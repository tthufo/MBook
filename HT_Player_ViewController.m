//
//  HT_Player_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/6/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_Player_ViewController.h"

#import "GUISlider.h"

#import "HT_Player_Item.h"

#import "MeBook-Swift.h"

@import ParallaxHeader;

@import MarqueeLabel;

@interface HT_Player_ViewController ()<GUIPlayerViewDelegate>
{
    IBOutlet MarqueeLabel * titleSong;
            
    IBOutlet UIView * controlView, * controlViewIpad;
    
    IBOutlet NSLayoutConstraint * topHeight, * topHeightIpad;
    
    IBOutlet UIButton * play;
    
    NSMutableArray * dataList, * chapList;
    
    NSMutableDictionary * playingData, * setupData;
    
    IBOutlet UIImageView * avatar;
    
    BOOL isResume, isSound;
    
    NSDictionary * config;
    
    NSString * localUrl, * playListName;
    
    IBOutlet GUISlider * slider;
    
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore;
}

@end

@implementation HT_Player_ViewController

@synthesize playerView, playState, topView, uID, controlView, controlViewIpad, collectionView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dataList = [NSMutableArray new];
    
    chapList = [NSMutableArray new];

    setupData = [@{} mutableCopy];
    
    topHeight.constant = screenWidth1 * 9 / 16;
    
    topHeightIpad.constant = screenWidth1 * 9 / 16;

    if(![self getObject:@"settingOpt"])
    {
        [self addObject:@{@"repeat":@"2", @"shuffle":@"0"} andKey:@"settingOpt"];
    }
    
    playingData = [[NSMutableDictionary alloc] initWithDictionary:[self getObject:@"settingOpt"]];
    
    [self playingState];
    
//    [self previousPlay];
    
    ((UIImageView*)[self playerInfo][@"img"]).hidden = YES;
    
    [self didSetUpCollectionView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       [self parallaxHeader];
    });
}

- (void)didSetUpCollectionView {
    [collectionView withCell:@"TG_Map_Cell"];
    [collectionView withCell:@"TG_Book_Chap_Cell"];
    [collectionView withHeaderOrFooter:@"Book_Detail_Title" andKind: UICollectionElementKindSectionHeader];
}

- (void)parallaxHeader {
    UIView * controller = IS_IPAD ? controlViewIpad : controlView;
    UIView * bg = [self withView:controller tag:1000];
    collectionView.parallaxHeader.view = IS_IPAD ? controlViewIpad : controlView;
    collectionView.parallaxHeader.height = screenWidth1 * 9 / 16;
    collectionView.parallaxHeader.minimumHeight = [self isIphoneX] ? 64 : 64;
    [collectionView.parallaxHeader setParallaxHeaderDidScrollHandler:^(ParallaxHeader * header) {
//        NSLog(@"%f", header.progress);
        for (UIView * v in controller.subviews) {
            if (v.tag != 1000 && v.tag != 1010101) {
                if (v.tag == 9988 || v.tag == 9989 || v.tag == 9990) {
                    v.alpha = 1 - header.progress;
                } else {
                    v.alpha = header.progress;
                }
            }
        }
        bg.alpha = 1 - header.progress;
    }];
}

- (void)adjustInset {
    float headerHeight = screenWidth1 * 9 / 16;
    float embeded = [self isEmbed] ? 0 : 0;
    float contentSizeHeight = collectionView.collectionViewLayout.collectionViewContentSize.height;
    float collectionViewHeight = collectionView.frame.size.height;
    collectionView.contentInset = UIEdgeInsetsMake(headerHeight, 0, contentSizeHeight < (collectionViewHeight - 64) ? (collectionViewHeight - contentSizeHeight - 64 + embeded) : (0 + embeded), 0);
}

- (void)backToTop {
    [collectionView setContentOffset:CGPointMake(0, - screenWidth1 * 9 / 16) animated:YES];
}

- (void)playingState
{
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:playingData];
    
    for(NSString * key in playingData.allKeys)
    {
        if([key isEqualToString:@"shuffle"] || [key isEqualToString:@"repeat"])
        {
            
        }
        else
        {
            [dict removeObjectForKey:key];
        }
    }
    
    [self addObject:dict andKey:@"settingOpt"];
    
//    [(UIButton*)[self playerInfo][@"random"] setImage:![playingData[@"shuffle"] boolValue] ? [UIImage imageNamed:@"shuffle"] : [[UIImage imageNamed:@"shuffle"] tintedImage: kColor] forState:UIControlStateNormal];
    
    [((UIButton*)[self playerInfo][@"repeat"]) setImage:[UIImage imageNamed:[playingData[@"repeat"] isEqualToString:@"2"] ? @"infinity" : [playingData[@"repeat"] isEqualToString:@"1"] ? @"repeat" : @"once"] forState:UIControlStateNormal];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.contentOffset.y < (-65 - (screenWidth1 * 9 / 16)))
    {
        [self didPressDown];
    }
    
//    [(UIButton*)[self playerInfo][@"off"] setImage: scrollView.contentOffset.y >= 0 ? [UIImage imageNamed:@"off"] : [self animate:@[@"down_1",@"down_3",@"down_2",@"down_4"] andDuration:0.8] forState:UIControlStateNormal];
}

- (void)previousPlay
{
    if(![self getObject:@"leftOver"])
    {
        return;
    }
    
    isResume = YES;
    
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[self getObject:@"leftOver"]];
    
//    dict[@"img"] = [self getValue:@"leftImg"];
    
//    avatar.image = [System getValue:@"leftImg"];
    
    playListName = dict[@"playListName"];
    
    localUrl = dict[@"localUrl"];
    
    playState = [dict[@"playingState"] intValue];
    
    BOOL isIpod = [dict responseForKey:@"ipod"];
    
    switch (playState) {
        case Normal:
        case Search:
        {
            [self didStartPlayWith:isIpod ? dict[@"assetUrl"] : [dict getValueFromKey:@"id"] andInfo:dict];
            
//            [self updateList:dict[@"dataList"]];
        }
            break;
        case PlayList:
        {
//            [self didStartPlayList:[dict getValueFromKey:@"playListName"] andVid:[dict getValueFromKey:@"id"] andInfo:dict];
//            
//            [dataList addObjectsFromArray:[Item getFormat:@"name=%@" argument:@[[dict getValueFromKey:@"playListName"]]]];
        }
            break;
        case Local:
        {
//            NSString *contentURL = [dict responseForKey:@"ipod"] ? [dict getValueFromKey:@"localUrl"] : [NSString stringWithFormat:@"%@.mp3", [[[self pathFile] stringByAppendingPathComponent:[dict getValueFromKey:@"localUrl"]] stringByAppendingPathComponent:[dict getValueFromKey:@"localUrl"]]];
//            
//            [self didStartPlayWithLocal:contentURL andInfo:dict];
//            
//            [dataList addObjectsFromArray:[[DownloadManager share] doneDownload]];
        }
            break;
        case Recent:
        {
//            [self didStartPlayWith:[dict getValueFromKey:@"id"] andInfo:dict];
//
//            [dataList addObjectsFromArray:[History getAll]];
        }
            break;
        default:
            break;
    }
    
    uID = isIpod ? dict[@"assetUrl"] : [dict getValueFromKey:@"id"];
    
//    [dataList addObjectsFromArray:[self getValue:@"leftOverList"]];
}

#pragma mark TableView

- (void)updateAll:(NSString*)playList
{
    [dataList removeAllObjects];
    
    for(Item * item in [Item getFormat:@"name=%@" argument:@[playList]])
    {
        NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:item.data];
        
        [dataList addObject:dict];
    }
}

- (void)updateList:(id)item
{
    BOOL isIpod = [item responseForKey:@"ipod"];

    BOOL isDownload = [item responseForKey:@"download"];

    BOOL found = NO;
    
    for(id ite in dataList)
    {
        if([ite responseForKey:@"ipod"] && isIpod)
        {
            if([ite[@"assetUrl"] isEqualToString:item[@"assetUrl"]])
            {
                found = YES;
                
                break;
            }
        }
        
        if([ite responseForKey:@"download"] && isDownload)
        {
            if([[ite getValueFromKey:@"id"] isEqualToString:[item getValueFromKey:@"id"]])
            {
                found = YES;
                
                break;
            }
        }
        else
        {
            if([[ite getValueFromKey:@"id"] isEqualToString:[item getValueFromKey:@"id"]])
            {
                found = YES;
                
                break;
            }
        }
        
    }
    
    if(found)
    {
        [self showToast:@"Song already in Play Now" andPos:0];

        return;
    }
    
    [dataList insertObject:item atIndex:0];
    
//    [System addValue:dataList andKey:@"leftOverList"];
//
//    [self showToast:@"Song added to Play Now" andPos:0];
}

- (void)resortDownload:(id)item andIndex:(int)index
{
    if([item responseForKey:@"download"] || [item responseForKey:@"ipod"])
    {
        return;
    }
    
    int count = [Records getFormat:@"vid=%@" argument:@[[item getValueFromKey:@"id"]]].count;
    
    if(count != 0)
    {
        Records * r = [[Records getFormat:@"vid=%@" argument:@[[item getValueFromKey:@"id"]]] lastObject];
        
        if([r.finish isEqualToString:@"1"])
        {
            NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:item];
            
            dict[@"download"] = @(1);
            
            dict[@"name"] = [NSKeyedUnarchiver unarchiveObjectWithData:r.data][@"name"];
            
            [dataList replaceObjectAtIndex:index withObject:dict];
        }
    }
}



/////////////////

- (void)didStartPlayWith:(NSString*)vID andInfo:(NSDictionary*)info
{
    config = info;
    
    NSLog(@"=====%@", info);
    
    uID = [info getValueFromKey:@"id"];
    
    localUrl = @"";
    
    playListName = @"";
    
    [setupData removeAllObjects];
    
    [setupData addEntriesFromDictionary:info];
    
    playingData[@"cover"] = setupData[@"img"];
    
//    NSLog(@"%@", info);
        
    titleSong.text = info[@"name"];
    
    ((UILabel*)[self playerInfo][@"title"]).text = info[@"name"];
    
    ((UILabel*)[self playerInfo][@"titleTop"]).text = info[@"name"];
    
    [((UIButton*)[self playerInfo][@"play"]) addTarget:self action:@selector(didPressPause:) forControlEvents:UIControlEventTouchUpInside];
    
     [((UIButton*)[self playerInfo][@"playTop"]) addTarget:self action:@selector(didPressPause:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self playerInfo][@"back"]) addTarget:self action:@selector(playPrevious) forControlEvents:UIControlEventTouchUpInside];

    [((UIButton*)[self playerInfo][@"next"]) addTarget:self action:@selector(playNext) forControlEvents:UIControlEventTouchUpInside];

    [((GUISlider*)[self playerInfo][@"slider"]) setThumbImage:[UIImage imageNamed:@"trans"] forState:UIControlStateNormal];
    
    [((GUISlider*)[self playerInfo][@"slider"]) setThumbImage:[UIImage imageNamed:@"trans"] forState:UIControlStateHighlighted];
    
    [((UIButton*)[self playerInfo][@"off"]) addTarget:self action:@selector(didPressDown) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self playerInfo][@"downTop"]) addTarget:self action:@selector(didPressDown) forControlEvents:UIControlEventTouchUpInside];
    
//    [((UIButton*)[self playerInfo][@"sync"]) addTarget:self action:@selector(didPressSync:) forControlEvents:UIControlEventTouchUpInside];
    

//    [((UIButton*)[self playerInfo][@"volume"]) addTarget:self action:@selector(didPressVolume:) forControlEvents:UIControlEventTouchUpInside];
//
//    [((UIButton*)[self playerInfo][@"random"]) addTarget:self action:@selector(didPressRandom:) forControlEvents:UIControlEventTouchUpInside];
//
//    [((UIButton*)[self playerInfo][@"repeat"]) addTarget:self action:@selector(didPressRepeat:) forControlEvents:UIControlEventTouchUpInside];
//
//    [((UIButton*)[self playerInfo][@"edit"]) addTarget:self action:@selector(didPressEdit:) forControlEvents:UIControlEventTouchUpInside];
//

    [((UIView*)[self playerInfo][@"view"]) withBorder:@{@"Bcorner":@(0)}];
    
    ((UIView*)[self playerInfo][@"view"]).alpha = 1;
    
//    [((UIButton*)[self playerInfo][@"share"]) addTarget:self action:@selector(didPressClock:) forControlEvents:UIControlEventTouchUpInside];
//
    
    BOOL isIpod = [info responseForKey:@"ipod"];
    
    BOOL isDownload = [info responseForKey:@"download"];
    
    NSString *url = isIpod ? info[@"assetUrl"] : isDownload ? [NSString stringWithFormat:@"%@.mp3", [[[self pathFile] stringByAppendingPathComponent:info[@"name"]] stringByAppendingPathComponent:info[@"name"]]] : info[@"stream_url"];
    
    [self didPlayingWithUrl: isIpod ? [NSURL URLWithString:url] : isDownload ? [NSURL fileURLWithPath:url] : [NSURL URLWithString:url]];
    

//    ((UIButton*)[self playerInfo][@"sync"]).enabled = !isIpod && !isDownload;
    
    if(isIpod)
    {
        ((UIImageView*)[self playerInfo][@"img"]).image = [UIImage imageNamed:@"ipod"];
        
        avatar.image = [UIImage imageNamed:@"ipod"];
    }
    else
    {
        [(UIImageView*)[self playerInfo][@"img"] sd_setImageWithURL:[NSURL URLWithString: info[@"avatar"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) return;
            if (image && cacheType == SDImageCacheTypeNone)
            {
                [UIView transitionWithView:(UIImageView*)[self playerInfo][@"img"]
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [(UIImageView*)[self playerInfo][@"img"] setImage:image];
                                } completion:NULL];
            }
        }];
    }
    
    if(info[@"img"])
    {
        [self showInforPlayer:@{@"img":info[@"img"], @"song": info[@"name"] ? info[@"name"] : @"Unknown"}];
        
        avatar.image = info[@"img"];
    }
    else
    {
        [avatar sd_setImageWithURL:[NSURL URLWithString:[info getValueFromKey:@"avatar"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            setupData[@"img"] = image ? image : kAvatar;
            
            [self showInforPlayer:@{@"img": image ?  image : kAvatar, @"song":info[@"name"] ? info[@"name"] : @"Unknown"}];
        }];
    }
    
    pageIndex = 1;
    
    totalPage = 1;
    
    [self didRequestData];
     
    [self didRequestChapter];
    
    if ([info responseForKey:@"back_to_top"]) {
        [self backToTop];
    }
}

- (NSDictionary*)playerInfo
{
    NSMutableDictionary * dict = [@{} mutableCopy];
    
    controlView.alpha = !IS_IPAD;
    
    controlViewIpad.alpha = IS_IPAD;

    UIView * cell = IS_IPAD ? controlViewIpad : controlView;
    
    NSArray * array = @[@"img", @"cover",@"slider",@"currentTime",@"remainTime",@"title",@"back",@"play",@"next",@"off",@"loading",@"sync",@"playTop",@"titleTop",@"downTop",@"repeat",@"line",@"view",@"list",@"edit",@"time"];
    
    for(UIView * v in cell.subviews)
    {
        dict[array[[cell.subviews indexOfObject:v]]] = v;
    }

//    NSLog(@"%@", dict);
    
    [((UIImageView*)dict[@"img"]) withBorder:@{@"Bcorner":@(6)}];
        
    return dict;
}

- (void)initAvatar:(NSString*)url
{
    if(playState == Search && url.length == 0)
    {
        avatar.image = [UIImage imageNamed:@"ipod"];
    }
    else
    {
        [avatar sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) return;
            if (image && cacheType == SDImageCacheTypeNone)
            {
                [UIView transitionWithView:avatar
                                  duration:0.5
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    [avatar setImage:image];
                                } completion:NULL];
            }
        }];
    }
}

- (NSDictionary*)sliderInfo
{
    ((GUISlider*)[self playerInfo][@"slider"]).value = 0;
    
    return @{@"slider":[self playerInfo][@"slider"], @"remainTime":[self playerInfo][@"remainTime"], @"currentTime":[self playerInfo][@"currentTime"],@"multi":@[@{@"slider":slider}]};
}

- (void)didPlayingWithUrl:(NSURL*)uri
{
    if(playerView)
    {
        [playerView clean];
        
        playerView = nil;
    }
    
    [playingData addEntriesFromDictionary:[self sliderInfo]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    playerView = [[GUIPlayerView alloc] initWithFrame:CGRectMake(0, 64, width, width * 9.0f / 16.0f) andInfo:playingData];
    
    [playerView setDelegate:self];
    
    if(uri)
    {
        [playerView setVideoURL:uri];
        
        [playerView prepareAndPlayAutomatically:YES];
    }
    
    [self startOrStop:YES];
    
    avatar.userInteractionEnabled = NO;
    
    titleSong.userInteractionEnabled = NO;
    
    play.enabled = NO;
    
    ((UIButton*)[self playerInfo][@"play"]).enabled = NO;
}

- (void)fadeVolume
{
    if(isSound)
        return;
    
    if([self.playerView getVolume] <= 1)
    {
        [self.playerView setVolume:[self.playerView getVolume] + 0.1];
        
        [self performSelector:@selector(fadeVolume) withObject:nil afterDelay:0.5];
    }
}

- (void)didStartSyncingWith:(NSDictionary*)dataInfo
{
    [[DownloadManager share] insertAll:[[DownLoad shareInstance] didProgress:@{@"url":dataInfo[@"url"],
                                                                               @"name":[self autoIncrement:@"nameId"],
                                                                               @"cover":dataInfo[@"cover"],
                                                                               @"infor":dataInfo[@"info"]}
                                                               andCompletion:^(int index, DownLoad *obj, NSDictionary *info) {
                                                                   
                                                               }]];
}

#pragma mark Action

- (void)didPressShare:(UIButton*)sender
{
   
}

- (void)didPressClock:(UIButton*)sender
{
    [[[EM_MenuView alloc] initWithTime:@{@"time":[self getValue:@"timer"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu) {
        
        if(index == 1983)
        {
            int val = (int)((UISlider*)object).value;
            
            ((UILabel*)[self playerInfo][@"time"]).text = [self duration:val * 60];

            //((UILabel*)[self playerInfo][@"time"]).alpha = 0;
            
            [UIView animateWithDuration:1.9 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
                
                //((UILabel*)[self playerInfo][@"time"]).alpha = 1;
                
            } completion:nil];
            
            [self addValue:[NSString stringWithFormat:@"%i",val] andKey:@"timer"];
            
            if(val == 0)
            {
                [[DownloadManager share] timerStop];
                
                ((UILabel*)[self playerInfo][@"time"]).text = @"";
            }
            else
            {
                [[DownloadManager share] initTime:(int)((UISlider*)object).value];
    
                [[DownloadManager share] completion:^(int index, int time, DownloadManager * manager) {

                    if(time >= 0)
                    {
                        if(time % 5 == 0)
                        {
                            ((UILabel*)[self playerInfo][@"time"]).text = [self duration:time];
                        }
                    }
                    
                    if(index == 0)
                    {
                        [manager timerStop];
        
                        if([self.playerView isPlaying])
                        {
                            [self.playerView pause];
                        }
                        
                        [UIView animateWithDuration:1.9 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                            
                            //((UILabel*)[self playerInfo][@"time"]).alpha = 1;
                            
                        } completion:^(BOOL done) {
                            
                            //[((UILabel*)[self playerInfo][@"time"]).layer removeAllAnimations];
                            
                            ((UILabel*)[self playerInfo][@"time"]).text = @"";
                            
                        }];
                    }
                    
                }];
            }
        }
        
        [menu close];
    }];
}

- (void)didPressEdit:(UIButton*)sender
{
//    tableView.editing = tableView.isEditing ? NO : YES;
    
//    [sender setTitle:tableView.isEditing ? @"Done" : @"Edit" forState:UIControlStateNormal];
}

- (void)didPressSync:(UIButton*)sender
{
    int count = [Records getFormat:@"vid=%@" argument:@[uID]].count;
    
    if(count > 0)
    {
        [self showToast:@"Already synced" andPos:0];
        
        return;
    }
    
    NSMutableDictionary * information = [[NSMutableDictionary alloc] initWithDictionary:setupData];
    
    information[@"img"] = avatar.image;
    
    [self didStartSyncingWith:@{@"url":information[@"stream_url"],
                                @"cover":information[@"img"],
                                @"info":information
                                }];
}

- (void)didPressVolume:(UIButton*)sender
{
    [sender setImage:[UIImage imageNamed: isSound ? @"sound_ac" : @"sound_in"] forState:UIControlStateNormal];
    
    isSound =! isSound;
    
    if(!isSound)
    {
        [self fadeVolume];
    }
    else
    {
        [self.playerView setVolume:0];
    }
}

- (IBAction)didPressRandom:(UIButton*)sender
{
    playingData[@"shuffle"] = [playingData[@"shuffle"] boolValue] ? @"0" : @"1";
    
    [self playingState];
}

- (IBAction)didPressRepeat:(UIButton*)sender
{
    playingData[@"repeat"] = [playingData[@"repeat"] isEqualToString:@"2"] ? @"0" : [playingData[@"repeat"] isEqualToString:@"1"] ? @"2" : @"1";
    
    [self playingState];
}

- (IBAction)didPressPause:(UIButton*)sender
{
    if(![self.playerView isPlaying])
    {
        [self.playerView play];
        
        [self fadeVolume];
        
        [titleSong resumeAnimations];
    }
    else
    {
        [self.playerView pause];
        
        [self.playerView setVolume:0];
    }
    
    [self playingState:[self.playerView isPlaying]];
}

- (IBAction)playNext
{
    [self didPlayNextOrPre:YES];
}

- (IBAction)playPrevious
{
    [self didPlayNextOrPre:NO];
}

- (void)didPlayNextOrPre:(BOOL)isNext
{
//    if(chapList.count == 0)
//    {
//        [self showToast:@"Music list is empty, please try other song" andPos:0];
//
//        return;
//    }
//
    int nextIndexing = 0;
    
    BOOL found = NO;
    
//    switch (playState)
    {
//        case Search:
        {
            for(NSDictionary* dict in chapList)
            {
//                if([dict responseForKey:@"ipod"])
//                {
//                    if([[dict getValueFromKey:@"assetUrl"] isEqualToString:uID])
//                    {
//                        found = YES;
//
//                        nextIndexing = [dataList indexOfObject:dict] + (isNext ? 1 : -1);
//
//                        break;
//                    }
//                }
//                else
//                {
                    if([[dict getValueFromKey:@"id"] isEqualToString:uID])
                    {
                        found = YES;
                        
                        nextIndexing = [chapList indexOfObject:dict] + (isNext ? -1 : 1);
                        
                        break;
                    }
//                }
            }
        }
//            break;
//        default:
//            break;
    }
    
//    NSLog(@"%i", nextIndexing);
    
    if(found)
    {
        if(!isNext)
        {
            if(nextIndexing >= chapList.count)
            {
                nextIndexing = 0;
            }
        }
        else
        {
            if(nextIndexing <= 0)
            {
                nextIndexing = chapList.count - 1;
            }
//            else
//            {
//                nextIndexing = 0;
//            }
        }
    }
    else
    {
        nextIndexing = 0;
    }
        
    NSMutableDictionary * playingInfo = [[NSMutableDictionary alloc] initWithDictionary:chapList[nextIndexing]];
    
    playingInfo[@"byPass"] = @"1";
    
    [self didRequestUrlWithInfo:playingInfo];
    
//    if([self.playerView.options[@"shuffle"] isEqualToString:@"1"])
//    {
//        nextIndexing = RAND_FROM_TO(0, dataList.count -1);
//    }
    
//    switch (playState)
    {
//        case Search:
        {
//            [self didStartPlayWith:[(NSDictionary*)dataList[nextIndexing] getValueFromKey: [(NSDictionary*)dataList[nextIndexing] responseForKey:@"ipod"] ? @"assetUrl" : @"id"] andInfo:(NSDictionary*)dataList[nextIndexing]];
        }
//            break;
//        default:
//            break;
    }
}


- (int)activeIndex
{
    int uuid = -1;
    
//    for(id dict in dataList)
//    {
//        NSDictionary * list = [dict isKindOfClass:[MPMediaItem class]] ? [self ipodItem:(MPMediaItem*)dict] : [dict isKindOfClass:[Item class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:((Item*)dict).data] : [dict isKindOfClass:[DownLoad class]] ?  ((DownLoad*)dict).downloadData[@"infor"] : [dict isKindOfClass:[History class]] ?
//        [NSKeyedUnarchiver unarchiveObjectWithData:((History*)dict).data] :
//        [dict responseForKey:@"track"] ? dict[@"track"] : dict;
//        
//        if([dict isKindOfClass:[MPMediaItem class]])
//        {
//            if([[list getValueFromKey:@"assetUrl"] isEqualToString:localUrl])
//            {
//                uuid = [dataList indexOfObject:dict];
//                
//                break;
//            }
//        }
//        else
//        {
//            if([[list getValueFromKey:@"id"] isEqualToString:uID])
//            {
//                uuid = [dataList indexOfObject:dict];
//                
//                break;
//            }
//        }
//    }
    
    return uuid;
}

- (void)didSaveProgress
{
    NSMutableDictionary * leftOver = [[NSMutableDictionary alloc] initWithDictionary:setupData];
    
    [leftOver removeObjectForKey:@"img"];
        
//    [self addValue:avatar.image andKey:@"leftImg"];
    
    leftOver[@"seek"] = @(slider.value);
    
    leftOver[@"localUrl"] = [setupData responseForKey:@"ipod"] ? localUrl : [[[[localUrl componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] firstObject];
    
    leftOver[@"playListName"] = playListName;
    
//    [self addValue:dataList andKey:@"leftOverList"];
    
    leftOver[@"playingState"] = @(playState);
        
    [self addObject:[leftOver reFormat] andKey:@"leftOver"];
}

- (void)playerDidPause
{
    [self playingState:NO];
    
    [titleSong pauseAnimations];

    [self didSaveProgress];
}

- (void)playerDidResume
{
    [self playingState:YES];
}

- (void)playerStalled
{
    [self playingState:NO];
    
    [self didSaveProgress];
}

- (void)playerFailedToPlayToEnd
{
    playerView.retryButton.hidden = NO;
    
    [self playingState:NO];
    
    [self showInforPlayer:@{@"img":kAvatar, @"song":@"Song not available"}];
    
//    [self removeObject:@"leftOver"];
    
//    [System removeValue:@"leftImg"];
}

- (void)playerError
{
    playerView.retryButton.hidden = NO;
    
    [self playingState:NO];
    
    [self showInforPlayer:@{@"img":kAvatar, @"song":@"Song not available"}];
    
//    [self removeObject:@"leftOver"];
    
//    [System removeValue:@"leftImg"];
}

- (void)playerReadyToPlay
{
    [self showInforPlayer:@{@"img":[setupData responseForKey:@"img"] ? setupData[@"img"] : kAvatar,@"song":[setupData responseForKey:@"name"] ? setupData[@"name"] : @"No Title"}];
    
    [self playingState:YES];
    
    if(isResume)
    {
        [self.playerView seekTo:[[self getObject:@"leftOver"][@"seek"] floatValue]];
        
        [[self ROOT] embed];
                
        [self didSaveProgress];

        [self.playerView setVolume:0];
        
        [self.playerView performSelector:@selector(pause) withObject:nil afterDelay:0.1];
        
        isResume = NO;
    }
    
    avatar.userInteractionEnabled = YES;
    
    titleSong.userInteractionEnabled = YES;
    
    play.enabled = YES;
    
    ((UIButton*)[self playerInfo][@"play"]).enabled = YES;
    
    [self startOrStop:NO];
}

- (void)playerDidEndPlaying
{
    [self playingState:NO];
    
    [self playNext];
    
    return;
    
    BOOL isIpod = [setupData responseForKey:@"ipod"];
    
//    if([playingData[@"repeat"] isEqualToString:@"0"])
//    {
//        [self initAvatar:[setupData getValueFromKey:@"artwork_url"]];
//
//        ((GUISlider*)[self playerInfo][@"slider"]).value = 0;
//    }
//
//    if([playingData[@"repeat"] isEqualToString:@"1"])
//    {
//        NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:setupData];
//
//        [self didStartPlayWith:isIpod ? dict[@"assetUrl"] : [dict getValueFromKey:@"id"] andInfo:dict];
//
//        [self initAvatar:[dict getValueFromKey:@"artwork_url"]];
//    }
    
    if([playingData[@"repeat"] isEqualToString:@"2"])
    {
        if(dataList.count == 0)
        {
            [self showToast:@"Music list is empty, please try other song" andPos:0];
            
            return;
        }
        
        int nextIndexing = 0;
        
//        if([self.playerView.options[@"shuffle"] isEqualToString:@"0"])
//        {
//            BOOL found = NO;
//
//            switch (playState)
//            {
//                case Search:
//                {
//                    for(NSDictionary* dict in dataList)
//                    {
//                        if([dict responseForKey:@"ipod"])
//                        {
//                            if([[dict getValueFromKey:@"assetUrl"] isEqualToString:uID])
//                            {
//                                found = YES;
//
//                                nextIndexing = [dataList indexOfObject:dict] + 1;
//
//                                break;
//                            }
//                        }
//                        else
//                        {
//                            if([[dict getValueFromKey:@"id"] isEqualToString:uID])
//                            {
//                                found = YES;
//
//                                nextIndexing = [dataList indexOfObject:dict] + 1;
//
//                                break;
//                            }
//                        }
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//
//            if(found)
//            {
//                if(nextIndexing >= dataList.count)
//                {
//                    nextIndexing = 0;
//                }
//            }
//            else
//            {
//                nextIndexing = 0;
//            }
//        }
//        else
//        {
//            nextIndexing = RAND_FROM_TO(0, dataList.count -1);
//        }
        
        switch (playState)
        {
            case Search:
            {
                [self didStartPlayWith:[(NSDictionary*)dataList[nextIndexing] getValueFromKey: [(NSDictionary*)dataList[nextIndexing] responseForKey:@"ipod"] ? @"assetUrl" : @"id"] andInfo:(NSDictionary*)dataList[nextIndexing]];
            }
                break;
            default:
                break;
        }
    }
}

- (void)playingState:(BOOL)isPlaying
{
    [play setImage:[UIImage imageNamed:isPlaying ? @"pause_s" : @"play_s"] forState:UIControlStateNormal];
    
    [(UIButton*)[self playerInfo][@"play"] setImage:[UIImage imageNamed:isPlaying ? @"pause_D" : @"play_D"] forState:UIControlStateNormal];
    
    [(UIButton*)[self playerInfo][@"playTop"] setImage:[UIImage imageNamed:isPlaying ? @"pause_D" : @"play_D"] forState:UIControlStateNormal];
    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        ((UIImageView*)[self playerInfo][@"img"]).transform = CGAffineTransformScale(CGAffineTransformIdentity, isPlaying ? 1 : 0.9,isPlaying ? 1 : 0.9);
//        
//    }];
//    
}

- (void)showInforPlayer:(NSDictionary*)dict
{
    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage: dict[@"img"]];
    
    NSArray *keys = [NSArray arrayWithObjects: MPMediaItemPropertyArtist, MPMediaItemPropertyArtwork, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
    
    NSArray *values = [NSArray arrayWithObjects: dict[@"song"], albumArt, [NSNumber numberWithFloat: CMTimeGetSeconds(playerView.currentItem.asset.duration)], [NSNumber numberWithFloat:1.0], nil];
    
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
}

- (void)startOrStop:(BOOL)start
{
    if(start)
    {
        play.alpha = 0;
        
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            
            play.alpha = 1;
            
        } completion:nil];
        
    }
    else
    {
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            play.alpha = 1;
            
        } completion:^(BOOL done) {
            
            [play.layer removeAllAnimations];
                        
        }];
    }
}

- (IBAction)didPressAvatar:(id)sender
{
    [self goUp];
    
//    if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
//    {
//        [((UIButton*)[self playerInfo][@"sync"]) setImage:[UIImage imageNamed:@"shareI"] forState:UIControlStateNormal];
//
//        [((UIButton*)[self playerInfo][@"sync"]) removeTarget:NULL action:nil forControlEvents:UIControlEventAllTouchEvents];
//
//        [((UIButton*)[self playerInfo][@"sync"]) addTarget:self action:@selector(didPressShare:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else
//    {
//        [((UIButton*)[self playerInfo][@"sync"]) setImage:[UIImage imageNamed:@"reload"] forState:UIControlStateNormal];
//
//        [((UIButton*)[self playerInfo][@"sync"]) removeTarget:NULL action:nil forControlEvents:UIControlEventAllTouchEvents];
//
//        [((UIButton*)[self playerInfo][@"sync"]) addTarget:self action:@selector(didPressSync:) forControlEvents:UIControlEventTouchUpInside];
//    }
}

- (IBAction)didPressDown
{
    [self goDown];
}

- (IBAction)didPressDismiss
{
    [self.playerView stop];
    
    [self.playerView clearSession];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{}];
    
    [self unEmbed];
}

- (void)didRequestData {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"page_index": @(pageIndex),
                                                                                      @"page_size": @(10),
                                                                                      @"book_type": @(0),
                                                                                      @"price": @(0), @"sorting": @(1),
                                                                                      @"overrideLoading": @"1",
                                                                                      @"overrideAlert": @"1",
                                                                                      @"host": self,
    }];
    request[@"CMD_CODE"] = @"getListBook";
    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];
    
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] || dict[@"result"] == [NSNull null] ) {
            NSDictionary * dict = [responseString objectFromJSONString][@"result"];
            totalPage = [dict[@"total_page"] intValue] ;
            if (!isLoadMore) {
                [dataList removeAllObjects];
            }
            
            NSArray * filter = [self filterArrayWithData:dict[@"data"]];
            
            [dataList addObjectsFromArray: [Information.check isEqualToString:@"0"] ? filter : dict[@"data"]];
            
            [collectionView reloadData];
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        
        [self adjustInset];
    }];
}

- (void)didRequestChapter {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"book_type": @(0),
                                                                                      @"price": @(0), @"sorting": @(1),
                                                                                      @"overrideAlert": @"1",
    }];
    
    request[@"id"] = config[@"id"];
    request[@"CMD_CODE"] = @"getListChapOfStory";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] || dict[@"result"] == [NSNull null]) {
            NSArray * dict = [responseString objectFromJSONString][@"result"];
            
            [chapList removeAllObjects];
            
            [chapList addObjectsFromArray: dict];
            
            [collectionView reloadData];
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        [self adjustInset];
    }];
}

- (void)didRequestContent {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"overrideAlert": @"1",
    }];
    
    request[@"id"] = config[@"id"];
    request[@"CMD_CODE"] = @"getBookContent";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
            NSDictionary * dict = [responseString objectFromJSONString][@"result"];

            NSMutableDictionary * information = [[NSMutableDictionary alloc] initWithDictionary:config];
            
            information[@"stream_url"] = [dict getValueFromKey:@"file_url"];

            [self didStartPlayWith:@"" andInfo:information];
            
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        [self adjustInset];
    }];
}

#pragma Collection


- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return section == 1 ? dataList.count : chapList.count == 1 ? 0 : chapList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:indexPath.section == 0 ? @"TG_Book_Chap_Cell" : @"TG_Map_Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        NSDictionary * chap = chapList[indexPath.item];
        
        ((UILabel*)[self withView:cell tag:1]).text = [chap getValueFromKey:@"name"];
        
//        ((UILabel*)[self withView:cell tag:2]).text = [NSString stringWithFormat:@"%@ chữ Cập nhật %@", [chap getValueFromKey:@"total_character"], [chap getValueFromKey:@"publish_time"]];
        
        ((UILabel*)[self withView:cell tag:2]).text = [NSString stringWithFormat:@"Cập nhật %@", [chap getValueFromKey:@"publish_time"]];

        ((UILabel*)[self withView:cell tag:5]).text = @"Nghe >";
    }
    
    if (indexPath.section == 1) {
        NSDictionary * book = dataList[indexPath.item];
        
        ((UILabel*)[self withView:cell tag:112]).text = [book getValueFromKey:@"name"];
        
        ((UILabel*)[self withView:cell tag:13]).text = ((NSArray*)book[@"author"]).count > 1 ? @"Nhiều tác giả" : book[@"author"][0][@"name"];
        
        [((UIImageView*)[self withView:cell tag:11]) imageUrlWithUrl:[book getValueFromKey:@"avatar"]];
        
        ((UIImageView*)[self withView:cell tag:999]).hidden = ![[book getValueFromKey:@"book_type"] isEqualToString:@"3"];
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1 ? CGSizeMake((screenWidth1 / (IS_IPAD ? 5 : 3)) - 15, ((screenWidth1 / (IS_IPAD ? 5 : 3)) - 15) * 1.72) : CGSizeMake(_collectionView.frame.size.width, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(4, 4, 4, 4);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        NSDictionary * chap = chapList[indexPath.item];
        config = chap;
        [self didRequestContent];
    }
    if (indexPath.section == 1) {
        NSDictionary * book = dataList[indexPath.item];
        if ([[book getValueFromKey:@"book_type"] isEqualToString:@"3"]) {
            config = book;
            [self didRequestContent];
            [self backToTop];
        } else {
            [self goDown];
            Book_Detail_ViewController * detail = [Book_Detail_ViewController new];
            NSMutableDictionary * information = [[NSMutableDictionary alloc] initWithDictionary:book];
            information[@"url"] = @{@"CMD_CODE": @"getListBook", @"book_type": @(0), @"price": @(0), @"sorting": @(1)};
            detail.config = information;
            [[self CENTER] pushViewController:detail animated:YES];
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UIView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Book_Detail_Title" forIndexPath:indexPath];
    
    ((UILabel*)[self withView:view tag:1]).text = indexPath.section == 0 ? @"Danh sách chương" : @"Có thể bạn thích";
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, chapList.count == 1 ? 0 : 44);
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        if (pageIndex == 1) {
            return;
        }
        
        if (indexPath.item == dataList.count - 1) {
            if(pageIndex <= totalPage) {
                isLoadMore = YES;
                [self didRequestData];
            }
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
