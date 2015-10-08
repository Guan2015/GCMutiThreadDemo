//
//  ViewController.m
//  GCMutiThreadDemo
//
//  Created by 哈帝 on 15/9/28.
//  Copyright (c) 2015年 guan. All rights reserved.
//

#import "ViewController.h"
#import "GCSynchronizeGCD.h"
#import "GCSynchronizeOperation.h"
#import "GCOperationManager.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)NSArray *testGCDs;
@property (nonatomic ,strong)NSArray *testQueues;
@property (nonatomic ,strong)NSArray *testOperation;

@end

@implementation ViewController

- (id)init
{
    if (self = [super init]) {
        // story board 不会走init
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _testGCDs = @[@"串行同步",@"并行同步"];
    _testQueues = @[@"串行同步", @"并行同步"];
    _testOperation = @[@"并行同步取消任务",@"暂停队列",@"依赖关系"];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark   test task

- (void)execATask
{
    for (int i = 0; i < 10; i ++) {
        NSLog(@"A task %d \n",i);
    }
}

- (void)execBTask
{
    for (int i = 0; i < 10; i ++) {
        NSLog(@"B task %d",i);
    }
}

#pragma mark - 并行并发

- (void)execMutiTask
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self execATask];
        NSLog(@"A task done");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self execBTask];
         NSLog(@"B task done");
    });
}

#pragma mark - GCD串行同步
#pragma mark   串行执行

- (void)gcd_seriallSync
{
    [GCSynchronizeGCD syncBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self execATask];
             NSLog(@"A task done");
        });
        NSLog(@"A task gone ------ \n");
    }];
    [GCSynchronizeGCD syncBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self execBTask];
            NSLog(@"B task done");
        });
        NSLog(@"B task gone ------ \n");
    }];
}

#pragma mark 并行执行

- (void)gcd_concurrentSync
{
    [GCSynchronizeGCD asyncBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self execATask];
             NSLog(@"A task done");
        });
        NSLog(@"A task gone ------ \n");
    }];
    
    [GCSynchronizeGCD asyncBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self execBTask];
             NSLog(@"B task done");
        });
        NSLog(@"Bnnn task gone ------ \n");
    }];
}


#pragma mark -
#pragma mark    OperationQueue

- (void)queue_serialSync
{
    NSLog(@"%@",[GCSynchronizeOperation currentQueue].name);
    [GCSynchronizeOperation serialSyncBlock:^{
        [self execATask];
    }];
    [GCSynchronizeOperation serialSyncBlock:^{
        [self execBTask];
    }];
}

- (void)queue_concurrentSync
{
    [GCSynchronizeOperation concurrentAsyncBlock:^{
        [self execATask];
    }];
    [GCSynchronizeOperation concurrentAsyncBlock:^{
        [self execBTask];
    }];
}

#pragma mark - operation

- (void)queueCancel
{
    [GCSynchronizeOperation concurrentAsyncBlock:^{
        [[GCOperationManager shareManager] cancelAllOperations];
//        [GCSynchronizeOperation cancelAllOperations];
        [self execATask];
    }];
    // 取消后不会再执行B
    [GCSynchronizeOperation concurrentAsyncBlock:^{
        [self execBTask];
    }];
    // 测试发现不能取消当前执行的任务，执行完后当前队列才能取消
    // 后来看文档发现 Canceling the operations does not automatically remove them from the queue or stop those that are currently executing
    // 如果你有更好的想法，请联系 gc@ihardy.net 非常感谢！
}

- (void)suspended
{
    [GCSynchronizeOperation concurrentAsyncBlock:^{
//        [GCSynchronizeOperation suspended];
        [[GCOperationManager shareManager] suspended];
        NSLog(@"suspended ...");
        NSLog(@"start A task  ...");
        [self execATask];
        // 此处 暂停是对该队列稍后执行，当所有队列执行完毕后再执行暂停队列,取消后该队列正常运行。但不能取消当前正在执行队列。
//      [GCSynchronizeOperation cancelSupended];
//      NSLog(@"cancel susppended");
    }];
    
    [GCSynchronizeOperation concurrentAsyncBlock:^{
         NSLog(@"start B task  ...");
        [self execBTask];
        
    }];
    
    [GCSynchronizeOperation concurrentAsyncBlock:^{
        NSLog(@"start A task again  ...");
        [self execATask];
    }];
    
}

//! 依赖关系
- (void)testDependency
{
    NSBlockOperation *mainQueue = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"正在定位...");
        sleep(3);
        NSLog(@"定位完成");
    }];
    
    NSBlockOperation *queue = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"搜索周围机器人");
    }];
    
    [[GCOperationManager shareManager] setDependencyQueue:queue mainQueue:mainQueue];
}

#pragma mark -
#pragma mark   tableView && tableView datasource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *cellIndentifier = @"testMutiThread";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
    }
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"多线程";
            break;
        case 1:
            cell.textLabel.text = _testGCDs[indexPath.row];
            break;
        case 2:
            cell.textLabel.text = _testQueues[indexPath.row];
            break;
        case 3:
            cell.textLabel.text = _testOperation[indexPath.row];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;
        case 1:return _testGCDs.count;
        case 2:return _testQueues.count;
        case 3:return _testOperation.count;
            
        default: return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @" ";
        case 1:
            return @"GCD";
        case 2:
            return @"OperationQueue";
        case 3:
            return @"Operation";
            
        default: return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:{
            [self execMutiTask];
        }
            break;
        case 1:{
        
            switch (indexPath.row) {
                case 0:
                {
                    [self gcd_seriallSync];
                }
                    break;
                case 1:
                {
                    [self gcd_concurrentSync];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    [self queue_serialSync];
                    break;
                case 1:
                    [self queue_concurrentSync];
                    break;
                default:
                    break;
            }
            break;
            
        case 3:
            switch (indexPath.row) {
                case 0:
                    [self queueCancel];
                    break;
                case 1:
                    [self suspended];
                    break;
                case 2:
                    // 依赖关系
                    [self testDependency];
                    break;
                case 3:
                    
                    break;
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
