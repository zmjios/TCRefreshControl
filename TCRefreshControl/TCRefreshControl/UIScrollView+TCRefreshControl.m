//
//  UIScrollView+TCRefreshControl.m
//  TCRefreshControl
//
//  Created by 曾明剑 on 15/5/9.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "UIScrollView+TCRefreshControl.h"
#import <objc/runtime.h>

static char refreshControlKey;

@implementation UIScrollView (TCRefreshControl)


- (TCRefreshControl *)refreshControl
{
    return objc_getAssociatedObject(self, &refreshControlKey);
}


- (void)setRefreshControl:(TCRefreshControl *)refreshControl
{
    objc_setAssociatedObject(self, &refreshControlKey, refreshControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (void)addPullToRefreshPostion:(TCRefreshPosition)position actionHander:(TCRefreshControlHander)hander
{
    self.refreshControl = [[TCRefreshControl alloc] initWithScrollView:self];
    
    [self.refreshControl addPullToRefreshPosition:position actionHander:^{
        
        if (hander) {
            hander(self.refreshControl);
        }
    }];
}




@end
