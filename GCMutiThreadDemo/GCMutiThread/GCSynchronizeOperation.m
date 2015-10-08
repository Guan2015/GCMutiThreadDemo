//
//  GCSynchronizeOperation.m
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import "GCSynchronizeOperation.h"

@implementation GCSynchronizeOperation

+ (GCSynchronizeOperation *)synchronizeQueue
{
    static GCSynchronizeOperation *shareQueues = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        shareQueues = [[self alloc] init];
    });
    
    return shareQueues;
}

- (instancetype)init
{
    if (self = [super init]) {
        // 设置最大并发数量
        self.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark -
#pragma mark   sync

+ (void)serialSyncBlock:(void (^)())block
{
    [[GCSynchronizeOperation synchronizeQueue] serialSyncBlock:block];
}

- (void)serialSyncBlock:(void (^)())block
{
    if ([NSOperationQueue currentQueue] == self) {
        block();
    }else{
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
        [self addOperations:@[operation] waitUntilFinished:YES];
    }
}

#pragma mark - 
#pragma mark   async

+ (void)concurrentAsyncBlock:(void (^)())block
{
    [[GCSynchronizeOperation synchronizeQueue] concurrentAsyncBlock:block];
}

- (void)concurrentAsyncBlock:(void (^)())block
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:block];
    [self addOperation:operation];
}





@end
