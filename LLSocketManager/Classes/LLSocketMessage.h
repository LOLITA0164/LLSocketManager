//
//  SocketMessage.h
//  GuDaShi
//
//  Created by 骆亮 on 2018/8/22.
//  Copyright © 2018年 晨曦科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LLSocketMessage : NSObject

@property (readonly,strong ,nonatomic) NSDictionary *body;
@property (readonly,copy ,nonatomic) NSString *string;

+(LLSocketMessage*)message:(NSString*)string;
+(LLSocketMessage*)messageBody:(NSDictionary*)body;

@end
