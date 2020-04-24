//
//  LLSocketMessage.m
//  LLSocketKitExample
//
//  Created by LOLITA0164 on 2018/8/22.
//  Copyright © 2018年 LOLITA0164. All rights reserved.
//

#import "LLSocketMessage.h"

@interface LLSocketMessage ()
@property (readwrite,strong ,nonatomic) NSDictionary *body;
@property (readwrite,copy ,nonatomic) NSString *string;
@end

@implementation LLSocketMessage

+(LLSocketMessage*)message:(NSString*)string body:(NSDictionary*)body{
    LLSocketMessage* message = [LLSocketMessage new];
    message.body = body;
    message.string = string;
    if (body.allKeys.count) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
        if (jsonData) {
            message.string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    // 添加结束
    if (![message.string hasSuffix:@"<EOF>"]) {
        message.string = [NSString stringWithFormat:@"%@<EOF>",message.string];
    }
    return message;
}

+(LLSocketMessage*)message:(NSString*)string{
    return [self message:string body:nil];
}
+(LLSocketMessage*)messageBody:(NSDictionary*)body{
    return [self message:nil body:body];
}

@end
