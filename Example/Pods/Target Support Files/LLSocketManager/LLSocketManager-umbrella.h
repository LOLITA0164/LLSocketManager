#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "LLSocketHead.h"
#import "LLSocketManager.h"
#import "LLSocketMessage.h"
#import "LLSocketProtocol.h"

FOUNDATION_EXPORT double LLSocketManagerVersionNumber;
FOUNDATION_EXPORT const unsigned char LLSocketManagerVersionString[];

