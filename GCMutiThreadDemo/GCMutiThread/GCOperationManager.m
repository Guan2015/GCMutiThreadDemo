//
//  GCOperationManager.m
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/10/8.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import "GCOperationManager.h"
#import "GCSynchronizeOperation.h"

@interface GCOperationManager()
{
    GCSynchronizeOperation *operation;
}

@end

@implementation GCOperationManager

+ (GCOperationManager *)shareManager
{
    static GCOperationManager *shareManager = nil;
    static dispatch_once_t     token;
    dispatch_once(&token, ^{
        shareManager = [[self alloc] init];
    });
    
    return shareManager;
}

-  (instancetype)init
{
    if (self = [super init]) {
        operation = [GCSynchronizeOperation synchronizeQueue];
    }
    
    return self;
}

#pragma mark - The queue operation
#pragma mark - 取消队列

- (void)cancelAllOperations
{
    [operation cancelAllOperations];
}

#pragma mark - 暂停

- (void)suspended
{
    [operation setSuspended:YES];
}

#pragma mark - 取消暂停

- (void)cancelSupended
{
    [operation setSuspended:NO];
}

#pragma mark - 依赖关系

- (void)setDependencyQueue:(NSOperation *)queue mainQueue:(NSOperation *)mainQueue 
{
    if (queue && mainQueue) {
        // 默认是按照添加顺序执行的，先执行queue，再执行queue
        // queue dependency mainQueues , queue 会等待mainQueue执行完毕后执行
        [queue addDependency:mainQueue];
        [operation addOperation:queue];
        [operation addOperation:mainQueue];
    }
}

@end
