//
//  GCSynchronizeGCD.m
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import "GCSynchronizeGCD.h"


@interface GCSynchronizeGCD ()
{
    dispatch_queue_t queue;
}

@end

@implementation GCSynchronizeGCD

+ (GCSynchronizeGCD *)synchronizeQueue
{
    static GCSynchronizeGCD *shareInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[self alloc] init];
    });
    
    return shareInstance;
}

- (id)init
{
    if (self = [super init]) {
        queue = dispatch_queue_create("com.ihardy.GCSynchronize", NULL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_set_target_queue(queue, globalQueue);
    }
    return self;
}

#pragma  mark -
#pragma  mark   串行同步
+ (void)syncBlock:(void (^)()) block
{
    [[GCSynchronizeGCD synchronizeQueue] p_syncBlock:block];
}

// pravite
- (void)p_syncBlock:(void (^)())block
{
    dispatch_sync(queue, ^{
        block();
    });
}


#pragma mark -
#pragma mark    并行同步
+ (void)asyncBlock:(void (^)())block
{
    [[GCSynchronizeGCD synchronizeQueue] p_asyncBlock:block];
}

// private
- (void)p_asyncBlock:(void (^)())block
{
    dispatch_async(queue, ^{
        block();
    });
}

@end
