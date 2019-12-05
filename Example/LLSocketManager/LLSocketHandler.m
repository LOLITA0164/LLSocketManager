//
//  LLSocketHandler.m
//  LLSocketManager_Example
//
//  Created by 骆亮 on 2019/12/5.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

#import "LLSocketHandler.h"

@implementation LLSocketHandler

/// socket 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    // 发送一些额外的信息，例如客户端信息
}

/// 发送心跳包数据
-(void)sendKeepAliveData:(GCDAsyncSocket *)sock{
    // 在这里发送心跳包数据
}

/// socket 收到了数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* dataContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    LLLog(@"收到 socket 消息：%@",dataContent);
    // 在这里进行 socket 的转发
}



@end
