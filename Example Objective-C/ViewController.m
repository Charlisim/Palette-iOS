//
//  ViewController.m
//  Example Objective-C
//
//  Created by Carlos Simon Villas on 17/07/15.
//  Copyright (c) 2015 Charlisim. All rights reserved.
//

#import "ViewController.h"
@import Palette;
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 200, 200)];
    label.text = @"Test text";
    Palette * palette = [[Palette alloc] initWithBackground:self.view forView:label];
    label.textColor =  [palette getContrastingColor];
    label.textColor = [Palette getContrastingColor:self.view forView:label];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

@end
