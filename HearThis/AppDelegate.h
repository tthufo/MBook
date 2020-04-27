//
//  AppDelegate.h
//  HearThis
//
//  Created by Thanh Hai Tran on 10/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HT_Root_ViewController.h"

#import "HT_Player_ViewController.h"

#import "TT_Panel_ViewController.h"

#import "ViewPagerController.h"

#import "TT_Synced_ViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)changeRoot:(BOOL)logOut;

@end

@interface UIImageView (shadow)

- (void)roundCornerswithRadius:(float)cornerRadius andShadowOffset:(float)shadowOffset;

@end

@interface NSObject (ext)

- (NSDictionary*)ipodItem:(MPMediaItem*)item;

@end

@interface ViewPagerController (external)

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index;

@end

@interface UIViewController (root)

- (UIWindow*)WINDOW;

- (TT_Panel_ViewController*)ROOT;

- (UIViewController*)LAST;

- (HT_Player_ViewController*)PLAYER;

- (void)didSuperEmbed;

- (void)didSubEmbed;

- (void)embed;

- (void)didEmbed;

- (void)didEmbed:(UIViewController*)controller;

- (void)didUnEmbed;

- (void)goUp;

- (void)goDown;

- (void)unEmbed;

- (HT_Root_ViewController*)TABBAR;

- (UINavigationController*)CENTER;

- (UIViewController*)TOPVIEWCONTROLER;

- (BOOL)hasAds;

- (BOOL)isEmbed;

- (BOOL)isFullEmbed;

- (BOOL)activeState;

- (BOOL)isReader;

- (BOOL)isParallax;

- (CGFloat)returnSizing:(NSAttributedString*)labelString;

- (CGFloat)returnSize:(NSString*)des;

//- (void)startPlayingIpod:(NSURL*)url andInfo:(NSDictionary*)info;
//
//- (void)startPlayingLocal:(NSString*)url andInfo:(NSDictionary*)info;
//
- (void)startPlaying:(NSString*)vID andInfo:(NSDictionary*)info;

//- (void)startPlayList:(NSString*)name andVid:(NSString*)vId andInfo:(NSDictionary*)info;

- (NSString *)pathFile;

- (NSString*)connectionType;

- (void)addHistory:(NSString*)history;

- (void)removeHistory;

- (NSArray*)getHistory;

@end

