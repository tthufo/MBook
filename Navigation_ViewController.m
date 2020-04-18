//
//  Navigation_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 4/2/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import "Navigation_ViewController.h"

#import "HT_Player_ViewController.h"

@interface Navigation_ViewController ()<UIGestureRecognizerDelegate>

@end

@implementation Navigation_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    HT_Player_ViewController * player = [HT_Player_ViewController new];
    
    [self addChildViewController:player];
    
    player.view.frame = CGRectMake(0, screenHeight1 - 0 , screenWidth1, 65);

    [self.view addSubview:player.view];

    [player didMoveToParentViewController:self];
    
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([[self.viewControllers lastObject] isKindOfClass:[HT_Root_ViewController class]] || [self isFullEmbed]) {
        [[self ROOT] toggleLeftPanel:nil];
        return NO;
    }
    return YES;
}

@end
