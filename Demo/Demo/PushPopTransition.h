//
//  TransitionObject.h
//  Demo
//
//  Created by iOSer on 2019/5/17.
//  Copyright © 2019 Some one. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PushPopTransitionStyle) {
    PushPopTransitionStyleDefault = 0,//默认
    PushPopTransitionStylePercentDrivenInteractive = 1,//百分比，一般用于手势拖动场景
};

@interface PushPopTransition : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic) UINavigationControllerOperation operation;
@property (nonatomic) PushPopTransitionStyle transitionStyle;
@property (nonatomic, weak) UIView *sourceView;//源view
@property (nonatomic, weak) UIView *destinationView;//目的view
@end

NS_ASSUME_NONNULL_END
