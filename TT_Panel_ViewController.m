//
//  M_Panel_ViewController.m
//  ProTube
//
//  Created by thanhhaitran on 8/4/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "TT_Panel_ViewController.h"

#import "HT_Player_ViewController.h"

@interface TT_Panel_ViewController ()
{
    
}

@end

@implementation TT_Panel_ViewController

//- (void)show
//{
//    [self PLAYER].topView.alpha = 0;
//    
//    [self PLAYER].adsView.alpha = 0;
//
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//        CGRect rect = [self.centerPanel.view.subviews lastObject].frame;
//        
//        rect.origin.y = 0;
//        
//        [self.centerPanel.view.subviews lastObject].frame = rect;
//        
//    } completion:^(BOOL finished) {
//        
//    }];
//}
//

//- (void)embed
//{
//    [self PLAYER].topView.alpha = 1;
//    
//    int embed = [[self getValue:@"embed"] intValue];
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//        CGRect rect = [self PLAYER].view.frame;
//        
//        rect.origin.y = screenHeight1 - ([[self TOPVIEWCONTROLER] isKindOfClass:[UITabBarController class]] ? 115 : 65) - ([self isIphoneX] ? 35 : 0) - embed - 1;
//        
//        [self PLAYER].view.frame = rect;
//        
//    } completion:^(BOOL finished) {
//        
//        [self didEmbed];
//        
//    }];
//}

//- (void)unEmbed
//{
//    [self PLAYER].topView.alpha = 1;
//        
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        
//        CGRect rect = [self PLAYER].view.frame;
//
//        rect.origin.y = screenHeight1;
//        
//        [self PLAYER].view.frame = rect;
//        
//    } completion:^(BOOL finished) {
//        
//        [self didUnEmbed];
//        
//    }];
//}


//- (void)hide
//{
//    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//
//        CGRect rect = [self.centerPanel.view.subviews lastObject].frame;
//
//        rect.origin.y = screenHeight1;
//
//        [self.centerPanel.view.subviews lastObject].frame = rect;
//
//    } completion:^(BOOL finished) {
//
//    }];
//}

- (void)displayContentController:(UIViewController*)content
{
//    NSLog(@"===>%@", [self CENTER]);
//    
//    [[self CENTER] addChildViewController:content];
//    
//    content.view.frame = CGRectMake(0, screenHeight1 - 300 , screenWidth1, 57);
//
//    [[self CENTER].view addSubview:content.view];
//
//    [content didMoveToParentViewController:[self CENTER]];
//    
//    [self.centerPanel.view addSubview:content.view];
//
//    [content didMoveToParentViewController:self.centerPanel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.rightFixedWidth = screenWidth1 * 9 / 16 - 10;
    
//    HT_Player_ViewController * player = [HT_Player_ViewController new];
//    
//    [self displayContentController:player];
    
//    NSLog(@"===>%@", [self CENTER]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [self resignFirstResponder];
}

- (CGRect)_adjustCenterFrame
{
//    [((LT_LeftMenuViewController*)self.leftPanel) performSelector:@selector(didShowAndHideController:) withObject:@{@"move":self.state == 1 ? @"0" : @"1"} afterDelay:0.3];
//    
//    NSString * titleText = ((M_First_ViewController*)[((UINavigationController*)[[self ROOT].childViewControllers firstObject]).viewControllers lastObject]).title;
//    
//    [[self LEFT] reloadData];
    
    return [super _adjustCenterFrame];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    HT_Player_ViewController * controller = [self PLAYER];
    
    if (event.type == UIEventTypeRemoteControl)
    {
        if (event.subtype == UIEventSubtypeRemoteControlPlay)
        {
            [controller.playerView togglePlay:controller.playerView.playButton];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPause)
        {
            [controller.playerView pause];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause)
        {
            
        }
        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
        {
            [controller playNext];
        }
        else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
        {
            [controller playPrevious];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end


@implementation JASidePanelController (extend)


@end
