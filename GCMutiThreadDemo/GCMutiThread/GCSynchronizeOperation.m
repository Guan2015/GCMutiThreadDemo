//
//  GCSynchronizeOperation.m
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import "GCSynchronizeOperation.h"

@implementation GCSynchronizeOperation

- (GCSynchronizeOperation *)synchronizeQueue
{
    static GCSynchronizeOperation *shareQueues = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareQueues = [[GCSynchronizeOperation alloc] init];
    });
    
    return shareQueues;
}

- (instancetype)init
{
    if (self = [super init]) {

    }
    return self;
}

@end
