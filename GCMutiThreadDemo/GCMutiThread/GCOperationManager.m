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
    /**
     tip: 对于addOperation中的队列，它们的执行顺序取决于2点：
     
     1.首先看看队列是否已经准备好：是否准备好由对象的依赖关系确定
     
     2.然后再根据所有NSOperation的相对优先级来确定。
       优先级等级则是operation对象本身的一个属性。默认所有operation都拥有默认优先级,
       可以通过setQueuePriority:方法来提升或降低operation对象的优先级。优先级只能应用于相同queue中的operations。
       如果应用有多个operation queue,每个queue的优先级等级是互相独立的。因此不同queue中的低优先级操作仍然可能比高优先级操作更早执行。
     
     注意：优先级不能替代依赖关系,优先级只是对已经准备好的 operations确定执行顺序。先满足依赖关系,然后再根据优先级从所有准备好的操作中选择优先级最高的那个执行。
     
     */
    
    if (queue && mainQueue) {
        // 默认是按照添加顺序执行的，先执行queue，再执行queue
        // queue dependency mainQueues , queue 会等待mainQueue执行完毕后执行
        [queue addDependency:mainQueue];
        [operation addOperation:queue];
        [operation addOperation:mainQueue];
    }
}

@end
