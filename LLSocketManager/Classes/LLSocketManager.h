//
//  LLSocketDelegate.h
//  NSNotificationCenter
//
//  Created by 骆亮 on 2018/8/22.
//  Copyright © 2018年 LOLITA0164. All rights reserved.
//

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <unistd.h>
#import <Foundation/Foundation.h>
#import "LLSocketHead.h"
#import "LLSocketMessage.h"

/*
 主要功能：完成 Socket 的链接保活功能
 */

@protocol LLSocketProtocol;
@interface LLSocketManager : NSObject <GCDAsyncSocketDelegate>

@property (nonatomic, copy) NSString* host; // 主机host （必须）
@property (nonatomic, assign) UInt16 port;  // 端口号 （必须）
@property (nonatomic, strong) id <LLSocketProtocol> delegate; // 用于处理或者配置 socket （必须）

@property (readonly, nonatomic, assign) BOOL isConnected;  // socket 是否连接

/// 实例
+(instancetype)share;

/// 配置 socket 信息
-(void)setupHost:(NSString*)host port:(UInt16)port delegate:(id <LLSocketProtocol>)delegate;

/// 主动连接
-(void)connectHost;
/// 不确定当前是否断开状态，可调此方法，如果断开则自动重连
-(void)reConnectSocketIfNeed;

/// 主动断开链接
-(void)cutOffSocketByUser;
/// 服务器断开链接，checkAliveInterval 后会尝试重新链接
-(void)cutOffSocketByServer;

/// 发送消息
-(void)sendMessage:(LLSocketMessage*)message;
/// 发送消息
-(void)sendData:(NSData*)data;

@end


















