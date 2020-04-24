//
//  LLSocketMessage.h
//  LLSocketKitExample
//
//  Created by LOLITA0164 on 2018/8/22.
//  Copyright © 2018年 LOLITA0164. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLSocketMessage : NSObject
@property (readonly, nonatomic, strong) NSDictionary *body;
@property (readonly, nonatomic, copy) NSString *string;

+(LLSocketMessage*)message:(NSString*)string;
+(LLSocketMessage*)messageBody:(NSDictionary*)body;

@end
