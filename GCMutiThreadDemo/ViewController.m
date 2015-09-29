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

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic ,strong)NSArray *testGCDs;
@property (nonatomic ,strong)NSArray *testQueues;

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
    _testQueues = @[@"串行同步", @"并行同步", @"并行同步取消任务"];
    // Do any additional setup after loading the view, typically from a nib.
}

#pragma mark -
#pragma mark   test task

- (void)execATask
{
    for (int i = 0; i < 5; i ++) {
        NSLog(@"A task %d \n",i);
    }
}

- (void)execBTask
{
    for (int i = 0; i < 5; i ++) {
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

#pragma mark - 串行同步
#pragma mark   串行执行

- (void)seriallSync
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

- (void)concurrentSync
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
            
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:return 1;
        case 1:return _testGCDs.count;
        case 2:return _testQueues.count;
            
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
                    [self seriallSync];
                }
                    break;
                case 1:
                {
                    [self concurrentSync];
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
                    
                    break;
                case 1:
                    
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
