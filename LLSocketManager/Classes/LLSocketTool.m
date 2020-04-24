//
//  LLSocketTool.m
//  LLSocketKitExample
//
//  Created by LOLITA0164 on 2018/8/22.
//  Copyright © 2018年 LOLITA0164. All rights reserved.
//

#import "LLSocketTool.h"
#import <Reachability/Reachability.h>

enum {
    SocketOfflineByServer,// 服务器掉线
    SocketOfflineByUser,  // 用户主动断掉，此时不需要重新链接
};

@interface LLSocketTool ()
@property (nonatomic, strong) GCDAsyncSocket* socket;  // socket
@property (readwrite, nonatomic, assign) BOOL isConnected;  // socket 是否连接

@property (nonatomic, assign) float heartbeatInterval;  // 心跳间隔
@property (nonatomic, strong) NSTimer* heartbeatTimer;  // 心跳计时器

@property (nonatomic, assign) float checkConnectInterval; // 链接检测间隔
@property (nonatomic, strong) NSTimer* checkConnectTimer; // 链接检测定时器
@end

@implementation LLSocketTool

#pragma mark - <************************** 实例初始化 **************************>
+(instancetype)share{
    static dispatch_once_t onceToken;
    static LLSocketTool* instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [LLSocketTool new];
        [instance addObservers];
    });
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    static LLSocketTool* instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        [instance addObservers];
    });
    return instance;
}

/// 心跳计时器
-(NSTimer *)heartbeatTimer{
    if (_heartbeatTimer == nil) {
        _heartbeatTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.heartbeatInterval] interval:self.heartbeatInterval target:self selector:@selector(sendHeartbeatPacket) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_heartbeatTimer forMode:NSDefaultRunLoopMode];
    }
    return _heartbeatTimer;
}

/// 检查链接计时器，该计时器会在链接成功后注销，被服务端断开后开启服务
-(NSTimer *)checkConnectTimer{
    if (_checkConnectTimer == nil) {
        _checkConnectTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:self.checkConnectInterval] interval:self.checkConnectInterval target:self selector:@selector(checkSocketConnect) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_checkConnectTimer forMode:NSDefaultRunLoopMode];
    }
    return _checkConnectTimer;
}

-(GCDAsyncSocket *)socket{
    if (_socket==nil) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

/// 心跳间隔
-(float)heartbeatInterval{
    if ([self.delegate respondsToSelector:@selector(heartbeatInterval)]) {
        return [self.delegate heartbeatInterval];
    }
    return 30;
}

/// 链接检测间隔
-(float)checkConnectInterval{
    if ([self.delegate respondsToSelector:@selector(checkConnectInterval)]) {
        return [self.delegate checkAliveInterval];
    }
    return 10;
}

/// socket 链接状态
-(BOOL)isConnected{
    return self.socket.isConnected;
}

/// 配置 socket 信息
-(void)setupHost:(NSString*)host port:(UInt16)port delegate:(id <LLSocketProtocol>)delegate{
    self.host = host;
    self.port = port;
    self.delegate = delegate;
}

#pragma mark - <************************** socket操作部分 **************************>
/// 连接host
-(void)connectHost{
    if (self.host.length == 0 || self.port == 0) { return; }
    // 链接前需要检测是否连接，否则出错
    if (self.isConnected) {
        [self cutOffSocketByUser]; // 主动断掉
    }
    NSError* error = nil;
    // 主动链接
    [self.socket connectToHost:self.host onPort:self.port withTimeout:3.0 error:&error];
    if (error) {
        // 发生错误，开始链接检测计时器尝试重连
        [self keepConnectCheck];
        LLLog(@"socket连接失败：%@",error.localizedDescription);
    }
}

/// 不确定当前是否断开状态，可调此方法，如果断开则自动重连
- (void)reConnectSocketIfNeed{
    if(self.isConnected == NO){
        [self connectHost];
    }
}

/// 主动断开链接
-(void)cutOffSocketByUser{
    self.socket.userData = [NSNumber numberWithInteger:SocketOfflineByUser];
    [self.socket disconnect];
    [self cutoffHeartbeatPacket];
}

/// 服务器断开链接
-(void)cutOffSocketByServer{
    self.socket.userData = [NSNumber numberWithInteger:SocketOfflineByServer];
    [self.socket disconnect];
    [self cutoffHeartbeatPacket];
}

/// 发送消息
-(void)sendMessage:(LLSocketMessage *)message{
    LLLog(@"socket：发送的消息为：%@", message.string);
    LLLog(@"socket是否正常链接：%@",self.isConnected ? @"YES" : @"NO");
    if (message.string.length) {
        NSData* data = [message.string dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket writeData:data withTimeout:-1 tag:0];
    }
}

/// 发送消息
-(void)sendData:(NSData *)data{
    if (self.isConnected && data.length) {
        [self.socket writeData:data withTimeout:-1 tag:0];
    } else {
        [self connectHost];
    }
}


#pragma mark - <************************** socket代理方法 **************************>
/// socket 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(nonnull NSString *)host port:(uint16_t)port{
    LLLog(@"socket 链接成功！！！");
    // 开启心跳包，保活
    [self keepAlive];
    // 注销 socket 检测
    [self invalidateConnectTimer];
    // 准备接收数据
    [self.socket readDataWithTimeout:-1 tag:0];
    
    // 将链接成功结果回调给可能的代理完成额外的任务
    if (self.delegate && [self.delegate respondsToSelector:@selector(socket:didConnectToHost:port:)]) {
        [self.delegate socket:sock didConnectToHost:host port:port];
    }
    if (self.connectSucceed) {
        self.connectSucceed(self);
    }
}

/// socket 断开链接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    // 如果是服务器断开，那么开启 socket 连接检测，尝试重新链接
    if (sock.userData == [NSNumber numberWithInteger:SocketOfflineByServer]) {
        [self keepConnectCheck];
        LLLog(@"服务器端 socket 断开了链接，%.0f秒后尝试重新链接", self.checkConnectInterval);
    }
    else if (sock.userData == [NSNumber numberWithInteger:SocketOfflineByUser]){
        [self cutOffSocketByUser];
        LLLog(@"客户端 socket 断开了链接。");
    }
    else {
        LLLog(@"socket 无故断开了链接。可能是网络问题。");
        // 开启socket连接检测
        [self keepConnectCheck];
    }
}

/// 接收到消息
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [sock readDataWithTimeout:-1 tag:0];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(socket:didReadData:withTag:)]) {
        [self.delegate socket:sock didReadData:data withTag:tag];
    }
}


#pragma mark - <************************** socket长链接与检测 **************************>
/// 开启心跳包
-(void)keepAlive{
    [self.heartbeatTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.heartbeatInterval]];
}
/// 开启链接检测
-(void)keepConnectCheck{
    [self.checkConnectTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:self.checkConnectInterval]];
}

/// 完成心跳包的发送
-(void)sendHeartbeatPacket{
    if (self.isConnected == NO ) {
        if (self.socket.userData == nil || self.socket.userData == [NSNumber numberWithInteger:SocketOfflineByServer]) {
            // 服务器掉线，重连
            [self connectHost];
            LLLog(@"服务器端 socket 断开了链接。");
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(sendKeepAliveData:)]) {
            [self.delegate sendKeepAliveData:self.socket];
        }
        else { // 如果没有代理完成心跳包的发送，这里提供了默认的发送
            NSString* flagString = @"KEEPALIVE<EOF>";
            NSData* data = [flagString dataUsingEncoding:NSUTF8StringEncoding];
            [self.socket writeData:data withTimeout:-1 tag:0];
        }
    }
}

/// 检测 socket 的链接
-(void)checkSocketConnect{
    [self connectHost];
}

/// 停止发送心跳包
-(void)cutoffHeartbeatPacket{
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
    // 如果是客户端主动断掉，则不需要链接检测计时器，否则需要尝试重连
    if (self.socket.userData == [NSNumber numberWithInteger:SocketOfflineByUser]) {
        [self invalidateConnectTimer];
    }
}

/// 注销链接检测计时器
-(void)invalidateConnectTimer{
    [_checkConnectTimer invalidate];
    _checkConnectTimer = nil;
}


#pragma mark - <************************** 应用即设备的变化监听 **************************>
/// 添加监听
-(void)addObservers{
    // 应用进入前台
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [self reConnectSocketIfNeed];
    }];
    // 应用进入后台
    [NSNotificationCenter.defaultCenter addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        [self cutOffSocketByUser];
    }];
    
    // 监听当前网络
    Reachability* reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    [NSNotificationCenter.defaultCenter addObserverForName:kReachabilityChangedNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:^(NSNotification * _Nonnull note) {
        Reachability* reach = [note object];
        if ([reach isKindOfClass:Reachability.class]) {
            switch (reach.currentReachabilityStatus) {
                case NotReachable:
                    [self cutOffSocketByUser];
                    break;
                default:
                    [self reConnectSocketIfNeed];
                    break;
            }
        }
    }];
}





@end
