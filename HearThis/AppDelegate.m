//
//  AppDelegate.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "AppDelegate.h"

#import "SC_Menu_ViewController.h"

#import "Navigation_ViewController.h"

#import "HT_Detail_ViewController.h"

#import "Reachability.h"

#import "HearThis-Swift.h"

@interface AppDelegate ()
{
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[LTRequest sharedInstance] initRequest];
    
    [[FirePush shareInstance] didRegister];
    
    [Information saveToken];
    
    [Information saveInfo];
    
    if(![self getValue:@"ipod"])
    {
        [self addValue:@"0" andKey:@"ipod"];
    }
    
    if(![self getObject:@"historyTag"])
    {
        [self addObject:@{@"history": @[]} andKey:@"historyTag"];
    }
    
    [[DownloadManager share] loadSort];
    
    
    if([[self getValue:@"ipod"] boolValue])
    {
        [[DownloadManager share] mergeIpod];
    }
    else
    {
        [[DownloadManager share] unmergeIpod];
    }
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDarkContent];
    
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)])
    {
        [UINavigationBar appearance].tintColor = [AVHexColor colorWithHexString:@"#FFFFFF"];
    }
    
    [[UITabBar appearance] setSelectedImageTintColor:[AVHexColor colorWithHexString:kColor]];
    
    
    UIImageView * view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    
    [view withBorder:@{@"Bcorner":@(4)}];
    
    view.backgroundColor = [AVHexColor colorWithHexString:kColor];
    
    view.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    
    [self.window addSubview:view];
    
    

    
    self.window.rootViewController = [self authenticationViewController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (TT_Panel_ViewController *)rootViewController {
    
    TT_Panel_ViewController * panel = [TT_Panel_ViewController new];
    
    panel.leftFixedWidth = [self screenWidth] * (IS_IPAD ? 0.4 : 0.8);
    
    Navigation_ViewController * nav = [[Navigation_ViewController alloc] initWithRootViewController: [HT_Root_ViewController new]];
    
    nav.navigationBarHidden = YES;
    
    panel.centerPanel = nav;
        
    panel.leftPanel = [TG_Intro_ViewController new];//[SC_Menu_ViewController new];

    return panel;
}

- (UINavigationController *)authenticationViewController {
        
    Navigation_ViewController * nav = [[Navigation_ViewController alloc] initWithRootViewController: [PC_Login_ViewController new]];
    
    nav.navigationBarHidden = YES;
    
    return nav;
}

- (void)changeRoot:(BOOL)logOut {
    if (!logOut) {
        [[self window] setRootViewController:[self rootViewController]];
    } else {
        [[self window] setRootViewController:[self authenticationViewController]];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

UIBackgroundTaskIdentifier bgTask;

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[FirePush shareInstance] disconnectToFcm];
    
    bgTask = [[UIApplication  sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    if (bgTask == UIBackgroundTaskInvalid)
    {
        //        NSLog(@"This application does not support background mode");
    }
    else
    {
        //        NSLog(@"Application will continue to run in background");
    }
    
    [[LTRequest sharedInstance] didClearBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication] endBackgroundTask:UIBackgroundTaskInvalid];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[FirePush shareInstance] connectToFcm];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    for(DownLoad * down in [DownloadManager share].dataList)
    {
        if(!down.operationFinished && !down.operationBreaked)
        {
            [down forceStop];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[FirePush shareInstance] didReiciveToken:deviceToken withType:0];
}

@end

@implementation NSObject (ext)

- (NSDictionary*)ipodItem:(MPMediaItem*)item
{
    return @{@"assetUrl":[[item valueForProperty:MPMediaItemPropertyAssetURL] absoluteString],
             @"duration":[item valueForProperty:MPMediaItemPropertyPlaybackDuration],
             @"title":[item valueForProperty:MPMediaItemPropertyTitle] ? [item valueForProperty:MPMediaItemPropertyTitle] : @"No Title",
             @"description":[item valueForProperty:MPMediaItemPropertyAlbumTitle] ? [item valueForProperty:MPMediaItemPropertyAlbumTitle] : @"No Description",
             @"img":[UIImage imageNamed:@"ipod"],
             @"id":@((int)(MPMediaEntityPersistentID)[item valueForProperty:MPMediaItemPropertyPersistentID]),
             @"ipod":@(1)
             };
}

@end

@implementation UIViewController (root)

- (UIWindow*)WINDOW
{
    return APPDELEGATE.window;
}

- (TT_Panel_ViewController*)ROOT
{
    return ((TT_Panel_ViewController*)[self WINDOW].rootViewController);
}

- (HT_Root_ViewController*)TABBAR
{
    return (HT_Root_ViewController*)((UINavigationController*)[self ROOT].centerPanel).viewControllers[1];
}

- (UINavigationController*)CENTER
{
    return (UINavigationController*)[self ROOT].centerPanel;
}

- (UIViewController*)TOPVIEWCONTROLER
{
    return [((UINavigationController*)[self ROOT].centerPanel).viewControllers lastObject];
}


- (UIViewController*)LAST
{
    return [((UINavigationController*)[self TABBAR].selectedViewController).viewControllers lastObject];
}

- (HT_Player_ViewController*)PLAYER
{
    HT_Player_ViewController * controller = (HT_Player_ViewController*)[[self CENTER].childViewControllers firstObject];
    
    return controller;
}

- (void)didEmbed
{
    int embed = [[self getValue:@"embed"] intValue];

    for(UIView * v in [self LAST].view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? 107 : [self hasAds] ? 52 : v.tag == 8989 ? 54 : 54) + embed, 0);
        }
            
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? 107 : [self hasAds] ? 52 : 54) + embed, 0);
        }
        
            if([v isKindOfClass:[UIButton class]] && v.tag == 99881)
            {
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    v.frame = CGRectMake(0, screenHeight1 - 175 - embed, 50, 50);
                    
                }];
                
                break;
            }
    }
}

- (void)didUnEmbed
{
    if (![self isEmbed]) {
        return;
    }
    int embed = 0;// [[self getValue:@"embed"] intValue];

    for(UIView * v in [self LAST].view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? 107 : [self hasAds] ? 52 : v.tag == 8989 ? 54 : 54) + embed, 0);
        }
            
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? 107 : [self hasAds] ? 52 : 54) + embed, 0);
        }
        
            if([v isKindOfClass:[UIButton class]] && v.tag == 99881)
            {
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    v.frame = CGRectMake(0, screenHeight1 - 175 - embed, 50, 50);
                    
                }];
                
                break;
            }
    }
}

- (void)goUp
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;
        
        rect.origin.y = 0;//25;
        
        rect.size.height = screenHeight1 - 0;//15;
        
        [self PLAYER].view.backgroundColor = [UIColor whiteColor];

        [self PLAYER].view.frame = rect;

        [[self PLAYER].view withBorder:@{@"Bcorner":@(6)}];
        
        [self PLAYER].topView.alpha = 0;
        
        ((UIImageView*)[[self PLAYER] playerInfo][@"img"]).hidden = NO;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)goDown
{
    int embed = [[self getValue:@"embed"] intValue];
            
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
        CGRect rect = [[self CENTER].view.subviews lastObject].frame;

        rect.origin.y = screenHeight1 - ([[self TOPVIEWCONTROLER] isKindOfClass:[UITabBarController class]] ? 115 : 65) - ([self isIphoneX] ? 35 : 0) - embed;

        rect.size.height = 65;
        
        [self PLAYER].view.backgroundColor = [UIColor clearColor];

        [self PLAYER].view.frame = rect;
        
        [[self PLAYER].view withBorder:@{@"Bcorner":@(3)}];
        
        [self PLAYER].topView.alpha = 1;
        
        ((UIImageView*)[[self PLAYER] playerInfo][@"img"]).hidden = NO;
        
    } completion:^(BOOL finished) {
        
//        id controller = [((UINavigationController*)[self TABBAR].selectedViewController).viewControllers lastObject];
//        
//        if([controller isKindOfClass:[TT_Synced_ViewController class]])
//        {
//            [(TT_Synced_ViewController*)controller didReloadData];
//        }
            
    }];
}

- (void)addHistory:(NSString*)history {
    NSMutableArray * hisTag = [[NSMutableArray alloc] initWithArray:[self getHistory]];
    
    [hisTag addObject:history];
    
    [self addObject:@{@"history": hisTag} andKey:@"historyTag"];
}

- (void)removeHistory {
    [self addObject:@{@"history": @[]} andKey:@"historyTag"];
}

- (NSArray*)getHistory {
    return [self getObject:@"historyTag"][@"history"];
}

- (BOOL)hasAds
{
    return ![[[self CENTER].view.subviews lastObject] isKindOfClass:[UITabBar class]];
}

- (BOOL)isEmbed
{
    return [self PLAYER].view.frame.origin.y < screenHeight1;
}

- (BOOL)activeState
{
    return [[self PLAYER].playerView isPlaying];
}

//- (void)startPlayingIpod:(NSURL*)url andInfo:(NSDictionary*)info
//{
//    [[self PLAYER] didStartPlayWithIpod:url andInfo:info];
//    
//    [[self ROOT] embed];
//}
//
//- (void)startPlayingLocal:(NSString*)url andInfo:(NSDictionary*)info
//{
//    [[self PLAYER] didStartPlayWithLocal:url andInfo:info];
//    
//    [[self ROOT] embed];
//}
//
- (void)startPlaying:(NSString*)vID andInfo:(NSDictionary*)info
{
    [[self PLAYER] didStartPlayWith:vID andInfo:info];
    
    [[self ROOT] goUp];
}
//
//- (void)startPlayList:(NSString*)name andVid:(NSString*)vId andInfo:(NSDictionary*)info
//{
//    [[self PLAYER] didStartPlayList:name andVid:vId andInfo:info];
//    
//    [[self ROOT] embed];
//}

- (NSString *)pathFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *yourArtPath = [documentsDirectory stringByAppendingPathComponent:@"/video"];
    
    return  yourArtPath;
}

- (NSString*)connectionType {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];

    NetworkStatus status = [reachability currentReachabilityStatus];

    if(status == NotReachable)
    {
        return @"";
    }
    else if (status == ReachableViaWiFi)
    {
        return @"WIFI";
    }
    else if (status == ReachableViaWWAN)
    {
        return @"3G";
    }
    
    return @"";
}

@end


@implementation UIImageView (shadow)

- (void)roundCornerswithRadius:(float)cornerRadius andShadowOffset:(float)shadowOffset
{
    const float CORNER_RADIUS = cornerRadius;
    const float SHADOW_OFFSET = shadowOffset;
    const float SHADOW_OPACITY = 0.5;
    const float SHADOW_RADIUS = 3.0;
    
    UIView *superView = self.superview;
    
    CGRect oldBackgroundFrame = self.frame;
    [self removeFromSuperview];
    
    CGRect frameForShadowView = CGRectMake(0, 0, oldBackgroundFrame.size.width, oldBackgroundFrame.size.height);
    UIView *shadowView = [[UIView alloc] initWithFrame:frameForShadowView];
    [shadowView.layer setShadowOpacity:SHADOW_OPACITY];
    [shadowView.layer setShadowRadius:SHADOW_RADIUS];
    [shadowView.layer setShadowOffset:CGSizeMake(SHADOW_OFFSET, SHADOW_OFFSET)];
    
    [self.layer setCornerRadius:CORNER_RADIUS];
    [self.layer setMasksToBounds:YES];
    
    [shadowView addSubview:self];
    [superView addSubview:shadowView];
    
}

@end
