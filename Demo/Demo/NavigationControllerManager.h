//
//  NavigationControllerManager.h
//  Demo
//
//  Created by iOSer on 2019/5/20.
//  Copyright © 2019 Some one. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavigationControllerManager : NSObject
@property (nonatomic, strong, readonly, class) NavigationControllerManager *shared;
- (void)addNavigationController:(UINavigationController *)navigationController;
- (void)removeNavigationController:(UINavigationController *)navigationController;
- (void)bindNavigationControllerDelegate:(UINavigationController *)navigationController toObject:(id)object;
- (void)unbindNavigationControllerDelegate:(UINavigationController *)navigationController;
@end

NS_ASSUME_NONNULL_END
