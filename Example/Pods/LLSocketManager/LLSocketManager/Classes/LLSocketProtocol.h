//
//  LLSocketProtocol.h
//  GuDaShi
//
//  Created by 骆亮 on 2018/8/22.
//  Copyright © 2018年 晨曦科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@protocol LLSocketProtocol <NSObject>

@optional
/// 心跳间隔
-(float)heartbeatInterval;
/// 链接检测间隔
-(float)checkAliveInterval;
/// socket 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port;
/// socket 断开链接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err;
/// 完成心跳包发送的内容
-(void)sendKeepAliveData:(GCDAsyncSocket *)sock;

@required
/// 完成 socket 接收到数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;

@end 
