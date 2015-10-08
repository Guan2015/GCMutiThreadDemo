//
//  GCSynchronizeOperation.h
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCSynchronizeOperation : NSOperationQueue

+ (GCSynchronizeOperation *)synchronizeQueue;

+ (void)serialSyncBlock:(void (^)())block;

+ (void)concurrentAsyncBlock:(void (^)())block;

@end
