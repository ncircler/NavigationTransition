//
//  AnimatedViewController.m
//  Demo
//
//  Created by iOSer on 2019/5/17.
//  Copyright © 2019 Some one. All rights reserved.
//

#import "AnimatedViewController.h"
#import "ViewController2.h"
#import "PushPopTransition.h"
#import "NavigationControllerManager.h"

@interface AnimatedViewController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) PushPopTransition *transition;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) IBOutlet UIView *blueView;
@property (nonatomic) CGRect blueViewFrame;

@property (nonatomic, weak) IBOutlet UIView *greenView;

@end

@implementation AnimatedViewController

+ (void)showWithSourceView:(UIView *)sourceView {
    UINavigationController *nav = (UINavigationController *)UIApplication.sharedApplication.delegate.window.rootViewController;
    AnimatedViewController *avc = [[AnimatedViewController alloc] initWithNibName:@"AnimatedViewController" bundle:nil];
    //处理导航，将导航的delegate绑定到AnimatedViewController
    [NavigationControllerManager.shared bindNavigationControllerDelegate:nav toObject:avc];
    //初始化动画处理实例
    PushPopTransition *transition = [[PushPopTransition alloc] init];
    transition.sourceView = sourceView;//前一个页面的红色块view
    //动画处理类赋值给AnimatedViewController
    avc.transition = transition;
    [nav pushViewController:avc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", @(self.navigationController.viewControllers.count)];
    //给目标view，由sourceView代表的红色块平滑过渡到destinationView代表的蓝色块，或者相反
    self.transition.destinationView = self.blueView;
    [self addGestures];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //重置导航代理，保留back行为，
    [self resetNavigationDelegate];
}

#pragma mark- private method

- (void)addGestures {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [self.blueView addGestureRecognizer:pan];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGPoint translationInView = [pan translationInView:self.blueView];
    CGFloat progress = translationInView.y / self.view.bounds.size.height;
    progress = MIN(1.0, MAX(0.0, progress));//把这个百分比限制在0~1之间
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.blueViewFrame = self.blueView.frame;
            self.percentDrivenTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
            [self holdNavigationDelegate];
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case UIGestureRecognizerStateChanged: {
            CGRect frame = self.blueViewFrame;
            frame.origin.x += translationInView.x;
            frame.origin.y += translationInView.y;
            self.blueView.frame = frame;
            self.backgroundView.alpha = 1 - progress;
            [self.percentDrivenTransition updateInteractiveTransition:progress];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            if (progress > 0.5) {
                [self.percentDrivenTransition finishInteractiveTransition];
            } else {
                [self.percentDrivenTransition cancelInteractiveTransition];
                [UIView animateWithDuration:self.percentDrivenTransition.duration animations:^{
                    self.blueView.frame = self.blueViewFrame;
                    self.backgroundView.alpha = 1;
                }];
            }
            [self resetNavigationDelegate];
            self.percentDrivenTransition = nil;
        }
            break;
        default:
            break;
    }
}

- (IBAction)close:(UIButton *)sender {
    [self holdNavigationDelegate];//自定义动画
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)push1:(UIButton *)sender {
    [self resetNavigationDelegate];
    [AnimatedViewController showWithSourceView:self.greenView];
}

- (IBAction)push2:(UIButton *)sender {
    [self resetNavigationDelegate];
    ViewController2 *v2 = [[ViewController2 alloc] initWithNibName:@"ViewController2" bundle:nil];
    [self.navigationController pushViewController:v2 animated:YES];
}

- (void)holdNavigationDelegate {
    [NavigationControllerManager.shared bindNavigationControllerDelegate:self.navigationController toObject:self];
}

- (void)resetNavigationDelegate {
    [NavigationControllerManager.shared unbindNavigationControllerDelegate:self.navigationController];
}

#pragma mark - UINavigationController delegate

- (nullable id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                           animationControllerForOperation:(UINavigationControllerOperation)operation
                                                        fromViewController:(UIViewController *)fromVC
                                                          toViewController:(UIViewController *)toVC {
    self.transition.operation = operation;
    if (operation == UINavigationControllerOperationPush) {
        if ([toVC isKindOfClass:self.class]) {
            return self.transition;
        }
        return nil;
    }
    if (operation == UINavigationControllerOperationPop) {
        if ([fromVC isKindOfClass:self.class]) {
            if (self.percentDrivenTransition != nil) {
                self.transition.transitionStyle = PushPopTransitionStylePercentDrivenInteractive;
            }
            return self.transition;
        }
        return nil;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.percentDrivenTransition;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
