//
//  TT_Synced_ViewController.m
//  Trending
//
//  Created by thanhhaitran on 8/24/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "TT_Synced_ViewController.h"

#import "MBCircularProgressBarView.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "EM_MenuView.h"

#import "M_Detail_ViewController.h"

@interface TT_Synced_ViewController ()<DetailDelegate>
{
    IBOutlet UITableView * tableView, * playList;
    
    IBOutlet UISegmentedControl * control;
    
    NSMutableArray * listData;
    
    UIBarButtonItem * rightButton, * leftButton;
    
    int activeIndex, activeSection;
    
    BOOL isList, isAdd;
}

@end

@implementation TT_Synced_ViewController

- (void)didReloadPlayList:(NSDictionary*)dict
{
    [listData removeAllObjects];
    
    [listData addObjectsFromArray:[List getAll]];
    
    [playList reloadData];
    
    [self didEmbed];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didEmbed];
    
    [tableView reloadData];
    
    [playList reloadData];
    
    [self adsAction];
}

- (void)didReloadData
{
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = control;
    
    leftButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"space"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(didPressInfo)];
    
    rightButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:[[self getValue:@"ipod"] boolValue] ? @"mobile_ac" : @"mobile_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(didPressIpod:)];

    
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.3"))
    {
        if([MPMediaLibrary authorizationStatus] != MPMediaLibraryAuthorizationStatusAuthorized)
        {
            rightButton.image = [[UIImage imageNamed:@"mobile_in"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
        }
    }
    
    rightButton.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
//    if([[self getObject:@"adsInfo"][@"itune"] boolValue])
    {
        self.navigationItem.leftBarButtonItems = @[leftButton];
    }
    
    self.navigationItem.rightBarButtonItems = @[rightButton];
    
    [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:@"itemCell"];
    
    [tableView registerNib:[UINib nibWithNibName:@"TT_Sync_Header" bundle:nil] forHeaderFooterViewReuseIdentifier:@"syncHeader"];
    
    [playList withCell:@"TT_List_Cell"];
    
    [self didChangeMode:0];
    
    listData = [NSMutableArray new];
    
    [listData addObjectsFromArray:[List getAll]];
    
    [playList reloadData];
    
    [self didEmbed];
}

- (void)didPressIpod:(UIBarButtonItem*)button
{
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.3"))
    {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            switch (status) {
                case MPMediaLibraryAuthorizationStatusNotDetermined:
                    
                    break;
                case MPMediaLibraryAuthorizationStatusAuthorized:
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self initIpod:button];
                    }];
                }
                    break;
                case MPMediaLibraryAuthorizationStatusDenied:
                    case MPMediaLibraryAuthorizationStatusRestricted:
                {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self showToast:@"Media Library permissions denied! Please go to Settings and allow media access" andPos:0];
                    }];
                }
                    break;
                default:
                    break;
            }
        }];
    }
    else
    {
        [self initIpod:button];
    }
}

- (void)initIpod:(UIBarButtonItem*)button
{
    if(![[self getValue:@"ipod"] boolValue])
    {
        [[DownloadManager share] mergeIpod];
    }
    else
    {
        [[DownloadManager share] unmergeIpod];
    }
    
    button.image = [[UIImage imageNamed:[[self getValue:@"ipod"] boolValue] ? @"mobile_in" : @"mobile_ac"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] ;
    
    [self addValue:[[self getValue:@"ipod"] boolValue] ? @"0" : @"1" andKey:@"ipod"];
    
    [tableView reloadDataWithAnimation:YES];
}

- (void)didChangeMode:(int)mode
{
    tableView.hidden = mode == 1;
    
    playList.hidden = mode == 0;
    
    if(isAdd)
    {
        [self didPressEditList:rightButton];
    }
    
    [self isRecentOrPlayList:mode == 0];
    
    if(mode == 1)
    {
        [listData removeAllObjects];
        
        [listData addObjectsFromArray:[List getAll]];
        
        [playList reloadData];
    }
    
    isList = mode == 1;
    
    if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
    {
        [leftButton setEnabled:mode == 1];
        
        leftButton.image = [[UIImage imageNamed:mode == 1 ? @"addon" :@"trans"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
}

- (IBAction)didPressSegment:(UISegmentedControl*)segment_
{
    [self didChangeMode:segment_.selectedSegmentIndex];
    
    [playList reloadData];

    [tableView reloadData];
}

- (void)isRecentOrPlayList:(BOOL)isRecent
{
    rightButton.action = isRecent ? @selector(didPressIpod:) : @selector(didPressEditList:);
    
    leftButton.action = !isRecent ? @selector(didAddList) : @selector(didPressInfo);
    
    leftButton.image = [[UIImage imageNamed:!isRecent ? @"addon" : @"space"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    rightButton.image = [[UIImage imageNamed:isRecent ? [[self getValue:@"ipod"] boolValue] ? @"mobile_ac" : @"mobile_in" : isAdd ? @"done" : @"edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)didPressEditList:(UIBarButtonItem*)sender
{
    if(listData.count == 0) return;
    
    isAdd =! isAdd;
    
    rightButton.image = [[UIImage imageNamed: isAdd ? @"done" : @"edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [playList reloadData];
}

- (void)didAddList
{
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Add"],@"option":@(0),@"title":@"New playlist",@"message":@"Please enter new playlist name"} andCompletion:^(int indexButton, id object) {
        switch (indexButton)
        {
            case 0:
            {
                if(((NSString*)object[@"uName"]).length == 0)
                {
                    [self showToast:@"Please enter playlist name" andPos:0];
                }
                else
                {
                    NSArray * arr = [List getFormat:@"name=%@" argument:@[object[@"uName"]]];
                    
                    if(arr.count == 0)
                    {
                        [List addValue:object[@"uName"]];
                        
                        [listData removeAllObjects];
                        
                        [listData addObjectsFromArray:[List getAll]];
                        
                        [playList reloadData];
                    }
                    else
                    {
                        [self showToast:@"Playlist name is already exist, please try other one" andPos:0];
                    }
                }
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didPressDeleteList:(UIButton*)sender
{
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Delete"],@"title":@"Attention",@"message":@"Delete this playlist will remove all saved songs, do you want to continue?"} andCompletion:^(int indexButton, id object) {
        switch (indexButton)
        {
            case 0:
            {
                [Item clearFormat:@"name=%@" argument:@[sender.accessibilityLabel]];
                
                [List removeValue:sender.accessibilityLabel];
                
                [listData removeAllObjects];
                
                [listData addObjectsFromArray:[List getAll]];
                
                [tableView reloadData];
                
                if(listData.count == 0)
                {
                    isAdd =! isAdd;
                    
                    rightButton.image = [[UIImage imageNamed: isAdd ? @"done" : @"edit"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                    
                    [playList reloadData];
                }
            }
                break;
            default:
                break;
        }
    }];
}





- (void)didPressInfo
{
    [[[EM_MenuView alloc] initWithLogIn:@{@"sync":[self sizeOfFolder]}] show];
}

- (void)didPressMenu
{
    [[self ROOT] showLeftPanelAnimated:YES];
    
    [self adsAction];
}

- (void)adsAction
{
    if([[self autoIncrement:@"syncAds"] intValue] % 6 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
}

#pragma CollectionView

- (NSString *)sizeOfFolder
{
    unsigned long long int folderSize = 0;
    
    for(Records * r in [Records getAll])
    {
        NSString *file;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:r.name];
        
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:subPath error:nil];
        
        NSEnumerator *contentsEnumurator = [contents objectEnumerator];
        
        while (file = [contentsEnumurator nextObject])
        {
            NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[subPath stringByAppendingPathComponent:file] error:nil];
            folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
        }
    }
    
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    
    return folderSizeStr;
}

- (NSString*)sizeOfAsset:(NSString*)filePath
{
    NSURL *urlAsset = [NSURL URLWithString:filePath];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:urlAsset options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName: AVAssetExportPresetAppleM4A];
    CMTime half = CMTimeMultiplyByFloat64(exportSession.asset.duration, 1); exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, half);
    long long size = exportSession.estimatedOutputFileLength;
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

- (NSString *)sizeOfFile:(NSString *)filePath
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];
    
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    
    return fileSizeStr;
}

- (NSString*)filePath:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (![fileManager fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"]])
    {
        [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:name];
    
    if (![fileManager fileExistsAtPath:subPath])
    {
        [fileManager createDirectoryAtPath:subPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * finalPath = [subPath stringByAppendingPathComponent:name];
    
    return finalPath;
}

#pragma TableView

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return isList ? @[] : [alphabet order];
}

- (NSInteger)tableView:(UITableView *)tableView_ sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
    if(isList)
    {
        return 0;
    }
    
    NSInteger newRow = [self indexForFirstChar:title inArray:[alphabet order]];

    if(((NSArray*)[DownloadManager share].array[title]).count != 0)
    {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:0 inSection:newRow];
        
        [tableView_ scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
    return index;
}

- (NSInteger)indexForFirstChar:(NSString *)character inArray:(NSArray *)array
{
    NSUInteger count = 0;
    
    for (NSString *str in array)
    {
        if ([str hasPrefix:character])
        {
            return count;
        }
        count++;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView_ viewForHeaderInSection:(NSInteger)section
{
    if(isList)
    {
        return nil;
    }
    
    UIView * v = [tableView_ dequeueReusableHeaderFooterViewWithIdentifier:@"syncHeader"];
    
    ((UILabel*)[self withView:v tag:11]).text = [[DownloadManager share].array.allKeys order][section];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(isList)
    {
        return -1;
    }
    
    NSString * key = [[DownloadManager share].array.allKeys order][section];
    
    return ((NSArray*)[DownloadManager share].array[key]).count == 0 ? -1 : 25;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return isList ? 1 : [DownloadManager share].array.count;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if(isList)
    {
        return listData.count;
    }
    
    NSString * key = [[DownloadManager share].array.allKeys order][section];
    
    return ((NSArray*)[DownloadManager share].array[key]).count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isList)
    {
        return 65;
    }
    
    NSString * key = [[DownloadManager share].array.allKeys order][indexPath.section];
    
    BOOL isItem = [((NSArray*)[DownloadManager share].array[key])[indexPath.row] isKindOfClass:[MPMediaItem class]];

    DownLoad * pro = ((NSArray*)[DownloadManager share].array[key])[indexPath.row];
    
    return isItem ? 75 : [pro.downloadData[@"infor"][@"active"] boolValue] ? 115 : 75;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView == playList)
    {
        UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"TT_List_Cell"forIndexPath:indexPath];
        
        if(listData.count == 0 || !isList)
        {
            return cell;
        }
        
        List * list = (List*)listData[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).text = list.name;
        
        ((UILabel*)[self withView:cell tag:12]).text = list.date;
        
        ((UIButton*)[self withView:cell tag:14]).hidden = !isAdd;
        
        [((UIButton*)[self withView:cell tag:14]) addTapTarget:self action:@selector(didPressDeleteList:)];
        
        ((UIButton*)[self withView:cell tag:14]).accessibilityLabel = list.name;
        
        ((UILabel*)[self withView:cell tag:15]).text = [NSString stringWithFormat:@"%lu",(unsigned long)[Item getFormat:@"name=%@" argument:@[list.name]].count];
        
        return cell;
    }
    else
    {
        ItemCell * cell = (ItemCell*)[_tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
        
        if(isList)
        {
            return cell;
        }
        
        NSString * key = [[DownloadManager share].array.allKeys order][indexPath.section];
        
        UILabel * percentMb = ((UILabel*)[self withView:cell tag:17]);
        
        BOOL isItem = [((NSArray*)[DownloadManager share].array[key])[indexPath.row] isKindOfClass:[MPMediaItem class]];
        
        if(isItem)
        {
            MPMediaItem * list = ((NSArray*)[DownloadManager share].array[key])[indexPath.row];
            
            ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:@"ipod"];
            
            ((UILabel*)[self withView:cell tag:11]).text = [list valueForProperty:MPMediaItemPropertyTitle];

            percentMb.text = @"";
            
            ((UILabel*)[self withView:cell tag:14]).text = [list valueForProperty:MPMediaItemPropertyAlbumTitle];
            
            ((UILabel*)[self withView:cell tag:17]).text = [self duration:[[list valueForProperty:MPMediaItemPropertyPlaybackDuration] intValue]];
            
            ((UIButton*)[self withView:cell tag:20]).userInteractionEnabled = NO;
            
            [((UIButton*)[self withView:cell tag:20]) setImage:[UIImage imageNamed:@"mobile"] forState:UIControlStateNormal];
            
            ((MBCircularProgressBarView*)[self withView:cell tag:100]).hidden = YES;
            
            [((UIImageView*)[self withView:cell tag:10]) withBorder:@{@"Bwidth":@(2),@"Bcorner":@(33),@"Bhex":kColor}];
            
            ((UIView*)[self withView:cell tag:99]).hidden = YES;
            
            [((UIButton*)[self withView:cell tag:101]) setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            
            [((UIButton*)[self withView:cell tag:101]) addTarget:self action:@selector(didPressMenu:) forControlEvents:UIControlEventTouchUpInside];

            ((UIView*)[self withView:cell tag:8864]).hidden = YES;
            
            return cell;
        }
        else
        {
            DownLoad * pro = ((NSArray*)[DownloadManager share].array[key])[indexPath.row];
            
            MBCircularProgressBarView * progress = ((MBCircularProgressBarView*)[self withView:cell tag:100]);
            
            progress.accessibilityLabel = pro.downloadData[@"name"];
            
            
            if(pro.operationFinished)
            {
                [UIView animateWithDuration:0.8 animations:^{
                    
                    progress.hidden = pro.operationFinished;
                    
                    ((UIView*)[self withView:cell tag:99]).hidden = pro.operationFinished;
                    
                }];
                
                [((UIImageView*)[self withView:cell tag:10]) withBorder:@{@"Bwidth":@(2),@"Bcorner":@(33),@"Bhex":kColor}];
            }
            else
            {
                progress.hidden = pro.operationFinished;
                
                ((UIView*)[self withView:cell tag:99]).hidden = pro.operationFinished;
                
                [((UIImageView*)[self withView:cell tag:10]) withBorder:@{@"Bwidth":@(0),@"Bcorner":@(33)}];
            }
            
            
            [((UIButton*)[self withView:progress tag:1000]) addTapTarget:self action:@selector(didPressPause:)];

            
            [((UIButton*)[self withView:progress tag:1000]) setBackgroundImage:[[UIImage imageNamed: !pro.operationBreaked ? @"trans" : @"round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            
            
            ((UIButton*)[self withView:cell tag:1000]).accessibilityLabel = [NSString stringWithFormat:@"%i", indexPath.section];

            
            if(pro.operationBreaked)
            {
                [progress setValue:pro.percentComplete];
                
                percentMb.text = [NSString stringWithFormat:@"%i %@",(int)pro.percentComplete,@"%"];
            }
            else
            {
                [progress setValue:pro.percentComplete];
                
                [pro completion:^(int index, DownLoad *obj, NSDictionary *info) {
                    
                    if(index == -1)
                    {
                        [tableView reloadData];
                    }
                    
                    if(index == 99)
                    {
                        if([progress.accessibilityLabel isEqualToString:pro.downloadData[@"name"]])
                        {
                            [progress setValue:[info[@"percentage"] intValue]];
                            
                            if(!isItem)
                            {
                                percentMb.text = [NSString stringWithFormat:@"%i %@",(int)pro.percentComplete,@"%"];
                            }
                        }
                    }
                    
                    if(index == 0)
                    {
                        if([info responseForKey:@"done"])
                        {
                            [[DownloadManager share] queueDownloadAll];
                            
                            [((UIImageView*)[self withView:cell tag:10]) withBorder:@{@"Bwidth":@(2),@"Bcorner":@(33),@"Bhex":kColor}];
                            
                            [tableView reloadData];
                        }
                        
                        if([info responseForKey:@"reload"])
                        {
                            [self showToast:@"Server error, restarting download" andPos:0];
                            
                            NSDictionary * downloadInfo = pro.downloadData[@"infor"];
                            
                            [[DownloadManager share] replaceAll:[[DownLoad shareInstance] didProgress:@{@"url":pro.downloadData[@"url"],
                                                                                                     @"name":((Records*)[[Records getFormat:@"vid=%@" argument:@[[downloadInfo getValueFromKey:@"id"]]] lastObject]).name,
                                                                                                     @"cover":pro.downloadData[@"cover"],
                                                                                                     @"infor":downloadInfo}
                                                                                             andCompletion:^(int index, DownLoad *obj, NSDictionary *info) {
                                                                                                 
                                                                                             }] index:indexPath.row andSection:key];
                            [tableView reloadData];
                        }
                    }
                }];
            }
            
            
            if(!isItem)
            {
                percentMb.text = pro.operationFinished ? @"" : [NSString stringWithFormat:@"%i %@",(int)pro.percentComplete,@"%"];
            }
            
            [((UIButton*)[self withView:cell tag:20]) addTarget:self action:@selector(didPressDelete:) forControlEvents:UIControlEventTouchUpInside];

            [((UIButton*)[self withView:cell tag:20]) setImage:[UIImage imageNamed:@"garbage"] forState:UIControlStateNormal];
            
            ((UIButton*)[self withView:cell tag:20]).accessibilityLabel = [NSString stringWithFormat:@"%i", indexPath.section];

            ((UIButton*)[self withView:cell tag:20]).userInteractionEnabled = YES;

            
            
            NSDictionary * list = pro.downloadData[@"infor"];
            
            [((UIImageView*)[self withView:cell tag:10]) sd_setImageWithURL:[NSURL URLWithString:[list getValueFromKey:@"artwork_url"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) return;
                if (image && cacheType == SDImageCacheTypeNone)
                {
                    [UIView transitionWithView:((UIImageView*)[self withView:cell tag:10])
                                      duration:0.5
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [((UIImageView*)[self withView:cell tag:10]) setImage:image];
                                    } completion:NULL];
                }
            }];
            
            ((UILabel*)[self withView:cell tag:11]).text = ![list responseForKey:@"title"] ? @"No Title" : list[@"title"];

            ((UILabel*)[self withView:cell tag:14]).text = ![list responseForKey:@"description"] ? @"No Description" : [list getValueFromKey:@"description"];

            [((UIButton*)[self withView:cell tag:101]) setImage:[UIImage imageNamed:@"drop"] forState:UIControlStateNormal];
            
            [((UIButton*)[self withView:cell tag:101]) addTarget:self action:@selector(didPressMenu:) forControlEvents:UIControlEventTouchUpInside];
            
            [((UIButton*)[self withView:cell tag:101]).layer setAffineTransform:CGAffineTransformMakeScale(1, [list[@"active"] isEqualToString:@"0"] ? 1 : -1)];
            
            ((UIView*)[self withView:cell tag:8864]).hidden = [list[@"active"] isEqualToString:@"0"];
            
            
            
            [((DropButton*)[self withView:cell tag:102]) addTarget:self action:@selector(didPressAdd:) forControlEvents:UIControlEventTouchUpInside];

            ((UIButton*)[self withView:cell tag:102]).enabled = pro.operationFinished;
            
            [((UIButton*)[self withView:cell tag:103]) addTarget:self action:@selector(didPressDelete:) forControlEvents:UIControlEventTouchUpInside];

            [((UIButton*)[self withView:cell tag:104]) addTarget:self action:@selector(didPressShare:) forControlEvents:UIControlEventTouchUpInside];

            [((UIButton*)[self withView:cell tag:103]) setImage:[UIImage imageNamed:@"erase"] forState:UIControlStateNormal];
            
            return cell;
        }
    }
    return nil;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(isList)
    {
        M_Detail_ViewController * detail = [M_Detail_ViewController new];
        
        detail.delegate = self;
        
        detail.playListName = detail.titleName = ((List*)listData[indexPath.row]).name;
        
        [self.navigationController pushViewController:detail animated:YES];
        
        return;
    }
    
    NSString * key = [[DownloadManager share].array.allKeys order][indexPath.section];
    
    id  pro = ((NSArray*)[DownloadManager share].array[key])[indexPath.row];
    
    BOOL isIpod = [pro isKindOfClass:[MPMediaItem class]];
    
    if(!isIpod)
    {
        if(![((DownLoad*)pro).downloadData[@"finish"] boolValue])
        {
            return;
        }

        NSString * pressKey = [[DownloadManager share].array.allKeys order][indexPath.section];
        
        DownLoad * pro = ((NSArray*)[DownloadManager share].array[pressKey])[indexPath.row];
        
        UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];
        
        if([pro.downloadData[@"infor"][@"active"] boolValue])
        {
            [self didPressMenu:(UIButton*)[self withView:cell tag:101]];
        }
    }
    
    ItemCell * cell = (ItemCell*)[_tableView cellForRowAtIndexPath:indexPath];
    
    UIImageView * logoDisc = (UIImageView*)[self withView:cell tag:10];
    
    NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithDictionary: isIpod ? [self ipodItem:((MPMediaItem*)pro)] : ((DownLoad*)pro).downloadData[@"infor"]];
    
    data[@"img"] = logoDisc.image;
    
    if(!isIpod)
    {
        data[@"download"] = @(1);
        
        data[@"name"] = ((DownLoad*)pro).downloadData[@"name"];
    }
        
    if([(isIpod ? data[@"assetUrl"] : [data getValueFromKey:@"id"]) isEqualToString:[self PLAYER].uID] && [self PLAYER].playState == Search)
    {
        [self PLAYER].playState = Search;
   
        [[self ROOT] goUp];

        return;
    }
    
    [self PLAYER].playState = Search;
    
    [[self PLAYER].playerView pause];
    
    [self startPlaying: isIpod ? data[@"assetUrl"] : [data getValueFromKey:@"id"] andInfo: data];
    
    [[self PLAYER] initAvatar:[data getValueFromKey:@"artwork_url"]];
}

- (void)presentAds
{
  
}


#pragma mark Action

- (void)didPressMenu:(UIButton*)sender
{
    int pressIndex = [[tableView inForOf:sender andTable:tableView][@"index"] intValue];
    
    int pressSection = [[tableView inForOf:sender andTable:tableView][@"section"] intValue];
    
    
    NSString * pressKey = [[DownloadManager share].array.allKeys order][pressSection];
    
    NSString * activeKey = [[DownloadManager share].array.allKeys order][activeSection];
    
    
    BOOL isItem = [((NSArray*)[DownloadManager share].array[pressKey])[pressIndex] isKindOfClass:[MPMediaItem class]];
    
    if(isItem)
    {
        id pro = ((NSArray*)[DownloadManager share].array[pressKey])[pressIndex];
        
        [[self PLAYER] updateList:[self ipodItem:((MPMediaItem*)pro)]];
        
        return;
    }
    
    DownLoad * pro = ((NSArray*)[DownloadManager share].array[pressKey])[pressIndex];
    
    ((NSMutableDictionary*)pro.downloadData)[@"infor"][@"active"] = [((NSMutableDictionary*)pro.downloadData)[@"infor"][@"active"] isEqualToString:@"0"] ? @"1" : @"0" ;
    
    [sender.layer setAffineTransform:CGAffineTransformMakeScale(1, [((NSMutableDictionary*)pro.downloadData)[@"infor"][@"active"] isEqualToString:@"0"] ? -1 : 1)];
    
    
    if(((NSArray*)[DownloadManager share].array[pressKey]).count != 0)
    {
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:pressIndex inSection:pressSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    if(((NSArray*)[DownloadManager share].array[activeKey]).count != 0)
    {
        if(pressIndex != activeIndex || pressSection != activeSection)
        {
            id activePro = ((NSArray*)[DownloadManager share].array[activeKey])[activeIndex];
            
            if([activePro isKindOfClass:[DownLoad class]])
            {
                ((NSMutableDictionary*)((DownLoad*)activePro).downloadData)[@"infor"][@"active"] = @"0";
            }
        }
        
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:activeIndex inSection:activeSection]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    activeIndex = pressIndex;
    
    activeSection = pressSection;
}

- (void)didPressDelete:(UIButton*)sender
{
    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Remove"],@"title":@"Remove Synced Item",@"message":@"Do you want to remove this song ?"} andCompletion:^(int indexButton, id object) {
        switch (indexButton)
        {
            case 0:
            {
                int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
                
                int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
                
                NSString * key = [[DownloadManager share].array.allKeys order][section];
                
                DownLoad *  pro = ((NSArray*)[DownloadManager share].array[key])[indexing];
                
                if(!pro.operationBreaked)
                {
                    [pro forceStop];
                }
                
                NSString * folderPath = [NSString stringWithFormat:@"%@", [[self pathFile] stringByAppendingPathComponent:pro.downloadData[@"name"]]];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                
                [fileManager removeItemAtPath:folderPath error:NULL];
                
                [Records clearFormat:@"name=%@" argument:@[pro.downloadData[@"name"]]];
                
                [[DownloadManager share] removeAll:pro];
                
                [tableView reloadDataWithAnimation:YES];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didPressPause:(UIButton*)sender
{
    if(![self isConnectionAvailable])
    {
        [self showToast:@"Please check your Internet Connection" andPos:0];
        
        return;
    }
    
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
    
    NSString * key = [[DownloadManager share].array.allKeys order][section];
    
    DownLoad *  down = ((NSArray*)[DownloadManager share].array[key])[indexing];
    
    if(down.operationBreaked)
    {
        if(![[DownloadManager share] isAllowAll])
        {
            [self showToast:@"Download concurrent limited" andPos:0];
            
            return;
        }
        
        [down forceContinue];
        
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexing inSection:section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else
    {
        [down forceStop];
    }
    
    [sender setBackgroundImage:[[UIImage imageNamed: !down.operationBreaked ? @"trans" : @"round"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
}

- (void)didPressAdd:(DropButton*)sender
{
    [sender didDropDownWithData:@[@{@"title":@"Add To Playlist"},@{@"title":@"Add To Play Now"}] andCompletion:^(id object) {
        
        if(object)
        {
            int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
            
            int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];

            if([object[@"index"] intValue] == 0)
            {
                [self didPressFavorite:sender];
            }
            else
            {
                NSString * key = [[DownloadManager share].array.allKeys order][section];
            
                id pro = ((NSArray*)[DownloadManager share].array[key])[indexing];
            
                BOOL isItem = [pro isKindOfClass:[MPMediaItem class]];
            
                NSMutableDictionary * dict = [@{} mutableCopy];
            
                if(!isItem)
                {
                    [dict addEntriesFromDictionary:((DownLoad*)pro).downloadData[@"infor"]];
                    
                    dict[@"download"] = @(1);
                    
                    dict[@"name"] = ((DownLoad*)pro).downloadData[@"name"];
                }
                
                [[self PLAYER] updateList: isItem ? [self ipodItem:((MPMediaItem*)pro)] : dict];
            }
            
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
    
                [self didPressMenu:((UIButton*)[self withView:cell tag:101])];
        }
    }];
}

- (void)didPressFavorite:(UIButton*)sender
{
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];

    NSString * key = [[DownloadManager share].array.allKeys order][section];
    
    BOOL isItem = [((NSArray*)[DownloadManager share].array[key])[indexing] isKindOfClass:[MPMediaItem class]];
    
    id list = ((NSArray*)[DownloadManager share].array[key])[indexing];
    
    NSDictionary * dict = isItem ?  [self ipodItem:list] : ((DownLoad*)list).downloadData[@"infor"];
    
    [[[M_Menu alloc] initWithInfo:[@{@"window":[self WINDOW],@"data":[List getAll]} mutableCopy]] didShow:^(int index, M_Menu *menu, NSDictionary * info) {
        
        if(index == 1)
        {
            [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Cancel",@"buttons":@[@"Add"],@"option":@(0),@"title":@"New playlist",@"message":@"Please enter new playlist name"} andCompletion:^(int indexButton, id object) {
                switch (indexButton)
                {
                    case 0:
                    {
                        if(((NSString*)object[@"uName"]).length == 0)
                        {
                            [self showToast:@"Please enter playlist name" andPos:0];
                        }
                        else
                        {
                            NSArray * arr = [List getFormat:@"name=%@" argument:@[object[@"uName"]]];
                            
                            if(arr.count == 0)
                            {
                                [List addValue:object[@"uName"]];
                                
                                [playList reloadData];
                                
                                [Item addValue:dict andKey:[dict getValueFromKey:@"id"] andName:object[@"uName"]];
                                
                                [menu didClose];
                            }
                            else
                            {
                                [self showToast:@"Playlist name is already exist, please try other one" andPos:0];
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
        else if(index == 0)
        {
            [Item addValue:dict andKey:[dict getValueFromKey:@"id"] andName:info[@"data"]];
            
            [menu didClose];
        }
        else
        {
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
        }
    }];
}


- (void)didPressShare:(UIButton*)sender
{
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
    
    [self didPressMenu:((UIButton*)[self withView:cell tag:101])];
    
    NSString * key = [[DownloadManager share].array.allKeys order][section];
    
    DownLoad *  pro = ((NSArray*)[DownloadManager share].array[key])[indexing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
