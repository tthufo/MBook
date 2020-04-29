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

#import "MeBook-Swift.h"

#define h 65

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    [[LTRequest sharedInstance] initRequest];
    
    [[LTRequest sharedInstance] initRequestWithWatch:^(NSDictionary *response) {
        if ([response responseForKey:@"error_code"] && [[response getValueFromKey:@"error_code"] isEqualToString:@"-1"]) {
            if ([self.window.rootViewController isEmbed]) {
                [self.window.rootViewController unEmbed];
            }
//            [Information removeInfo];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self changeRoot:YES];
            });
        }
    }];
    
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
    
//    [[DownloadManager share] loadSort];
    
//    if([[self getValue:@"ipod"] boolValue])
//    {
//        [[DownloadManager share] mergeIpod];
//    }
//    else
//    {
//        [[DownloadManager share] unmergeIpod];
//    }
    
    
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
    
    

    
    self.window.rootViewController = [self authenticationViewController: @"logIn"];
    
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

- (UINavigationController *)authenticationViewController:(NSString* )logOut {
    PC_Login_ViewController * login = [PC_Login_ViewController new];
    
    login.logOut = logOut;
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController: login];
    
    nav.navigationBarHidden = YES;
    
    return nav;
}

- (void)changeRoot:(BOOL)logOut {
    if (!logOut) {
        [[self window] setRootViewController:[self rootViewController]];
    } else {
        [[self window] setRootViewController:[self authenticationViewController: @"logOut"]];
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

- (void)didSuperEmbed
{
    BOOL isMotion = [[self TOPVIEWCONTROLER] isKindOfClass:[UITabBarController class]];
        
    int embed = [[self getValue:@"embed"] intValue];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3 animations:^{
    
        CGRect rect = [self PLAYER].view.frame;
                
        rect.origin.y = screenHeight1 - (isMotion ? 115 : 65) - ( IS_IPAD ? 1 : [self isIphoneX] ? 35 : 0) - embed;
        
        rect.size.height = h;

        [self PLAYER].view.frame = rect;
        
        [[self PLAYER].view withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)didEmbed:(UIViewController*)controller
{
    int embed = [[self getValue:@"embed"] intValue];
    
    for(UIView * v in controller.view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(((UICollectionView*)v).contentInset.top, 0, ([self isEmbed] ? (((UICollectionView*)v).contentInset.bottom == 0 ? h : ((UICollectionView*)v).contentInset.bottom) : ((UICollectionView*)v).contentInset.bottom == h ? 0 : ((UICollectionView*)v).contentInset.bottom) + (((UICollectionView*)v).contentInset.bottom == 0 ? embed : 0), 0);
        }
        
        if([v isKindOfClass:[UIView class]])
        {
            for(UIView * innerView in v.subviews)
            {
                if([innerView isKindOfClass:[UITableView class]])
                {
                    ((UITableView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UICollectionView class]])
                {
                    ((UICollectionView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UITextView class]])
                {
                    ((UITextView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h - 15 : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UIView class]])
                {
                    for(UIView * childInner in v.subviews)
                    {
                        if([childInner isKindOfClass:[UITableView class]])
                        {
                            ((UITableView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                        
                        if([childInner isKindOfClass:[UICollectionView class]])
                        {
                            ((UICollectionView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                    }
                }
            }
        }
    }
}

- (void)didEmbed
{
    int embed = [[self getValue:@"embed"] intValue];
    
    for(UIView * v in [self LAST].view.subviews)
    {
        if([v isKindOfClass:[UITableView class]])
        {
            ((UITableView*)v).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
        }
        
        if([v isKindOfClass:[UICollectionView class]])
        {
            ((UICollectionView*)v).contentInset = UIEdgeInsetsMake(((UICollectionView*)v).contentInset.top, 0, ([self isEmbed] ? (((UICollectionView*)v).contentInset.bottom == 0 ? h : ((UICollectionView*)v).contentInset.bottom) : ((UICollectionView*)v).contentInset.bottom == h ? 0 : ((UICollectionView*)v).contentInset.bottom) + (((UICollectionView*)v).contentInset.bottom == 0 ? embed : 0), 0);
        }
                
        if([v isKindOfClass:[UIView class]])
        {
            for(UIView * innerView in v.subviews)
            {
                if([innerView isKindOfClass:[UITableView class]])
                {
                    ((UITableView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UICollectionView class]])
                {
                    ((UICollectionView*)innerView).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                }
                
                if([innerView isKindOfClass:[UIView class]])
                {
                    for(UIView * childInner in v.subviews)
                    {
                        if([childInner isKindOfClass:[UITableView class]])
                        {
                            ((UITableView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                        
                        if([childInner isKindOfClass:[UICollectionView class]])
                        {
                            ((UICollectionView*)childInner).contentInset = UIEdgeInsetsMake(0, 0, ([self isEmbed] ? h : 0) + embed, 0);
                        }
                    }
                }
            }
        }
    }
}

- (void)embed
{
    [self PLAYER].topView.alpha = 1;
    
    int embed = [[self getValue:@"embed"] intValue];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [self PLAYER].view.frame;
        
        rect.origin.y = screenHeight1 - ([[self TOPVIEWCONTROLER] isKindOfClass:[UITabBarController class]] ? 115 : 65) - ([self isIphoneX] ? 35 : 0) - embed - 1;
        
        [self PLAYER].view.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [self didEmbed];
        
    }];
}

- (void)didSubEmbed
{
    BOOL isMotion = [[self TOPVIEWCONTROLER] isKindOfClass:[Reader_ViewController class]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = [self PLAYER].view.frame;
        
        rect.origin.y = screenHeight1; //- h - (isMotion ? 0 : 0);
        
        rect.size.height = h;
        
        [self PLAYER].view.frame = rect;
        
        [[self PLAYER].view withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        [[self PLAYER].playerView pause];
        [self PLAYER].playState = Pause;
    }];
}

- (void)unEmbed
{
    [self PLAYER].topView.alpha = 1;
    
    int embed = [[self getValue:@"embed"] intValue];
    
    if([self activeState])
    {
        [[self PLAYER].playerView stop];
        
        [[self PLAYER].playerView clean];
        
        [self PLAYER].playerView = nil;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = [self PLAYER].view.frame;
        
        rect.origin.y = screenHeight1 - embed;
        
        [self PLAYER].view.frame = rect;
        
        [[self PLAYER].view withBorder:@{@"Bcorner":@(0)}];
        
    } completion:^(BOOL finished) {
        
        if([self isParallax]) {
            [self didEmbed];
            
            [self didEmbed:[self TOPVIEWCONTROLER]];
            
            if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
            {
                [self didEmbed:[((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]]];
            }
        }

        [self PLAYER].playState = Normal;
        
    }];
}

- (void)didUnEmbed //no use
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
                
        int topPoint = IS_IPAD ? 20 : [self isIphoneX] ? 40 : 20;
        
        CGRect rect = [self PLAYER].view.frame;
        
        rect.origin.y = topPoint;
        
        rect.origin.x = IS_IPAD ? 0 : 0;
        
        rect.size.width = screenWidth1 - (IS_IPAD ? 0 : 0);
        
        rect.size.height = screenHeight1 - topPoint;
        
        [self PLAYER].view.backgroundColor = [UIColor whiteColor];

        [self PLAYER].view.frame = rect;

        [[self PLAYER].view withBorder:@{@"Bcorner":@(0)}];
        
        [self PLAYER].topView.alpha = 0;
        
        [self PLAYER].controlView.alpha = 1;
             
        [self PLAYER].controlViewIpad.alpha = 1;
        
        for (UIView * v in  [self PLAYER].controlViewIpad.subviews) {
//            v.alpha = v.tag == 1010101 ? 0.6 : 1;
            if (v.tag == 10001) {
                v.hidden = YES;
            }
            v.hidden = NO;
        }
        
        for (UIView * v in  [self PLAYER].controlView.subviews) {
//            if (v.tag != 9988 || v.tag != 9989) {
//                v.alpha = v.tag == 1010101 ? 0.6 : 1;
            if (v.tag == 10001) {
                v.hidden = YES;
            }
            v.hidden = NO;
//            }
        }
        
        ((UIImageView*)[[self PLAYER] playerInfo][@"img"]).hidden = NO;
        
        ((UICollectionView*)[self PLAYER].collectionView).hidden = NO;
        
    } completion:^(BOOL finished) {
        
        if([self isParallax]) {
            [self didEmbed];
            [self didEmbed:[self TOPVIEWCONTROLER]];
            
            if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
            {
                [self didEmbed:[((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]]];
            }
        }
    }];
}

- (void)goDown
{
    int embed = [[self getValue:@"embed"] intValue];
            
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                
        int topPoint = IS_IPAD ? 20 : [self isIphoneX] ? 40 : 20;

        CGRect rect = [self PLAYER].view.frame;

        rect.origin.y = screenHeight1 - ([[self TOPVIEWCONTROLER] isKindOfClass:[UITabBarController class]] ? 115 : 65) - ( IS_IPAD ? 1 : [self isIphoneX] ? 35 : 0) - embed;

        rect.origin.x = IS_IPAD ? 150 : 0;
             
        rect.size.width = screenWidth1 - (IS_IPAD ? 300 : 0);
        
        rect.size.height = screenHeight1 - topPoint;

        rect.size.height = 65;
        
        [self PLAYER].view.backgroundColor = [UIColor clearColor];

        [self PLAYER].view.frame = rect;
        
        [[self PLAYER].view withBorder:@{@"Bcorner":@(0)}];
        
        [self PLAYER].topView.alpha = 1;
        
        [self PLAYER].controlView.alpha = 0;
        
        [self PLAYER].controlViewIpad.alpha = 0;
        
        for (UIView * v in  [self PLAYER].controlViewIpad.subviews) {
//            v.alpha = 0;
            if (v.tag == 10001) {
                v.hidden = YES;
            }
            v.hidden = YES;
        }
        
        for (UIView * v in  [self PLAYER].controlView.subviews) {
//            if (v.tag != 9988 || v.tag != 9989) {
//                v.alpha = 0;
            if (v.tag == 10001) {
                v.hidden = YES;
            }
            v.hidden = YES;
//            }
        }
        
        ((UIImageView*)[[self PLAYER] playerInfo][@"img"]).hidden = YES;
        
        ((UICollectionView*)[self PLAYER].collectionView).hidden = YES;

    } completion:^(BOOL finished) {
        
//        id controller = [((UINavigationController*)[self TABBAR].selectedViewController).viewControllers lastObject];
//        
//        if([controller isKindOfClass:[TT_Synced_ViewController class]])
//        {
//            [(TT_Synced_ViewController*)controller didReloadData];
//        }
        if([[[self LAST] classForCoder] isSubclassOfClass:[ViewPagerController class]])
        {
            [self didEmbed:[((ViewPagerController*)[self LAST]) viewControllerAtIndex:[((ViewPagerController*)[self LAST]).indexSelected intValue]]];
        }
    }];
}

- (CGFloat)returnSizing:(NSAttributedString*)labelString  {
//    NSAttributedString* labelString = [[NSAttributedString alloc] initWithString:des attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
           CGRect cellRect = [labelString boundingRectWithSize:CGSizeMake(screenWidth1 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return cellRect.size.height;
}


- (CGFloat)returnSize:(NSString*)des  {
    NSAttributedString* labelString = [[NSAttributedString alloc] initWithString:des attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0]}];
           CGRect cellRect = [labelString boundingRectWithSize:CGSizeMake(screenWidth1 - 20, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return cellRect.size.height;
}

- (void)addHistory:(NSString*)history {
    NSMutableArray * hisTag = [[NSMutableArray alloc] initWithArray:[self getHistory]];
    
    if (![hisTag containsObject: history] ) {
        [hisTag addObject:history];
    }
    
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

- (BOOL)isFullEmbed
{
    int point = IS_IPAD ? 20 : [self isIphoneX] ? 40 : 20;
    return [self PLAYER].view.frame.origin.y == point;
}

- (BOOL)isEmbed
{
    return [self PLAYER].view.frame.origin.y < screenHeight1;
}

- (BOOL)activeState
{
    return [[self PLAYER].playerView isPlaying];
}

- (BOOL)isReader
{
    return [self isKindOfClass:[Reader_ViewController class]];
}

- (BOOL)isParallax
{
    return YES;
//    ![self isKindOfClass:[HT_Player_ViewController class]];
//    &&
//    ![self isKindOfClass:[Author_Detail_ViewController class]];
//    && ![self isKindOfClass:[Event_Detail_ViewController class]];
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
    
    if ([self isFullEmbed] || [info responseForKey:@"byPass"]) {
        return;
    }
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

@implementation ViewPagerController (external)


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
