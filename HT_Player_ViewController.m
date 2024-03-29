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
    
    IBOutlet NSLayoutConstraint * topHeight, * topHeightIpad, * leftGap, * rightGap;
    
    IBOutlet UIButton * play;
    
    NSMutableArray * dataList, * chapList, * detailList, * ratingList;
    
    NSMutableDictionary * playingData, * setupData, * tempInfo;
    
    IBOutlet UIImageView * avatar;
    
    BOOL isResume, isSound, showMore;
    
    NSDictionary * config;
    
    NSTimer * timer;
    
    NSString * localUrl, * playListName, * tempBio, * bioString, * catId, * mp3URL;
    
    IBOutlet GUISlider * slider;
    
    int pageIndex;
    
    int totalPage;
    
    int totalRateCount;
    
    int readTime;
    
    BOOL isLoadMore, isBlock;
    
    float bioHeight;
}

@end

@implementation HT_Player_ViewController

@synthesize playerView, playState, topView, uID, controlView, controlViewIpad, collectionView, retract, isRestricted;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mp3URL = @"";
    
    isBlock = NO;
    
    isRestricted = NO;
    
    dataList = [NSMutableArray new];
    
    chapList = [NSMutableArray new];

    detailList = [NSMutableArray new];
    
    ratingList = [NSMutableArray new];
    
    tempInfo = [NSMutableDictionary new];

    setupData = [@{} mutableCopy];
        
    topHeight.constant = screenWidth1 * 9 / 16;
    
    topHeightIpad.constant = screenWidth1 * 9 / 16;
    
    bioHeight = 0;
    
    readTime = 0;
    
    retract = YES;

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
    [collectionView withCell:@"Book_Detail_Infor"];
    [collectionView withCell:@"Book_Detail_Option_Cell"];
    [collectionView withCell:@"Author_Bio_Cell"];
    [collectionView withCell:@"TG_Book_Detail_Cell"];
    [collectionView withCell:@"Book_Rating_Cell"];
    [collectionView withHeaderOrFooter:@"Book_Detail_Chap_Header" andKind: UICollectionElementKindSectionHeader];
    [collectionView withHeaderOrFooter:@"Book_Detail_Gap" andKind: UICollectionElementKindSectionHeader];
}

- (void)parallaxHeader {
    UIView * controller = IS_IPAD ? controlViewIpad : controlView;
    UIView * bg = [self withView:controller tag:1000];
    UIView * imageView = [self withView:controller tag:10001];
    UIButton * down = [self withView:controller tag:10002];
    collectionView.parallaxHeader.view = IS_IPAD ? controlViewIpad : controlView;
    collectionView.parallaxHeader.height = screenWidth1 * 9 / 16;
    collectionView.parallaxHeader.minimumHeight = [self isIphoneX] ? 64 : 64;
    [collectionView.parallaxHeader setParallaxHeaderDidScrollHandler:^(ParallaxHeader * header) {
        for (UIView * v in controller.subviews) {
            if (v.tag != 1000 && v.tag != 1010101) {
                if (v.tag == 9988 || v.tag == 9989 || v.tag == 9990) {
                    v.alpha = 0;//1 - header.progress;
                } else {
                    v.alpha = header.progress;
                }
            }
        }
        bg.alpha = 0;//1 - header.progress;
        imageView.alpha = 1;
        down.alpha = 0;
    }];
}

- (void)adjustInset {
    float headerHeight = screenWidth1 * 9 / 16;
    float embeded = [self isEmbed] ? 0 : 0;
    float contentSizeHeight = collectionView.collectionViewLayout.collectionViewContentSize.height;
    float collectionViewHeight = collectionView.frame.size.height;
    collectionView.contentInset = UIEdgeInsetsMake(headerHeight, 0, contentSizeHeight < (collectionViewHeight - 64) ? (collectionViewHeight - contentSizeHeight - 64 + embeded) : (0 + embeded), 0);
}

- (void)startTimer {
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(updateTime)
                                           userInfo:nil
                                            repeats:YES];
}

- (void)updateTime {
    readTime += 1;
//    NSLog(@"--->%i", readTime);
}

- (void)stoptimer {
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
}

- (void)backToTop {
    [collectionView setContentOffset:CGPointMake(0, - screenWidth1 * 9 / 16) animated:YES];
}

- (NSString*)iniBio:(BOOL)show {
    NSString * modifiedFont = [NSString stringWithFormat:@"<span style=\"font-family: '-apple-system', 'HelveticaNeue'; font-size:16 \">%@</span>", self->tempBio];
    NSString * tempString = [[self html2StringWithString:modifiedFont] length] > (IS_IPAD ? 120 : 120) ? [NSString stringWithFormat:@"%@...", [[self html2StringWithString:modifiedFont] substringToIndex:120]] : [self html2StringWithString:modifiedFont];
    
    return !show ? tempString : [self html2StringWithString:modifiedFont];
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
//            [self didStartPlayWith:isIpod ? dict[@"assetUrl"] : [dict getValueFromKey:@"id"] andInfo:dict];
            
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
        
    uID = [info getValueFromKey:@"id"];
    
    localUrl = @"";
    
    playListName = @"";
    
    readTime = 0;
    
    isBlock = NO;
    
    isRestricted = NO;
    
    [setupData removeAllObjects];
    
    [setupData addEntriesFromDictionary:info];
    
    playingData[@"cover"] = setupData[@"img"];
            
    titleSong.text = info[@"name"];
    
    ((UILabel*)[self playerInfo][@"title"]).text = info[@"name"];
    
    ((UILabel*)[self playerInfo][@"titleTop"]).text = info[@"name"];
    
    [((UIButton*)[self playerInfo][@"play"]) addTarget:self action:@selector(didPressPause:) forControlEvents:UIControlEventTouchUpInside];
    
     [((UIButton*)[self playerInfo][@"playTop"]) addTarget:self action:@selector(didPressPause:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self playerInfo][@"back"]) addTarget:self action:@selector(playPrevious:) forControlEvents:UIControlEventTouchUpInside];

    [((UIButton*)[self playerInfo][@"next"]) addTarget:self action:@selector(playNext:) forControlEvents:UIControlEventTouchUpInside];

    [((GUISlider*)[self playerInfo][@"slider"]) setThumbImage:[UIImage imageNamed:@"ico_round"] forState:UIControlStateNormal];
    
    [((GUISlider*)[self playerInfo][@"slider"]) setThumbImage:[UIImage imageNamed:@"ico_round"] forState:UIControlStateHighlighted];
    
    [((GUISlider*)[self playerInfo][@"slider"]) setSecondaryTintColor:[UIColor redColor]];
    
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

//    [self didPlayingWithUrl: isIpod ? [NSURL URLWithString:url] : isDownload ? [NSURL fileURLWithPath:url] : [NSURL URLWithString:url]];
    
//    ((UIButton*)[self playerInfo][@"sync"]).enabled = !isIpod && !isDownload;
    
    if(isIpod)
    {
        ((UIImageView*)[self playerInfo][@"img"]).image = [UIImage imageNamed:@"ipod"];
        
        avatar.image = [UIImage imageNamed:@"ipod"];
    }
    else
    {
        [(UIImageView*)[self playerInfo][@"img"] sd_setImageWithURL:[NSURL URLWithString: [info getValueFromKey: @"avatar"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    
    totalRateCount = 0;
        
    [self didRequestDetail: url];
     
    [self didRequestChapter];
    
    [self didRequestRating];
        
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
        if (sender.tag == 22 && !isBlock) {
            [self goUp];
        }
        [self.playerView play];
        
        if (!isRestricted) {
            [self startTimer];
        }
        
        [self fadeVolume];
        
        [titleSong resumeAnimations];
    }
    else
    {
        [self.playerView pause];
        
        [self stoptimer];
        
        [self.playerView setVolume:0];
    }
    
    [self playingState:[self.playerView isPlaying]];
}

- (void)didCheckBuy {
    if ([self.playerView isPlaying])
    {
        [self.playerView pause];
        
        [self stoptimer];
        
        [self.playerView setVolume:0];
        
        [self playingState: [self.playerView isPlaying]];
    }
}

- (IBAction)playNext:(UIButton*)sender;
{
    if (sender.tag == 33 && !isBlock) {
        [self goUp];
    }
    [self didPlayNextOrPre:YES];
}

- (IBAction)playPrevious:(UIButton*)sender;
{
    if (sender.tag == 11 && !isBlock) {
        [self goUp];
    }
    [self didPlayNextOrPre:NO];
}

- (void)didPlayNextOrPre:(BOOL)isNext
{
    [self didrequestLogTime];
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
    
    [self didRequestMP3LinkWithInfo:playingInfo];
    
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
    
    [self stoptimer];
}

- (void)playerDidResume
{
    [self playingState:YES];
    if (!isRestricted) {
        [self startTimer];
    }
}

- (void)playerStalled
{
    [self playingState:NO];
    
    [self didSaveProgress];
    
    [self stoptimer];
}

- (void)playerFailedToPlayToEnd
{
    playerView.retryButton.hidden = NO;
    
    [self playingState:NO];
    
    [self showInforPlayer:@{@"img":kAvatar, @"song":@"Song not available"}];
    
    [self stoptimer];
    
//    [self removeObject:@"leftOver"];
    
//    [System removeValue:@"leftImg"];
}

- (void)playerError
{
    playerView.retryButton.hidden = NO;
    
    [self playingState:NO];
    
    [self showInforPlayer:@{@"img":kAvatar, @"song":@"Song not available"}];
    
    [self stoptimer];

//    [self removeObject:@"leftOver"];
    
//    [System removeValue:@"leftImg"];
}

- (void)playerReadyToPlay
{
    [self showInforPlayer:@{@"img":[setupData responseForKey:@"img"] ? setupData[@"img"] : kAvatar, @"song":[setupData responseForKey:@"name"] ? setupData[@"name"] : @"No Title"}];

    [self playingState:YES];
    
    avatar.userInteractionEnabled = YES;
    
    titleSong.userInteractionEnabled = YES;
    
    play.enabled = YES;
    
    ((UIButton*)[self playerInfo][@"play"]).enabled = YES;
    
    if (self.isRestricted) {
        return;
    }
    
    [self startOrStop:NO];
    
    if (isBlock) {
        return;
    }
    
    [self didPressPause:nil];
    
    if (![[tempInfo getValueFromKey:@"price"] isEqualToString:@"0"]) {
        [self didRequestUrlWithInfo:tempInfo callBack:^(NSDictionary * info) {
            NSLog(@"%@", tempInfo);
            if([info responseForKey:@"fail"]) {
                if ([[tempInfo getValueFromKey: @"has_preview"] isEqualToString:@"0"]) {
                    [self didPressBuyWithIsAudio: YES];
                } else {
                    self.isRestricted = YES;
                    [self didPlayingWithUrl: [NSURL URLWithString: [tempInfo getValueFromKey:@"demo_path"]]];
                }
                [self stoptimer];
            } else {
                NSTimeInterval delayInSeconds = 0.8;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self didPressPause:nil];
                });
                isBlock = YES;
            }
        }];
    } else {
        NSTimeInterval delayInSeconds = 0.8;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self didPressPause:nil];
        });
        isBlock = YES;
    }
    
    [self startTimer];
}

- (void)playerDidEndPlaying
{
    [self didrequestLogTime];

    [self playingState:NO];
    
    [self stoptimer];
    
    if (self.isRestricted) {
        [[[EM_MenuView alloc] initWithRestrict:@{@"line3": @"MUA GÓI"}] disableCompletion:^(int index, id object, EM_MenuView *menu) {
            if (index == 4) {
                [self didPressBuyWithIsAudio: YES];
            }
        }];
        [self.playerView seekTo:0];
    } else {
        [self playNext:nil];
    }
    
    return;
    
    
    
    
////////////////////////////
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
    [play setImage:[UIImage imageNamed: isPlaying ? @"pause_s" : @"play_s"] forState:UIControlStateNormal];
    
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
    [self stoptimer];
    
    [self didrequestLogTime];

    [self.playerView stop];
    
    [self.playerView clearSession];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:@{}];
    
    [self unEmbed];
}

- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

- (void)didrequestLogTime {
    if (readTime == 0) {
        return;
    }
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                      @"start_time":[NSString currentDate:@"HH:mm dd/MM/yyyy"],
                                                                                      @"time":@(readTime),
                                                                                      @"overrideAlert": @"1",
    }];
    request[@"CMD_CODE"] = @"pushReadingLog";
    request[@"item_id"] = config[@"id"];
    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];
    
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
    
    }];
}

- (IBAction)senderdidRequestLike:(UIButton*)sender {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                      @"overrideAlert": @"1",
    }];
    request[@"CMD_CODE"] = @"pushLikeItem";
    request[@"item_id"] = config[@"id"];
    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];
    
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
            NSDictionary * dict = [responseString objectFromJSONString][@"result"];
            
            NSMutableDictionary * tempConfig = [[NSMutableDictionary alloc] initWithDictionary:self->tempInfo];

            tempConfig[@"like_count"] = [dict getValueFromKey:@"like_count"];
                        
//            BOOL likeStatus = [[dict getValueFromKey:@"like_status"] isEqualToString:@"1"];

            tempConfig[@"like_status"] = [dict getValueFromKey:@"like_status"];
            
            [self->tempInfo removeAllObjects];
            
            [self->tempInfo addEntriesFromDictionary:tempConfig];
//            self->tempInfo = tempConfig;
                        
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                                                
//            [sender setImage: likeStatus ? [[UIImage imageNamed:@"ico_like_fill"] imageWithTintColor:[UIColor systemPinkColor]] : [UIImage imageNamed:@"ico_like_white"]
//                    forState:UIControlStateNormal];
            
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        
        [self adjustInset];
    }];
}

- (void)didRequestData {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                      @"page_index": @(pageIndex),
                                                                                      @"page_size": @(10),
                                                                                      @"book_type": @(0),
                                                                                      @"price": @(0), @"sorting": @(1),
                                                                                      @"overrideLoading": @"1",
                                                                                      @"overrideAlert": @"1",
                                                                                      @"host": self,
    }];
    request[@"CMD_CODE"] = @"getListBook";
    request[@"category_id"] = catId;
    [request removeObjectForKey:@"group_type"];
    request[@"sorting"] = @([self randomNumberBetween:1 maxNumber:6]);
    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];
    
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] || dict[@"result"] == [NSNull null] ) {
            NSDictionary * dict = [responseString objectFromJSONString][@"result"];
            totalPage = [dict[@"total_page"] intValue] ;

            pageIndex += 1;

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
                                                                                      @"header":@{@"session":Information.token == nil ? @"" : Information.token},
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

- (void)didRequestRating {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{@"session": Information.token,
                                                                                      @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                      @"page_index": @(1),
                                                                                      @"page_size": @(3),
                                                                                      @"overrideAlert": @"1",
    }];
    
    request[@"item_id"] = config[@"id"];
    request[@"CMD_CODE"] = @"getListRating";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] || dict[@"result"] == [NSNull null]) {
            NSArray * array = dict[@"result"][@"data"];
                    
            totalRateCount = [dict[@"result"][@"total_count"] intValue] ;
            
            [ratingList removeAllObjects];
            
            [ratingList addObjectsFromArray: array];
            
            [collectionView reloadData];
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        [self adjustInset];
    }];
}

- (void)didRequestReaderContent {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                @"session": Information.token,
                                                                                @"overrideAlert": @"1",
    }];
    
    request[@"id"] = [tempInfo[@"related"] getValueFromKey: @"id"];
    request[@"CMD_CODE"] = @"getBookContent";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
            
            [self goDown];

            NSDictionary * dict = [responseString objectFromJSONString][@"result"];

            NSMutableDictionary * bookInfo = [[NSMutableDictionary alloc] initWithDictionary:tempInfo[@"related"]];
           
            Reader_ViewController * reader = [Reader_ViewController new];
            
            bookInfo[@"file_url"] = [dict getValueFromKey:@"file_url"];
            
            reader.config = bookInfo;
                        
            [[self CENTER] pushViewController:reader animated:YES];
            
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        [self adjustInset];
    }];
}

- (void)didRequestContent {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                @"session": Information.token,
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

- (void)didRequestItemInfo:(NSDictionary*)book {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                                                @"session": Information.token,
                                                                                @"item_id": [book getValueFromKey:@"id"],
                                                                                @"item_type": @"item",
                                                                                @"overrideAlert":@"1",
                                                                                @"overrideLoading":@"1"
    }];
    
    request[@"CMD_CODE"] = @"checkItemPurchaseInfo";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];
        
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
            NSDictionary * dict = [responseString objectFromJSONString][@"result"];

            if ([[dict getValueFromKey:@"status"] isEqualToString:@"1"]) {
                [self showToast: [NSString stringWithFormat:@"Mua sách nói \"%@\" thành công", [self->config getValueFromKey:@"name"]] andPos:0];
//                if(![self.playerView isPlaying])
//                {
//                    [self.playerView play];
//                    if (!isRestricted) {
//                        [self startTimer];
//                    }
//                    [self fadeVolume];
//                    [titleSong resumeAnimations];
//                }
            } else {
                [self didCheckBuy];
                NSMutableDictionary * checkInfo = [[NSMutableDictionary alloc] initWithDictionary:book];
                checkInfo[@"price"] = [[[checkInfo getValueFromKey:@"price"] stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
//                NSLog(@"%@", checkInfo);
                checkInfo[@"is_package"] = @"0";
                Check_Out_ViewController * checkOut = [Check_Out_ViewController new];
                checkOut.info = checkInfo;
                
                UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:checkOut];
                nav.navigationBarHidden = YES;
                nav.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:nav animated:YES completion:nil];
            }
            
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
    }];
}

- (void)didRequestDetail:(NSString*)url {
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"header":@{@"session":Information.token == nil ? @"" : Information.token},
        @"session": Information.token,
        @"overrideAlert": @"1",
    }];
    
    request[@"id"] = config[@"id"];
    request[@"CMD_CODE"] = @"getBookDetail";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
            NSDictionary * tempResult = [responseString objectFromJSONString][@"result"];
           
            NSMutableDictionary * result = [[NSMutableDictionary alloc] initWithDictionary:tempResult];
            
            if (![[result getValueFromKey:@"price"] isEqualToString:@"0"]) {
                NSString * pricing = [result getValueFromKey:@"price"];
                result[@"price"] = [self addDotWithNumber:pricing.integerValue];
            }
            
//            NSLog(@"====>%@", result);
            
//            let data = NSMutableDictionary.init(dictionary: dataTemp)
//            if data.getValueFromKey("price") != "0" {
//                let pricing = data.getValueFromKey("price")! as NSString
//                data["price"] = self.addDot(number: pricing.integerValue)
//            }
            
            self->catId = ((NSArray*)result[@"category"]).count == 0 ? @"0" : result[@"category"][0][@"id"];
            
            [self didRequestData];
            
            [self->detailList removeAllObjects];
                        
            [self->detailList addObjectsFromArray:[self filter:result relate: ![[result getValueFromKey:@"price"] isEqualToString:@"0"] || ![result[@"related"] isEqual:[NSNull null]]]];
            
            [self->tempInfo removeAllObjects];
            
            [self->tempInfo addEntriesFromDictionary:result];
            
            BOOL likeStatus = [[result getValueFromKey:@"like_status"] isEqualToString:@"1"];
            
            self->tempInfo[@"like_status"] = likeStatus ? @"1" : @"0";
                        
            [self->_likeBtn setImage: likeStatus ? [[UIImage imageNamed:@"ico_like_fill"] imageWithTintColor:[UIColor systemPinkColor]] : [UIImage imageNamed:@"ico_like_white"]
                    forState:UIControlStateNormal];
            
//            NSString * tem = ((NSArray*)result[@"publisher"]).count == 0 ? @"" : result[@"publisher"][0][@"description"];
            
            NSString * tem = [result getValueFromKey:@"description"];

            self->tempBio = tem;
            
            self->bioString = [self iniBio:self->showMore];
            
            [self->collectionView performBatchUpdates:^{
                [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:2]];
                [self->collectionView reloadData];
            } completion:^(BOOL finished) {
                    mp3URL = url;
                    [self didPlayingWithUrl:[NSURL URLWithString:url]];
            }];
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
        [self adjustInset];
    }];
}

- (void)didRequestComment:(NSDictionary*)comment andMenu:(EM_MenuView*)menu {
    if ([[comment getValueFromKey: @"rating"] isEqualToString:@"0.0"]) {
        [self showToast:@"Bạn chưa chọn đánh giá" andPos:0];
        return;
    }
    
    NSMutableDictionary * request = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"header":@{@"session":Information.token == nil ? @"" : Information.token},
        @"session": Information.token,
        @"overrideAlert": @"1",
        @"item_id": [config getValueFromKey:@"id"],
        @"rating": [comment getValueFromKey:@"rating"],
        @"rating_content": [[comment getValueFromKey:@"comment"] isEqualToString:@""] ? @" " : [comment getValueFromKey:@"comment"] ,
        @"overrideAlert":@"1",
    }];
    
    request[@"CMD_CODE"] = @"pushRateItem";

    [[LTRequest sharedInstance] didRequestInfo:request withCache:^(NSString *cacheString) {
        
    } andCompletion:^(NSString *responseString, NSString *errorCode, NSError *error, BOOL isValidated, NSDictionary *header) {
        NSDictionary * dict = [responseString objectFromJSONString];

        [menu close];
        
        if ([[dict getValueFromKey:@"error_code"] isEqualToString:@"0"] && dict[@"result"] != [NSNull null]) {
           
            [self showToast:@"Đánh giá thành công" andPos:0];
            
            self->tempInfo[@"rating"] = [dict[@"result"] getValueFromKey:@"rating"];
            
            [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            [self didRequestRating];
            
        } else {
            [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
        }
    }];
}

//NSArray * keys = relate ? @[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
//                   @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
////                       @{@"key": @"author", @"title": @"Tác giả", @"tag": @2, @"height": @35},
////                       @{@"key": @"publisher", @"title": @"Nhà xuất bản", @"tag": @2, @"height": @35},
////                       @{@"key": @"events", @"title": @"Tuyển tập", @"tag": @2, @"height": @35},
//                   @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
//                   @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
//                   @{@"key": @"button_cell", @"tag": @4, @"height": @35},
//                   @{@"key": @"read_cell", @"tag": @6, @"height": @20},
//] :
//@[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
//                   @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
////                       @{@"key": @"author", @"title": @"Tác giả", @"tag": @2, @"height": @35},
////                       @{@"key": @"publisher", @"title": @"Nhà xuất bản", @"tag": @2, @"height": @35},
////                       @{@"key": @"events", @"title": @"Tuyển tập", @"tag": @2, @"height": @35},
//                   @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
//                   @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
////                       @{@"key": @"button_cell", @"tag": @4, @"height": @35},
//                   @{@"key": @"read_cell", @"tag": @6, @"height": @20},
//];

- (NSArray*)filter:(NSDictionary*)info relate:(BOOL)relate {
    NSArray * keys = relate ? [Information.check isEqualToString:@"1"] ? @[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
                       @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
                       @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
                       @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
                       @{@"key": @"button_cell", @"tag": @4, @"height": @35},
                       @{@"key": @"read_cell", @"tag": @6, @"height": @20},
    ] : @[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
          @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
          @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
//          @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
          @{@"key": @"button_cell", @"tag": @4, @"height": @35},
          @{@"key": @"read_cell", @"tag": @6, @"height": @20},
    ] : [Information.check isEqualToString:@"1"] ?
    @[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
                       @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
                       @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
                       @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
                       @{@"key": @"read_cell", @"tag": @6, @"height": @20},
    ] : @[@{@"key": @"header_cell", @"tag": @1, @"height": @44},
          @{@"key": @"category", @"title": @"Thể loại", @"tag": @2, @"height": @35},
          @{@"key": @"publish_time", @"title": @"Ngày upload", @"arrow": @"1", @"tag": @2, @"height": @35},
//          @{@"key": @"price", @"title": @"Giá mua lẻ", @"tag": @2, @"height": @35, @"unit": @" VND"},
          @{@"key": @"read_cell", @"tag": @6, @"height": @20},
    ];
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSDictionary * key in keys) {
        NSString * keying = [key getValueFromKey:@"key"];
        if ([info responseForKey:keying]) {
            NSMutableDictionary * dict = [NSMutableDictionary new];
            if ([info[keying] isKindOfClass:[NSArray class]]) {
                NSArray * tempArray = (NSArray*)info[keying];
                if([keying isEqualToString:@"author"]) {
                    dict[@"name"] = tempArray.count != 0 ? tempArray.count == 1 ? ((NSDictionary*)tempArray.firstObject)[@"name"] : @"Nhiều tác giả" : @"";
                } else {
                    dict[@"name"] = tempArray.count != 0 ? ((NSDictionary*)tempArray.firstObject)[@"name"] : @"";
                }
            } else {
                dict[@"name"] = [info getValueFromKey:keying];
            }
            dict[@"key"] = keying;
            dict[@"config"] = info[keying];
            dict[@"title"] = [key getValueFromKey:@"title"];
            dict[@"arrow"] = [[key getValueFromKey:@"arrow"] isEqualToString:@""] ? @"0" : @"1";
            dict[@"tag"] = key[@"tag"];
            dict[@"height"] = key[@"height"];
            dict[@"unit"] = [key getValueFromKey:@"unit"];
            if (![[dict getValueFromKey:@"name"] isEqualToString:@""]) {
                [tempArray addObject:dict];
            }
        } else {
            NSMutableDictionary * dict = [NSMutableDictionary new];
            dict[@"key"] = keying;
            dict[@"tag"] = key[@"tag"];
            dict[@"height"] = key[@"height"];
            [tempArray addObject:dict];
        }
    }
    return tempArray;
}

- (CGSize)sizeFor:(NSIndexPath*)indexPath {
    UICollectionViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"Book_Detail_Infor" owner:self options:nil] firstObject];
    
    UILabel * title = (UILabel*)[self withView:cell tag:1];
    title.text = [self->config getValueFromKey:@"name"];
    
    NSString * authorName = [self->config[@"author"] firstObject][@"name"];
    UILabel * author = (UILabel*)[self withView:cell tag:2];
    author.text = authorName;
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = 0;
    
    CGSize targetSize = CGSizeMake(width, height);
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority: UILayoutPriorityDefaultHigh verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    
    return size;
}

- (CGSize)sizeForRating:(NSIndexPath*)indexPath {
    UICollectionViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"Book_Rating_Cell" owner:self options:nil] firstObject];
    
    UILabel * title = (UILabel*)[self withView:cell tag:2];
    NSDictionary * rating = ratingList[indexPath.item];
    title.text = [rating getValueFromKey:@"rating_content"];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = 0;
    
    CGSize targetSize = CGSizeMake(width, height);
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority: UILayoutPriorityDefaultHigh verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    
    return size;
}

- (CGSize)sizeForBio:(NSIndexPath*)indexPath {
    UICollectionViewCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"Author_Bio_Cell" owner:self options:nil] firstObject];
    
    UILabel * title = (UILabel*)[self withView:cell tag:1];
    title.text = self->bioString;
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat width = collectionView.frame.size.width;
    CGFloat height = 0;
    
    CGSize targetSize = CGSizeMake(width, height);
    
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:targetSize withHorizontalFittingPriority: UILayoutPriorityDefaultHigh verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
    
    return size;
}

- (BOOL)condition {
    return [Information.check isEqualToString:@"0"];
}

#pragma Collection

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 6;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section
{
    return section == 0 || section == 1 ? 1 : section == 2 ? detailList.count : section == 3 ? retract ? 0 : chapList.count > 1 ? chapList.count : 0 : section == 4 ? ratingList.count : dataList.count;
}

- (CGSize)collectionView:(UICollectionView *)_collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? [self sizeFor:indexPath] : indexPath.section == 1 ? [self sizeForBio:indexPath] : indexPath.section == 2 ? CGSizeMake(_collectionView.frame.size.width, detailList.count == 0 ? 0 : [[((NSDictionary*)detailList[indexPath.item]) getValueFromKey:@"height"] doubleValue]) : indexPath.section == 3 ? CGSizeMake(_collectionView.frame.size.width, 65) : indexPath.section == 4 ? [self condition] ? CGSizeMake(0, 0) : [self sizeForRating:indexPath] : CGSizeMake((screenWidth1 / (IS_IPAD ? 5 : 3)) - 15, ((screenWidth1 / (IS_IPAD ? 5 : 3)) - 15) * 1.72);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return section == 5 ? UIEdgeInsetsMake(0, 5, 0, 5) : UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:indexPath.section == 0 ? @"Book_Detail_Infor" : indexPath.section == 1 ? @"Author_Bio_Cell" : indexPath.section == 2 ? @"Book_Detail_Option_Cell" : indexPath.section == 3 ? @"TG_Book_Chap_Cell" : indexPath.section == 4 ? @"Book_Rating_Cell" : @"TG_Map_Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
                
        UILabel * title = (UILabel*)[self withView:cell tag:1];
        title.text = [self->config getValueFromKey:@"name"];
        
        NSString * authorName = [self->tempInfo[@"author"] firstObject][@"name"];
        UILabel * author = (UILabel*)[self withView:cell tag:2];
        author.text = authorName;
        
        CosmosView * rate = (CosmosView*)[self withView:cell tag: 3];
        rate.rating = [[self->tempInfo getValueFromKey:@"rating"] isEqualToString:@""] ? 0 : [[self->tempInfo getValueFromKey:@"rating"] doubleValue];
        
        [rate actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            if ([self condition]) {
                return;
            }
            
            [[[EM_MenuView alloc] initWithRate:@{}] disableCompletion:^(int index, id object, EM_MenuView *menu) {
                if (index == 3) {
                    [self didRequestComment:object andMenu:menu];
                }
            }];
        }];
                                        
        UIButton * viewCount = [self withView:cell tag: 4];
        [viewCount setImage:[UIImage imageNamed:@"ic_listen"] forState: UIControlStateNormal];
        [viewCount setTitle:[self->tempInfo getValueFromKey:@"read_count"] forState: UIControlStateNormal];
        
        UIButton * likeCount = [self withView:cell tag: 5];
        [likeCount setTitle:[self->tempInfo getValueFromKey:@"like_count"] forState: UIControlStateNormal];
        BOOL likeStatus = [[self->tempInfo getValueFromKey:@"like_status"] isEqualToString:@"1"];
        [likeCount setImage: likeStatus ? [[UIImage imageNamed:@"ico_like"] imageWithTintColor:[UIColor systemPinkColor]] : [UIImage imageNamed:@"ico_like"]
                forState:UIControlStateNormal];
        [likeCount actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            if ([self condition]) {
                return;
            }
            [self senderdidRequestLike:nil];
        }];
        
        UIButton * commentCount = [self withView:cell tag: 6];
        [commentCount setTitle:[self->tempInfo getValueFromKey:@"comment_count"] forState: UIControlStateNormal];
        
        [commentCount actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            if ([self condition]) {
                return;
            }
            PC_FeedBack_ViewController * rating = [PC_FeedBack_ViewController new];
            NSDictionary * tempo = [[NSDictionary alloc] initWithDictionary:self->tempInfo];
            rating.config = tempo;
            rating.callBack  = ^(NSDictionary* info) {
                NSMutableDictionary * tempConfig = [[NSMutableDictionary alloc] initWithDictionary:self->tempInfo];

                tempConfig[@"comment_count"] = [info getValueFromKey:@"comment_count"];
                            
                self->tempInfo = tempConfig;
                            
                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            };
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:rating];
            nav.navigationBarHidden = YES;
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
    
    if (indexPath.section == 1) {
        UILabel * title = [self withView:cell tag: 1];

        title.text = bioString;
        
        bioHeight = [title sizeOfMultiLineLabel].height;
    }
    
    if (indexPath.section == 2) {
        NSDictionary * detail = detailList[indexPath.item];

        NSString * tag = [detail getValueFromKey:@"tag"];
        
        if ([tag isEqualToString:@"1"]) {
             for (UIView * v in cell.contentView.subviews) {
                 v.hidden = v.tag != 1;
             }
        }
         
        if ([tag isEqualToString:@"2"]) {
            UILabel * title = [self withView:cell tag: 2];
            title.text = [detail getValueFromKey:@"title"];
 
            UILabel * description = [self withView:cell tag: 3];
            description.text = [NSString stringWithFormat:@"%@%@", [detail getValueFromKey:@"name"], [detail getValueFromKey:@"unit"]];
             
             for (UIView * v in cell.contentView.subviews) {
                 v.hidden = v.tag != 2 && v.tag != 3;
             }
         }
         
        if ([tag isEqualToString:@"4"]) {
            for (UIView *v in cell.contentView.subviews) {
                v.hidden = v.tag != 4 && v.tag != 5;
            }
            UIButton * readOrListen = [self withView:cell tag: 4];
            readOrListen.hidden = [self->tempInfo[@"related"] isEqual:[NSNull null]];
            [readOrListen setImage:[UIImage imageNamed:@"ico_reading"] forState:UIControlStateNormal];
            [readOrListen setTitle:@"Đọc Ebook" forState:UIControlStateNormal];
            [readOrListen setTitleColor:[AVHexColor colorWithHexString:@"#1E928C"] forState:UIControlStateNormal];
            [readOrListen actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                [self didRequestReaderContent];
            }];
            UIButton * purchase = [self withView:cell tag: 5];
            purchase.hidden = [[self->tempInfo getValueFromKey:@"price"] isEqualToString:@"0"] || [Information.check isEqualToString:@"0"];
//            purchase.hidden = [Information.check isEqualToString:@"0"];
            [purchase actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                [self didRequestItemInfo:self->tempInfo];
            }];
         }
         
        if ([tag isEqualToString:@"6"]) {
            UIButton * read = [self withView:cell tag: 6];
            [read actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            }];
             for (UIView * v in cell.contentView.subviews) {
                 v.hidden = YES;
             }
         }
    }
    
    if (indexPath.section == 3) {
        NSDictionary * chap = chapList[indexPath.item];

        ((UILabel*)[self withView:cell tag:1]).text = [chap getValueFromKey:@"name"];
        
        ((UILabel*)[self withView:cell tag:2]).text = [NSString stringWithFormat:@"%@ chữ Cập nhật %@", [chap getValueFromKey:@"total_character"], [chap getValueFromKey:@"publish_time"]];
        
        ((UILabel*)[self withView:cell tag:2]).text = [NSString stringWithFormat:@"Cập nhật %@", [chap getValueFromKey:@"publish_time"]];
    }
    
    if (indexPath.section == 4) {
        NSDictionary * rating = ratingList[indexPath.item];

        [((UIImageView*)[self withView:cell tag:1]) imageUrlHolderWithUrl:[rating getValueFromKey:@"avatar"] holder:@"ic_avatar"];

        ((UILabel*)[self withView:cell tag:2]).text = [rating getValueFromKey:@"user_name"];
        
        CosmosView * rate = (CosmosView*)[self withView:cell tag: 3];
        rate.rating = [[rating getValueFromKey:@"rating"] isEqualToString:@""] ? 0 : [[rating getValueFromKey:@"rating"] doubleValue];
                                       
        ((UILabel*)[self withView:cell tag:4]).text = [rating getValueFromKey:@"rating_content"];
    }
    
    if (indexPath.section == 5) {
        NSDictionary * book = dataList[indexPath.item];

        ((UILabel*)[self withView:cell tag:112]).text = [book getValueFromKey:@"name"];

        ((UILabel*)[self withView:cell tag:13]).text = ((NSArray*)book[@"author"]).count > 1 ? @"Nhiều tác giả" : book[@"author"][0][@"name"];

        [((UIImageView*)[self withView:cell tag:11]) imageUrlWithUrl:[book getValueFromKey:@"avatar"]];

        ((UIImageView*)[self withView:cell tag:999]).hidden = ![[book getValueFromKey:@"book_type"] isEqualToString:@"3"];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)_collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
        UILabel * title = [self withView:cell tag: 1];
        showMore = !showMore;
        bioString = [self iniBio:showMore];
        title.text = bioString;
        bioHeight = [title sizeOfMultiLineLabel].height;
        [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
        [self adjustInset];
    }
    
    if (indexPath.section == 3) {
        NSDictionary * chap = chapList[indexPath.item];
        config = chap;
        retract = NO;
        [self didRequestContent];
    }
    
    if (indexPath.section == 5) {
        NSDictionary * book = dataList[indexPath.item];
        if ([[book getValueFromKey:@"book_type"] isEqualToString:@"3"]) {
            [self didrequestLogTime];
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
    
    if (indexPath.section == 5) {
        UIView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Book_Detail_Gap" forIndexPath:indexPath];

        return view;
    }
    UIView * view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Book_Detail_Chap_Header" forIndexPath:indexPath];
    
    ((UILabel*)[self withView:view tag: 1]).text = indexPath.section == 3 ? [NSString stringWithFormat:@"NGHE EBOOK (%lu CHƯƠNG)", (unsigned long)chapList.count] : [NSString stringWithFormat:@"ĐÁNH GIÁ (%i)", totalRateCount];
    
    if (indexPath.section == 3) {
        double angle = retract ? 0 : M_PI;
        ((UILabel*)[self withView:view tag: 99]).hidden = YES;
        UIButton * arr = (UIButton*)[self withView:view tag: 3];
        UIButton * arr_r = (UIButton*)[self withView:view tag: 4];
        arr.hidden = NO;
        arr_r.hidden = YES;
        arr.transform = CGAffineTransformMakeRotation(angle);
        [arr setBackgroundImage:[UIImage imageNamed:@"ico_arrow_teal"] forState:UIControlStateNormal];
        view.backgroundColor = [AVHexColor colorWithHexString:@"#F0F0EC"];
        [view actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            retract = !retract;
            [self->collectionView performBatchUpdates:^{
                [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:3]];
            } completion:^(BOOL finished) {
                [self adjustInset];
            }];
        }];
    } else {
        ((UILabel*)[self withView:view tag: 99]).hidden = NO;
        UIButton * arr = (UIButton*)[self withView:view tag: 3];
        UIButton * arr_r = (UIButton*)[self withView:view tag: 4];
        arr.hidden = YES;
        arr_r.hidden = NO;
        [arr_r setBackgroundImage:[UIImage imageNamed:@"ico_arrow_teal_r"] forState:UIControlStateNormal];
        view.backgroundColor = [UIColor whiteColor];
        [view actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            Rating_ViewController * rating = [Rating_ViewController new];
            NSDictionary * tempo = [[NSDictionary alloc] initWithDictionary:self->tempInfo];
            rating.config = tempo;
            rating.ratingMode = @"audio";
            rating.callBack  = ^(NSDictionary* info) {
                self->tempInfo[@"rating"] = [info getValueFromKey:@"rating"];
                [self->collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
                [self didRequestRating];
            };
            UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:rating];
            nav.navigationBarHidden = YES;
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
    
    return view;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.frame.size.width, section == 3 ? chapList.count <= 1 ? 0 : 55 : section == 4 ? [self condition] ? 0 : 55 : section == 5 ? 40 : 0);
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 5) {
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
