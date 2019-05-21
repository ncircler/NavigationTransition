//
//  ViewController2.m
//  Demo
//
//  Created by iOSer on 2019/5/17.
//  Copyright © 2019 Some one. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"%@", @(self.navigationController.viewControllers.count)];
}

@end
