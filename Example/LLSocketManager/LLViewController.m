//
//  LLViewController.m
//  LLSocketManager
//
//  Created by LOLITA0164 on 12/04/2019.
//  Copyright (c) 2019 LOLITA0164. All rights reserved.
//

#import "LLViewController.h"
#import <LLSocketManager/LLSocketManager.h>
#import "LLSocketHandler.h"

@interface LLViewController ()
@end

@implementation LLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // 47.111.76.92
    // 8001
    [LLSocketManager.share setupHost:@"47.111.76.92" port:8001 delegate:LLSocketHandler.new];
    [LLSocketManager.share connectHost];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
