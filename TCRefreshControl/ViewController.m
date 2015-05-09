//
//  ViewController.m
//  TCRefreshControl
//
//  Created by 曾明剑 on 15/5/8.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "ViewController.h"
#import "TCRefreshControl.h"
#import "UIScrollView+TCRefreshControl.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,TCRefreshControlDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TCRefreshControl *refreshControl;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    self.navigationItem.title = @"测试";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    
    _refreshControl = [[TCRefreshControl alloc] initWithScrollView:_tableView];
    _refreshControl.topEnabled = YES;
    _refreshControl.bottomEnabled = YES;
//    _refreshControl.delegate = self;
    
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
   
    
    
//    [_tableView addPullToRefreshPostion:TCRefreshPositionTop actionHander:^(TCRefreshControl *refresh){
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [refresh finishAnimation:TCRefreshPositionTop];
//        });
//        
//        
//    }];
    
    
    
    
    NSLog(@"contentOffset.y=%f",self.tableView.contentOffset.y);
    
    
    
    [_refreshControl addPullToRefreshPosition:TCRefreshPositionTop actionHander:^{
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_refreshControl finishAnimation:TCRefreshPositionTop];
//        });
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 刷新代理

- (void)refreshControl:(TCRefreshControl *)refreshControl didEngageRefreshDirection:(TCRefreshPosition)direction
{
    if (direction==TCRefreshPositionTop)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshControl finishAnimation:TCRefreshPositionTop];
        });
    }else
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [refreshControl finishAnimation:TCRefreshPositionBottom];
        });
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    
    return cell;
}




@end
