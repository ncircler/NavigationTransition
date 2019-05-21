//
//  NavigationRootViewController.m
//  Demo
//
//  Created by iOSer on 2019/5/17.
//  Copyright © 2019 Some one. All rights reserved.
//

#import "NavigationRootViewController.h"
#import "AnimatedViewController.h"

@interface NavigationRootViewController ()
@property (nonatomic, weak) IBOutlet UIView *redView;
@end

@implementation NavigationRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", @(self.navigationController.viewControllers.count)];
}

- (IBAction)push1:(UIButton *)button {
    [AnimatedViewController showWithSourceView:self.redView];
}

@end
