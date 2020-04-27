//
//  HT_Player_ViewController.h
//  HearThis
//
//  Created by Thanh Hai Tran on 10/6/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GUIPlayerView.h"

typedef enum __playerState
{
    Normal,
    PlayList,
    Local,
    Recent,
    Search,
    Ipod,
    Pause,
}PlayingState;

@interface HT_Player_ViewController : UIViewController

@property(nonatomic, retain) IBOutlet UICollectionView * collectionView;

@property(nonatomic, retain) GUIPlayerView * playerView;

@property(nonatomic, retain) IBOutlet UIView * topView, * controlView, * controlViewIpad;

@property(nonatomic) PlayingState playState;

@property (strong, nonatomic) NSString *uID;

- (void)didStartPlayWith:(NSString*)vID andInfo:(NSDictionary*)info;

- (void)initAvatar:(NSString*)url;

- (void)updateList:(id)item;

- (void)updateAll:(NSString*)playList;

- (NSDictionary*)playerInfo;

- (IBAction)playNext;

- (IBAction)playPrevious;

- (void)backToTop;

@end
