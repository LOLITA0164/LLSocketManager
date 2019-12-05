//
//  LLSocketManagerHead.h
//  LLSocketManager_Example
//
//  Created by 骆亮 on 2019/12/4.
//  Copyright © 2019 LOLITA0164. All rights reserved.
//

#import "GCDAsyncSocket.h"
#import "LLSocketManager.h"
#import "LLSocketProtocol.h"
#import "LLSocketMessage.h"

#ifdef DEBUG
#define LLLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LLLog(...)
#endif
