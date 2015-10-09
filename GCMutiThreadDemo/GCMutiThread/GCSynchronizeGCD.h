//
//  GCSynchronizeGCD.h
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCSynchronizeGCD : NSObject

+ (void)syncBlock:(void (^)()) block;

+ (void)asyncBlock:(void (^)())block;

+ (GCSynchronizeGCD *)concurrentQueue;

+ (GCSynchronizeGCD *)synchronizeQueue;

- (void)testBarrier;

- (void)test_gcdApply;

- (void)test_gcdSemaphore;

@end
