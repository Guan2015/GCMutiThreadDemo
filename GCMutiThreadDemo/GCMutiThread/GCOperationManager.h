//
//  GCOperationManager.h
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/10/8.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCOperationManager : NSObject

+ (GCOperationManager *)shareManager;

- (void)cancelAllOperations;

- (void)suspended;

- (void)cancelSupended;

- (void)setDependencyQueue:(NSOperation *)queue mainQueue:(NSOperation *)mainQueue;
@end
