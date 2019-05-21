//
//  PushPopTransition.m
//  Demo
//
//  Created by iOSer on 2019/5/17.
//  Copyright © 2019 Some one. All rights reserved.
//

#import "PushPopTransition.h"

@interface PushPopTransition ()

@end

@implementation PushPopTransition

- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionStyle == PushPopTransitionStylePercentDrivenInteractive) {
        [self interactiveAnimation:transitionContext];
        return;
    }
    if (self.operation == UINavigationControllerOperationPush) {
        [self pushAnimation:transitionContext];
    } else if (self.operation == UINavigationControllerOperationPop) {
        [self popAnimation:transitionContext];
    }
}

- (void)pushAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    //toVC为AnimatedViewController
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    //获取源sourceView截图，并计算frame
    UIView *snapSourceView = [self.sourceView snapshotViewAfterScreenUpdates:NO];
    snapSourceView.frame = [containerView convertRect:self.sourceView.frame fromView:self.sourceView.superview];
    //显示将要push的vc
    [containerView addSubview:toView];
    //把源截图加入当前视图
    [containerView addSubview:snapSourceView];
    //开始动画
    self.destinationView.hidden = YES;
    toView.alpha = 0.0;
    CGRect toFrame = [containerView convertRect:self.destinationView.frame fromView:self.destinationView.superview];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        //源截图设置为目标view位置
        snapSourceView.frame = toFrame;
        toView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [snapSourceView removeFromSuperview];
        self.destinationView.hidden = NO;
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)popAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    //fromVC为AnimatedViewController
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    //toVC任意
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    //与push逆过程，获取destinationView截图，并计算frame
    UIView *snapDestinationView = [self.destinationView snapshotViewAfterScreenUpdates:NO];
    snapDestinationView.frame = [containerView convertRect:self.destinationView.frame fromView:self.destinationView.superview];
    //显示将要pop的vc
    [containerView insertSubview:toView belowSubview:fromView];
    //把目标截图加入当前视图
    [containerView addSubview:snapDestinationView];
    //开始动画
    self.destinationView.hidden = YES;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{
        //过渡到源view
        snapDestinationView.frame = [containerView convertRect:self.sourceView.frame fromView:self.sourceView.superview];;
        fromView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.destinationView.hidden = NO;
        [snapDestinationView removeFromSuperview];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
    }];
}

- (void)interactiveAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = (UIViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    UIView *containerView = [transitionContext containerView];
    //显示将要pop到的vc
    [containerView insertSubview:toView belowSubview:fromView];
    /***一级动画，对应于UIPercentDrivenInteractiveTransition的updateInteractiveTransition:行为的进度，
     注意这里其实是假的动画，真正的动画在对应AnimatedViewController的panAction:方法中，
     之所以这样做，是因为该方法只在pop时候触发一次，
     如果真实改变某个存在于某个VC中的view的背景颜色或者其他效果，会导致动画结束时候某个view的效果定格在animations里的效果，
     而该效果与实际手势进度不符，会导致过渡效果不平滑
     ****/
    UIView *animateView = [[UIView alloc] initWithFrame:containerView.bounds];
    animateView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [containerView addSubview:animateView];
    animateView.hidden = YES;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration animations:^{//该block中实际alpha对应于UIPercentDrivenInteractiveTransition的percentComplete：alpha = 1 - percentComplete
        animateView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {//该block由UIPercentDrivenInteractiveTransition的finishInteractiveTransition或者cancelInteractiveTransition触发执行
        [animateView removeFromSuperview];
        if (transitionContext.transitionWasCancelled) {//cancelInteractiveTransition取消了pop
            [transitionContext completeTransition:NO];
            return;
        }
        //finishInteractiveTransition，执行了pop
        //与push逆过程，获取destinationView截图，并计算frame
        UIView *snapDestinationView = [self.destinationView snapshotViewAfterScreenUpdates:NO];
        snapDestinationView.frame = [containerView convertRect:self.destinationView.frame fromView:self.destinationView.superview];
        [containerView addSubview:snapDestinationView];
        self.destinationView.hidden = YES;
        [UIView animateWithDuration:duration animations:^{
            //过渡到源view
            snapDestinationView.frame = [containerView convertRect:self.sourceView.frame fromView:self.sourceView.superview];
        } completion:^(BOOL finished) {
            [snapDestinationView removeFromSuperview];
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}

@end
