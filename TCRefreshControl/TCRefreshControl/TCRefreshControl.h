//
//  TCRefreshControl.h
//  TCRefreshControl
//
//  Created by 曾明剑 on 15/5/9.
//  Copyright (c) 2015年 zmj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


///**
// * 当前refreshing状态
// */
//typedef enum {
//    TCRefreshingDirectionNone    = 0,
//    TCRefreshingDirectionTop     = 1 << 0,
//    TCRefreshingDirectionBottom  = 1 << 1
//} TCRefreshingDirections;

/**
 * 刷新的状态
 */
typedef NS_ENUM(NSUInteger, TCRefreshState) {
    TCRefreshStateStopped = 0,
    TCRefreshStateTriggered,
    TCRefreshStateLoading,
    TCRefreshStateAll = 10
};


/**
 *  指定回调方向
 */
typedef enum {
    TCRefreshPositionTop = 0,
    TCRefreshPositionBottom
} TCRefreshPosition;


@protocol TCRefreshControlDelegate;

typedef void(^TCRefreshControlActionHandler)();

@interface TCRefreshControl : NSObject

///当前的状态
@property (nonatomic,assign,readonly) TCRefreshState state;

@property (nonatomic,strong,readonly)UIScrollView * scrollView;
@property (nonatomic, weak) id <TCRefreshControlDelegate> delegate;


- (instancetype)initWithScrollView:(UIScrollView *)scrollView;


///是否开启下拉刷新，YES-开启 NO-不开启 默认是NO
@property (nonatomic,assign)BOOL topEnabled;
///是否开启上拉加载更多，YES-开启 NO-不开启 默认是NO
@property (nonatomic,assign)BOOL bottomEnabled;

///下拉刷新 状态改变的距离 默认65.0
@property (nonatomic,assign)float originalTopInset;
///上拉 状态改变的距离 默认65.0
@property (nonatomic,assign)float originalBottomInset;


/**
 *	注册Top加载的view,view必须接受RefreshViewDelegate协议,默认是RefreshTopView
 *	@param topClass 类类型
 */
- (void)registerClassForTopView:(Class)topClass;
/**
 *	注册Bottom加载的view,view必须接受RefreshViewDelegate协议,默认是RefreshBottomView
 *	@param bottomClass 类类型
 */

- (void)registerClassForBottomView:(Class)bottomClass;

///手动开启刷新
- (void)startAnimation:(TCRefreshPosition)direction;

///完成
- (void)finishAnimation:(TCRefreshPosition)direction;


- (void)addPullToRefreshPosition:(TCRefreshPosition)position actionHander:(TCRefreshControlActionHandler)hander;


@end


/**
 *	代理方法
 */
@protocol TCRefreshControlDelegate <NSObject>


@optional
- (void)refreshControl:(TCRefreshControl *)refreshControl didEngageRefreshDirection:(TCRefreshPosition) direction;

@end


