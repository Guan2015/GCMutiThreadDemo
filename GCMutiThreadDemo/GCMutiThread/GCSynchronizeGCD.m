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

+ (GCSynchronizeGCD *)concurrentQueue
{
    static GCSynchronizeGCD *shareInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareInstance = [[self alloc] initConcurrent];
    });
    
    return shareInstance;
}

//! 串行队列
- (id)init
{
    if (self = [super init]) {
        queue = dispatch_queue_create("com.ihardy.GCSynchronize", NULL);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        // 设置目标优先级
        dispatch_set_target_queue(queue, globalQueue);
    }
    return self;
}

//! 并行队列
- (id)initConcurrent
{
    if (self = [super init]) {
        queue = dispatch_queue_create("com.ihardy.GCConcurrent", DISPATCH_QUEUE_CONCURRENT);
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND , 0);
        dispatch_set_target_queue(queue, globalQueue);
    }
    return self;
}

- (void)testBarrier
{
    dispatch_async(queue, ^{
        NSLog(@"read1");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"read2");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"read3");
    });
    
//    dispatch_async(queue, ^{
//        NSLog(@"write3/update");
//    });
    // A dispatch barrier allows you to create a synchronization point within a concurrent dispatch queue. 
    // 保证 read3 again 和 read4 再 write /update 后执行
    dispatch_barrier_async(queue, ^{
        NSLog(@"write3/update");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"read3 again new");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"read4");
    });
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
