//
//  TCRefreshControl.m
//  TCRefreshControl
//
//  Created by 曾明剑 on 15/5/9.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import "TCRefreshControl.h"
#import "RefreshTopView.h"
#import "RefreshBottomView.h"
#import "RefreshViewDelegate.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fequalzero(a) (fabs(a) < FLT_EPSILON)

static CGFloat const TCPullToRefreshViewHeight = 65;

@interface TCRefreshControl ()

@property (nonatomic,strong)UIView * topView;
@property (nonatomic,strong)UIView * bottomView;

@property (nonatomic,copy)NSString * topClass;
@property (nonatomic,copy)NSString * bottomClass;

@property (nonatomic,copy) TCRefreshControlActionHandler hander;
@property (nonatomic,assign) CGFloat progress;

@property (nonatomic, readwrite) TCRefreshState state;
@property (nonatomic, readwrite) TCRefreshPosition position;

@end

@implementation TCRefreshControl

- (void)registerClassForTopView:(Class)topClass
{
    if ([topClass conformsToProtocol:@protocol(RefreshViewDelegate)]) {
        self.topClass = NSStringFromClass([topClass class]);
    }
    else{
        self.topClass = NSStringFromClass([RefreshTopView class]);
    }
}

- (void)registerClassForBottomView:(Class)bottomClass
{
    if ([bottomClass conformsToProtocol:@protocol(RefreshViewDelegate)]) {
        self.bottomClass = NSStringFromClass([bottomClass class]);
    }
    else{
        self.bottomClass = NSStringFromClass([RefreshBottomView class]);
    }
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
{
    self=[super init];
    if (self)
    {
        _scrollView = scrollView;
        
        _topClass = NSStringFromClass([RefreshTopView class]);
        _bottomClass = NSStringFromClass([RefreshBottomView class]);
        
        self.originalTopInset = scrollView.contentInset.top;
        self.originalBottomInset = scrollView.contentInset.bottom;
        
        self.state = TCRefreshStateStopped;
        
        [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
        
    }
    
    return self;
}

#pragma mark - KVO 

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqual:@"contentSize"])
    {
        if (self.topEnabled)
        {
            [self initTopView];
        }
        
        if (self.bottomEnabled)
        {
            [self initBottonView];
        }
    }
    else if([keyPath isEqualToString:@"contentOffset"])
    {
        
        
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
}


- (void)scrollViewDidScroll:(CGPoint)contentOffset
{
    CGFloat yOffset = contentOffset.y;
    
    NSLog(@"contentOffset.y = %f",contentOffset.y);
    
    if(self.state != TCRefreshStateLoading)
    {
        CGFloat scrollOffsetThreshold = 0;//offset临界值
        
        if (self.topEnabled && yOffset < -TCPullToRefreshViewHeight)
        {
            self.position = TCRefreshPositionTop;
            
            scrollOffsetThreshold = self.topView.frame.origin.y - self.originalTopInset;
            
            if(!self.scrollView.isDragging && _state == TCRefreshStateTriggered)
            {
                self.state = TCRefreshStateLoading;
            }
            else if(contentOffset.y < scrollOffsetThreshold && self.scrollView.isDragging && _state == TCRefreshStateStopped)
            {
                self.state = TCRefreshStateTriggered;
            }
            else if(contentOffset.y >= scrollOffsetThreshold && _state != TCRefreshStateStopped)
            {
                self.state = TCRefreshStateStopped;
            }
            
             self.progress = ((contentOffset.y + self.originalTopInset) / -TCPullToRefreshViewHeight);
            
        }else if (self.bottomEnabled && yOffset + self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
        {
            self.position = TCRefreshPositionBottom;
            
            scrollOffsetThreshold = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height, 0.0f) + self.bottomView.bounds.size.height + self.originalBottomInset;
            
            if(contentOffset.y > scrollOffsetThreshold && self.scrollView.isDragging && _state == TCRefreshStateStopped)
            {
                self.state = TCRefreshStateTriggered;
            }
            else if(contentOffset.y <= scrollOffsetThreshold && _state != TCRefreshStateStopped)
            {
                self.state = TCRefreshStateStopped;
            }
            
             self.progress = ((contentOffset.y + self.originalTopInset) / -TCPullToRefreshViewHeight);
        }
        
    } else
    {
        CGFloat offset;
        UIEdgeInsets contentInset;
        
        if (self.topEnabled) {
//            offset = MAX(self.scrollView.contentOffset.y * -1, 0.0f);
//            offset = MIN(offset, self.originalTopInset + self.topView.bounds.size.height);
//            contentInset = self.scrollView.contentInset;
//            self.scrollView.contentInset = UIEdgeInsetsMake(offset, contentInset.left, contentInset.bottom, contentInset.right);
        }else if (self.bottomEnabled)
        {
            if (self.scrollView.contentSize.height >= self.scrollView.bounds.size.height) {
                offset = MAX(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.bottomView.bounds.size.height, 0.0f);
                offset = MIN(offset, self.originalBottomInset + self.bottomView.bounds.size.height);
                contentInset = self.scrollView.contentInset;
                self.scrollView.contentInset = UIEdgeInsetsMake(contentInset.top, contentInset.left, offset, contentInset.right);
            }
        }
    }
}


- (void)setState:(TCRefreshState)newState
{
    if(_state == newState)
        return;
    
    //TCRefreshState previousState = _state;
    _state = newState;

    
    switch (newState) {
        case TCRefreshStateAll:
        case TCRefreshStateStopped:
            [self _didDisengageRefreshDirection:self.position];
            break;
            
        case TCRefreshStateTriggered:
            [self _didDisengageRefreshDirection:self.position];
            break;
            
        case TCRefreshStateLoading:
            
            [self _engageRefreshDirection:self.position];
            
            break;
    }

}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case TCRefreshPositionTop:
            currentInsets.top = self.originalTopInset;
            break;
        case TCRefreshPositionBottom:
            currentInsets.bottom = self.originalBottomInset;
            currentInsets.top = self.originalTopInset;
            break;
    }
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForLoading {
    CGFloat offset = MAX(self.scrollView.contentOffset.y * -1, 0);
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case TCRefreshPositionTop:
            currentInsets.top = MIN(offset, self.originalTopInset + self.topView.bounds.size.height);
            break;
        case TCRefreshPositionBottom:
            currentInsets.bottom = MIN(offset, self.originalBottomInset + self.bottomView.bounds.size.height);
            break;
    }
    [self setScrollViewContentInset:currentInsets];
}


- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}



#pragma mark - drag

- (void)_canEngageRefreshDirection:(TCRefreshPosition)direction
{
    if (direction == TCRefreshPositionTop)
    {
        [self.topView performSelector:@selector(canEngageRefresh)];
    }
    else if (direction == TCRefreshPositionBottom)
    {
        [self.bottomView performSelector:@selector(canEngageRefresh)];
    }
}


- (void)_didDisengageRefreshDirection:(TCRefreshPosition) direction
{
    if (direction==TCRefreshPositionTop)
    {
        [self.topView performSelector:@selector(didDisengageRefresh)];
    }
    else if (direction==TCRefreshPositionBottom)
    {
        [self.bottomView performSelector:@selector(didDisengageRefresh)];
    }
}

- (void)_engageRefreshDirection:(TCRefreshPosition) direction
{
    [self setScrollViewContentInsetForLoading];
    [self _didEngageRefreshDirection:direction];
}

- (void)_didEngageRefreshDirection:(TCRefreshPosition)direction
{
    if (direction==TCRefreshPositionTop)
    {
        [self.topView performSelector:@selector(startRefreshing)];
    }
    else if (direction==TCRefreshPositionBottom)
    {
        [self.bottomView performSelector:@selector(startRefreshing)];
    }
    
    if ([self.delegate respondsToSelector:@selector(refreshControl:didEngageRefreshDirection:)])
    {
        [self.delegate refreshControl:self didEngageRefreshDirection:direction];
    }
    
    if (self.hander) {
        self.hander();
    }
    
}

- (void)_startRefreshingDirection:(TCRefreshPosition)direction animation:(BOOL)animation
{
    CGPoint point = CGPointZero;
    
    if (direction == TCRefreshPositionTop)
    {
        float topH = self.originalTopInset < TCPullToRefreshViewHeight ? TCPullToRefreshViewHeight:self.originalTopInset;
        point = CGPointMake(0, -topH);
    }
    else if (direction==TCRefreshPositionBottom)
    {
        float height = MAX(self.scrollView.contentSize.height, self.scrollView.frame.size.height);
        float bottomH = self.originalBottomInset < TCPullToRefreshViewHeight ? TCPullToRefreshViewHeight:self.originalBottomInset;
        point = CGPointMake(0, height - self.scrollView.bounds.size.height + bottomH);
    }
    __weak typeof(self)weakSelf=self;
    
    [_scrollView setContentOffset:point animated:YES];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(self)strongSelf=weakSelf;
        [strongSelf _engageRefreshDirection:direction];
    });
}

- (void)_finishRefreshingDirection:(TCRefreshPosition)direction animation:(BOOL)animation
{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    switch (self.position) {
        case TCRefreshPositionTop:
            currentInsets.top = self.originalTopInset;
            break;
        case TCRefreshPositionBottom:
            currentInsets.bottom = self.originalBottomInset;
            currentInsets.top = self.originalTopInset;
            break;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.scrollView.contentInset = currentInsets;
        
    } completion:^(BOOL finished) {
        
    
        if (direction==TCRefreshPositionTop)
        {
            [self.topView performSelector:@selector(finishRefreshing)];
        }
        else if(direction==TCRefreshPositionBottom)
        {
            [self.bottomView performSelector:@selector(finishRefreshing)];
        }
        
        [self _didEngageRefreshDirection:self.position];
    }];
}

- (void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)initTopView
{
    if (!CGRectIsEmpty(self.scrollView.frame))
    {
        float topOffsetY = TCPullToRefreshViewHeight;
        
        if (self.topView == nil)
        {
            Class className = NSClassFromString(self.topClass);
            
            _topView = [[className alloc] initWithFrame:CGRectMake(0, -topOffsetY, self.scrollView.frame.size.width, topOffsetY)];
            [self.scrollView addSubview:self.topView];
        }
        else{
            _topView.frame = CGRectMake(0, -topOffsetY, self.scrollView.frame.size.width, topOffsetY);
            
            [_topView performSelector:@selector(resetLayoutSubViews)];
        }
    }
}

- (void)initBottonView
{
    if (!CGRectIsNull(self.scrollView.frame))
    {
        CGFloat y = MAX(self.scrollView.bounds.size.height, self.scrollView.contentSize.height);
        if (self.bottomView==nil)
        {
            Class className=NSClassFromString(self.bottomClass);
            
            _bottomView=[[className alloc] initWithFrame:CGRectMake(0,y , self.scrollView.bounds.size.width, TCPullToRefreshViewHeight)];
            [self.scrollView addSubview:_bottomView];
        }
        else{
            
            _bottomView.frame=CGRectMake(0,y , self.scrollView.bounds.size.width, self.originalBottomInset);
            [self.bottomView performSelector:@selector(resetLayoutSubViews)];
        }
    }
}

- (void)setTopEnabled:(BOOL)topEnabled
{
    _topEnabled=topEnabled;
    
    if (_topEnabled)
    {
        if (self.topView == nil)
        {
            [self initTopView];
        }
    }
    else{
        [self.topView removeFromSuperview];
        self.topView=nil;
    }
}

- (void)setBottomEnabled:(BOOL)bottomEnabled
{
    _bottomEnabled=bottomEnabled;
    
    if (_bottomEnabled)
    {
        if (_bottomView==nil)
        {
            [self initBottonView];
        }
    }
    else{
        [_bottomView removeFromSuperview];
        _bottomView=nil;
    }
}

- (void)startAnimation:(TCRefreshPosition)direction
{
    self.state = TCRefreshStateLoading;
    [self _startRefreshingDirection:direction animation:YES];
}

- (void)finishAnimation:(TCRefreshPosition)direction
{
    self.state = TCRefreshStateStopped;
    [self _finishRefreshingDirection:direction animation:YES];
}


- (void)addPullToRefreshPosition:(TCRefreshPosition)position actionHander:(TCRefreshControlActionHandler)hander
{
    self.hander = hander;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > 1.0) {
        _progress = 1.0;
    }else
    {
        _progress = progress;
    }
}



@end
