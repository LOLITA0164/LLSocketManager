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
    // 发送客户端信息
    LLSocketMessage* message = [LLSocketMessage messageBody:@{
        @"Users_Id":@"CA32977D14D72A98FF217A3796260A4B",
        @"Source":@"IOS iPhone Simulator(IOS 13.1)",
        @"AppKey":@"25061510",
    }];
    [LLSocketTool.share sendMessage:message];
}

/// 重写心跳包
-(void)sendKeepAliveData:(GCDAsyncSocket *)sock{
    [LLSocketTool.share sendMessage:[LLSocketMessage message:@"KEEPALIVE<EOF>"]];
}

/// socket 收到了数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* dataContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    LLLog(@"收到 socket 消息：%@",dataContent);
}



@end
