//
//  NavigationControllerManager.m
//  Demo
//
//  Created by iOSer on 2019/5/20.
//  Copyright © 2019 Some one. All rights reserved.
//

#import "NavigationControllerManager.h"

@interface WeakObject : NSObject
@property (nonatomic, weak) id weakObject;
@end

@implementation WeakObject

@end

@interface NavigationControllerManager () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) NSMutableArray<WeakObject *> *navigationControllers;
@end

@implementation NavigationControllerManager

+ (NavigationControllerManager *)shared {
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        self.navigationControllers = [NSMutableArray array];
    }
    return self;
}

- (void)addNavigationController:(UINavigationController *)navigationController {
    navigationController.delegate = self;
    navigationController.interactivePopGestureRecognizer.delegate = self;
    WeakObject *wo = [[WeakObject alloc] init];
    wo.weakObject = navigationController;
    [self.navigationControllers addObject:wo];
}

- (void)removeNavigationController:(UINavigationController *)navigationController {
    for (NSUInteger i = self.navigationControllers.count; i > 0; i--) {
        WeakObject *wo = self.navigationControllers[i-1];
        if (navigationController == wo.weakObject) {
            navigationController.delegate = nil;
            navigationController.interactivePopGestureRecognizer.delegate = nil;
            [self.navigationControllers removeObjectAtIndex:i-1];
        }
    }
}

- (void)bindNavigationControllerDelegate:(UINavigationController *)navigationController toObject:(id)object {
    navigationController.delegate = object;
    navigationController.interactivePopGestureRecognizer.delegate = object;
}

- (void)unbindNavigationControllerDelegate:(UINavigationController *)navigationController {
    navigationController.delegate = self;
    navigationController.interactivePopGestureRecognizer.delegate = self;
}

- (nullable id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                           animationControllerForOperation:(UINavigationControllerOperation)operation
                                                        fromViewController:(UIViewController *)fromVC
                                                          toViewController:(UIViewController *)toVC {
    if (navigationController.delegate == self) {
        return nil;
    }
    if ([navigationController.delegate respondsToSelector:_cmd]) {
        return [navigationController.delegate navigationController:navigationController animationControllerForOperation:operation fromViewController:fromVC toViewController:toVC];
    }
    return nil;
}

- (nullable id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if (navigationController.delegate == self) {
        return nil;
    }
    if ([navigationController.delegate respondsToSelector:_cmd]) {
        return [navigationController.delegate navigationController:navigationController interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    for (WeakObject *wo in self.navigationControllers) {
        UINavigationController *nav = wo.weakObject;
        if (gestureRecognizer != nav.interactivePopGestureRecognizer) {
            continue;
        }
        if (nav.delegate == self) {
            continue;
        }
        if ([nav.delegate respondsToSelector:_cmd]) {
            id<UIGestureRecognizerDelegate> delegate = (id<UIGestureRecognizerDelegate>)nav.delegate;
            return [delegate gestureRecognizerShouldBegin:gestureRecognizer];
        }
    }
    return YES;
}

@end

