//
//  HT_Root_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_Root_ViewController.h"

#import "HT_Search_ViewController.h"

#import "HT_Genres_ViewController.h"

#import "HT_Player_ViewController.h"

#import "TT_Synced_ViewController.h"

#import "HT_Feed_ViewController.h"

#import "HT_More_ViewController.h"

#import <StoreKit/StoreKit.h>

@interface HT_Root_ViewController ()<SKStoreProductViewControllerDelegate>
{
    UIView * banner;
    
    BOOL isHidden;
}
@end

@implementation HT_Root_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTabBar];
}

- (void)initTabBar
{
    HT_Genres_ViewController * first = [HT_Genres_ViewController new];
    
    UINavigationController *nav1 = [[UINavigationController alloc]
                                    initWithRootViewController:first];
    first.title = @"Genres";
    
    nav1.tabBarItem.image = [UIImage imageNamed:@"genres"];
    
    HT_Search_ViewController * second = [HT_Search_ViewController new];
    
    second.title = @"Find";
    
    UINavigationController *nav2 = [[UINavigationController alloc]
                                    initWithRootViewController:second];
    
    nav2.tabBarItem.image = [UIImage imageNamed:@"search"];

    TT_Synced_ViewController * third = [TT_Synced_ViewController new];
    
    third.title = @"Playlist";
    
    UINavigationController *nav3 = [[UINavigationController alloc]
                                    initWithRootViewController:third];
    
    nav3.tabBarItem.image = [UIImage imageNamed:@"ipod-1"];
    

    HT_Feed_ViewController * fourth = [HT_Feed_ViewController new];
    
    fourth.title = @"New Feed";
    
    UINavigationController *nav4 = [[UINavigationController alloc]
                                    initWithRootViewController:fourth];
    
    nav4.tabBarItem.image = [UIImage imageNamed:@"albums"];
    
    
    HT_More_ViewController * fifth = [HT_More_ViewController new];
    
    fifth.title = @"Extras";
    
    UINavigationController *nav5 = [[UINavigationController alloc]
                                    initWithRootViewController:fifth];
    
    nav5.tabBarItem.image = [UIImage imageNamed:@"extras"];
    
    self.viewControllers = @[nav1, nav2, nav4, nav3, nav5];
    
    
    
    
    for(UITabBarItem * button in self.tabBar.items)
    {
        [button setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Helvetica" size:8.5], NSFontAttributeName, nil]
                              forState:UIControlStateNormal];
    }
    
    UIView * line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1, 1)];
    line.backgroundColor = [UIColor redColor];
    [self.tabBar addSubview: line];
}

- (void)reAdsAdd
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        CGRect rect = self.tabBar.frame;
        
        rect.origin.y = screenHeight1 - 50;
        
        self.tabBar.frame = rect;
        
    } completion:^(BOOL finished) {
        
        if([self isEmbed])
        {
            [[self ROOT] embed];
        }
        
        [banner removeFromSuperview];
        
    }];
}

- (void)didShowBanner
{
    if(![[LTRequest sharedInstance] isConnectionAvailable])
    {
        return;
    }
    
}

- (NSDictionary*)returnDictionary:(NSDictionary*)dict
{
    NSMutableDictionary * result = [NSMutableDictionary new];
    
    for(NSDictionary * key in dict[@"plist"][@"dict"][@"key"])
    {
        result[key[@"jacknode"]] = dict[@"plist"][@"dict"][@"string"][[dict[@"plist"][@"dict"][@"key"] indexOfObject:key]][@"jacknode"];
    }
    
    return result;
}

- (void)didRequestInfo
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":@"https://dl.dropboxusercontent.com/s/oc2v05ni2c1mvdo/HearItAgain.plist",@"overrideError":@(1)} withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString* errorCode, NSError *error, BOOL isValidated, NSDictionary * object) {
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError * er = nil;
        NSDictionary * dict = [self returnDictionary: [XMLReader dictionaryForXMLData:data
                                                                              options:XMLReaderOptionsProcessNamespaces
                                                                                error:&er]];
        if(dict.allKeys.count != 0)
        {
            [self addObject:@{@"banner":dict[@"banner"],@"fullBanner":dict[@"fullBanner"],@"adsMob":dict[@"ads"],@"itune":dict[@"itune"],@"alert":[dict responseForKey:@"alert"] ? dict[@"alert"] : @""} andKey:@"adsInfo"];
            
            if([dict responseForKey:@"alert"] && ((NSString*)dict[@"alert"]).length != 0)
            {
                if(![self getValue:dict[@"key"]])
                {
                    [self addValue:dict[@"alert"] andKey:dict[@"key"]];
                    
                    [[[EM_MenuView alloc] initWithSubMenu:@{@"message":dict[@"alert"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
                        
                        [menu close];
                        
                        [self openStoreProductViewControllerWithITunesItemIdentifier:1073174100];
                        
                    }];
                }
            }
            
            if([dict responseForKey:@"direct"] && ((NSString*)dict[@"direct"]).length != 0)
            {
                if(![self getValue:dict[@"directKey"]])
                {
                    [self addValue:dict[@"directKey"] andKey:dict[@"directKey"]];
                    
                    [[[EM_MenuView alloc] initWithWebView:@{@"url":dict[@"direct"]}] show];
                }
            }
        }
        
        BOOL isUpdate = data ? [dict[@"version"] compare:[self appInfor][@"majorVersion"] options:NSNumericSearch] == NSOrderedDescending : NO;
        
        if(isUpdate)
        {
            [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Close",@"buttons":@[@"Download now"],@"title":@"New Update",@"message":dict[@"update_message"]} andCompletion:^(int indexButton, id object) {
                switch (indexButton)
                {
                    case 0:
                    {
                        if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:dict[@"url"]]])
                        {
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dict[@"url"]]];
                        }
                    }
                        break;
                    case 1:
                        
                        break;
                    default:
                        break;
                }
            }];
        }
    }];
}

#define kCOLOR_NON_WHITE_COLOR [UIColor blueColor]

- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier
{
    [self showSVHUD:@"Loading" andOption:0];
    
    if(SYSTEM_VERSION_GREATER_THAN(@"7"))
    {
        [UINavigationBar appearance].tintColor = [AVHexColor colorWithHexString:kColor];
    }
    
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
    UIViewController *viewController = self;
    
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error)
     {
         [self hideSVHUD];
         if (result)
             [viewController presentViewController:storeViewController
                                          animated:YES
                                        completion:nil];
     }];
    
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
//
//    // bail if the current state matches the desired state
////    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
//
//    if (isHidden) {
//        return (completion)? completion(YES) : nil;
//    }
//
////    [self tabBarIsVisible];
//
//    // get a frame calculation ready
//    CGRect frame = self.tabBar.frame;
//    CGFloat height = frame.size.height;
//    CGFloat offsetY = height;
//
//    // zero duration means no animation
//    CGFloat duration = (animated)? 0.3 : 0.0;
//
//    [UIView animateWithDuration:duration animations:^{
//        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
//    } completion:completion];
//}
//
//- (void)setTabBarInVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
//
//    // bail if the current state matches the desired state
////    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;
//
//    if (!isHidden) {
//        return (completion)? completion(YES) : nil;
//    }
//
////    [self tabBarIsVisible];
//
//    // get a frame calculation ready
//    CGRect frame = self.tabBar.frame;
//    CGFloat height = frame.size.height;
//    CGFloat offsetY = -height;
//
//    // zero duration means no animation
//    CGFloat duration = (animated)? 0.3 : 0.0;
//
//    [UIView animateWithDuration:duration animations:^{
//        self.tabBar.frame = CGRectOffset(frame, 0, offsetY);
//    } completion:completion];
//}
//
//- (BOOL)tabBarIsVisible {
//    if (self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)) {
//        isHidden = NO;
//    } else {
//        isHidden = YES;
//    }
//    return self.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
//}
//
//- (void)didHideTabbar {
//    [self setTabBarVisible:YES animated:YES completion:^(BOOL finished) {
//        NSLog(@"hide");
//        isHidden = YES;
//    }];
//}
//
//- (void)didShowTabbar {
//    [self setTabBarInVisible:NO animated:YES completion:^(BOOL finished) {
//        NSLog(@"show");
//        isHidden = NO;
//    }];
//}

@end
