

//
//  UIScrollView+TCRefreshControl.h
//  TCRefreshControl
//
//  Created by 曾明剑 on 15/5/9.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCRefreshControl.h"


typedef  void(^TCRefreshControlHander)(TCRefreshControl *);

@interface UIScrollView (TCRefreshControl)


- (void)addPullToRefreshPostion:(TCRefreshPosition)position actionHander:(TCRefreshControlHander)hander;

@end
