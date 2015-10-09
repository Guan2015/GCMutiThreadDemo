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

#pragma mark - test

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

- (void)test_gcdApply
{
    NSArray *photos = @[@"photo1",@"photo2",@"photo3",@"photo4",@"photo5"];
    
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // dispatch_apply 与 dispatch_sync 相同都是等待所有任务完成后执行，使用串行会造成 “死锁”
    // block 永远不会执行
    // dispatch_queue_t globalQueue = dispatch_queue_create("com.ihardy.apply", NULL);
    dispatch_async(globalQueue, ^{
        dispatch_apply(photos.count, globalQueue, ^(size_t index) {
            NSLog(@"上传%@",photos[index]);
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"上传完毕");
        });
    });
}

- (void)test_gcdSemaphore
{
    // NSMutableArray 不支持多线程，有可能造成数组错乱
    NSMutableArray *photos = [NSMutableArray array];
    // 默认设置信号量大于1
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    for (int i = 0; i < 5; i ++) {
        
        dispatch_async(queue, ^{
            //            dispatch_time_t time = dispatch_time(DISPATCH_TIME_FOREVER, 1ull * nec)
            /** 等待信号量
             *
             * 一直等待，直到信号量计数器大于等于1。
             */
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            /** 因为信号量计数器>=1，
             * dispatch_semaphore_wait函数停止等待，计数器自动-1，流程继续
             *
             * 到这里的时候，计数器始终会变成0。
             * 因为初始时为1，限定了一次只能有一个线程访问NSMutableArray对象。(但使用并行队列并不能保证顺序)
             *
             * 现在，在这里，你可以安全地更新数组了。
             */
            [photos addObject:[NSString stringWithFormat:@" 照片%d",i]];
            
            // + 1
            dispatch_semaphore_signal(semaphore);
            
        });
    }
}


@end
