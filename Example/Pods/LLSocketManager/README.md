# LLSocketManager

[![CI Status](https://img.shields.io/travis/LOLITA0164/LLSocketManager.svg?style=flat)](https://travis-ci.org/LOLITA0164/LLSocketManager)
[![Version](https://img.shields.io/cocoapods/v/LLSocketManager.svg?style=flat)](https://cocoapods.org/pods/LLSocketManager)
[![License](https://img.shields.io/cocoapods/l/LLSocketManager.svg?style=flat)](https://cocoapods.org/pods/LLSocketManager)
[![Platform](https://img.shields.io/cocoapods/p/LLSocketManager.svg?style=flat)](https://cocoapods.org/pods/LLSocketManager)

## 安装

LLSocketManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LLSocketManager'
```

## 使用

```
#import <LLSocketManager/LLSocketManager.h>

// 配置 host、port 以及代理对象
[LLSocketManager.share setupHost:@"xxxx.xxxx.xxxx.xxxx" port:8001 delegate:AObject];
// 链接 socket
[LLSocketManager.share connectHost];

```

`LLSocketManager` 自动帮你重连，发送心跳包保持长链接。你要做的就是设置遵循协议 `LLSocketProtocol` 的代理对象，该协议让你完成一些功能设置，其中必须要实现的就是来自服务端 `socket` 的消息转发功能。


比如新建实例 `LLSocketHandler`:

```
#import <LLSocketManager/LLSocketManager.h>
@interface LLSocketHandler : NSObject <LLSocketProtocol>
@end

@implementation LLSocketHandler

/// socket 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    // 发送一些额外的信息，例如客户端信息
}

/// 发送心跳包数据
-(void)sendKeepAliveData:(GCDAsyncSocket *)sock{
    // 在这里发送心跳包数据
    // 例如：[LLSocketManager.share sendMessage:[LLSocketMessage message:@"KEEPALIVE<EOF>"]];
}

/// socket 收到了数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString* dataContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    LLLog(@"收到 socket 消息：%@",dataContent);
    // 在这里进行 socket 的处理和转发
}
@end
```




## License

LLSocketManager is available under the MIT license. See the LICENSE file for more info.
