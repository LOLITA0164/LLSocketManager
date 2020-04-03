//
//  LLSocketManager.h
//  LLSocketManager
//
//  Created by QS on 2020/1/8.
//  Copyright © 2020 LOLITA0164. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for LLSocketManager.
FOUNDATION_EXPORT double LLSocketManagerVersionNumber;

//! Project version string for LLSocketManager.
FOUNDATION_EXPORT const unsigned char LLSocketManagerVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LLSocketManager/PublicHeader.h>


#import <LLSocketManager/LLSocketProtocol.h>
#import <LLSocketManager/LLSocketTool.h>
#import <LLSocketManager/LLSocketMessage.h>


#ifdef DEBUG
#define LLLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define LLLog(...)
#endif
