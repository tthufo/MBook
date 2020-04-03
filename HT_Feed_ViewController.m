//
//  HT_Feed_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/11/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_Feed_ViewController.h"

#define ahihi @{@"1":@"new",@"2":@"popular",@"3":@"feed"}

@interface HT_Feed_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    int pageNo;
    
    BOOL isLoadMore;
    
    NSString * type;
}

@end

@implementation HT_Feed_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didEmbed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    type = @"feed";
    
//    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"waving"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPressType)];
//    
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    pageNo = 1;
    
    [tableView registerNib:[UINib nibWithNibName:@"ItemCell" bundle:nil] forCellReuseIdentifier:@"itemCell"];
    
    dataList = [NSMutableArray new];
    
    __block HT_Feed_ViewController * weakSelf  = self;
    
    [tableView addFooterWithBlock:^{
        
        [weakSelf didLoadMore];
        
    } withIndicatorColor:[UIColor grayColor]];
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didLoadMore];
        
    } withIndicatorColor:[UIColor grayColor]];
    
    [self didReload];
}

- (void)didPressType
{
    [[DropAlert shareInstance] actionSheetWithInfo:@{@"title":@"Your Mood",@"cancel":@"Cancel",@"buttons":@[@"New",@"Popular",@"Feed"]} andCompletion:^(int indexButton, id object) {
        
        self.title = [ahihi[[NSString stringWithFormat:@"%i", indexButton]] capitalizedString];
        
        type = ahihi[[NSString stringWithFormat:@"%i", indexButton]];
        
        [self didReload];
        
    }];
}

- (void)didReload
{
    isLoadMore = NO;
    
    pageNo = 1;
    
    [self didRequestData];
}

- (void)didLoadMore
{
    isLoadMore = YES;
    
    pageNo += 1;
    
    [self didRequestData];
}

- (void)didRequestData
{
    NSString * uri = [NSString stringWithFormat:@"https://api-v2.hearthis.at/%@/?page=%i&count=%@", type, pageNo, maxR];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[uri encodeUrl],@"method":@"GET",@"overrideError":@(1),@"host":self} withCache:^(NSString *cacheString) {
        
        if(cacheString.length != 0 && !isLoadMore)
        {
            [dataList removeAllObjects];
            
            NSDictionary * dict = [cacheString objectFromJSONString];
            
            [dataList addObjectsFromArray:[self reConstruct: dict[@"array"]]];
        }
        
        [tableView reloadData];
        
    } andCompletion:^(NSString *responseString, NSString* errorCode, NSError *error, BOOL isValidated, NSDictionary * object) {
        
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.5];
        
        [tableView headerEndRefreshing];
        
        if(isValidated)
        {
            NSDictionary * dict = [responseString objectFromJSONString];
            
            if(!isLoadMore)
            {
                [dataList removeAllObjects];
            }
            
            [dataList addObjectsFromArray:[self reConstruct: dict[@"array"]]];
        }
        
        if(!isLoadMore)
        {
            [tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        }
        
        [tableView reloadData];
        
    }];
}

- (NSMutableArray*)reConstruct:(NSArray*)array
{
    NSMutableArray * temp = [NSMutableArray new];
    
    for(id  dict in array)
    {
        if([dict isKindOfClass:[NSDictionary class]])
        {
            NSMutableDictionary * mute = [[NSMutableDictionary alloc] initWithDictionary:dict];
            
            mute[@"active"] = @"0";
            
            [temp addObject:mute];
        }
    }
    
    return temp;
}

#pragma TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [((NSDictionary*)dataList[indexPath.row])[@"active"] isEqualToString:@"0"] ? 75 : 115;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCell * cell = (ItemCell*)[_tableView dequeueReusableCellWithIdentifier:@"itemCell" forIndexPath:indexPath];
    
    NSDictionary * list = dataList[indexPath.row];
    
    [((UIImageView*)[self withView:cell tag:10]) sd_setImageWithURL:[NSURL URLWithString:[[list getValueFromKey:@"artwork_url"] stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
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
    
    ((UILabel*)[self withView:cell tag:12]).text = [[list[@"created_at"] ? list[@"created_at"] : @"" dateWithFormat:@"yyyy-MM-dd HH:mm:ss"] dateTimeAgo];
    
    ((UILabel*)[self withView:cell tag:14]).text = ![list responseForKey:@"description"] ? @"No Description" : [list getValueFromKey:@"description"];
    
    ((UILabel*)[self withView:cell tag:17]).text = [self duration: [list[@"duration"] ? list[@"duration"] : @"0" intValue] / 1];
    
    [((UIButton*)[self withView:cell tag:101]) addTarget:self action:@selector(didPressMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self withView:cell tag:101]).layer setAffineTransform:CGAffineTransformMakeScale(1, [list[@"active"] isEqualToString:@"0"] ? 1 : -1)];
    
    ((UIView*)[self withView:cell tag:8864]).hidden = [list[@"active"] isEqualToString:@"0"];
    
    
    
    [((DropButton*)[self withView:cell tag:102]) addTarget:self action:@selector(didPressAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self withView:cell tag:103]) addTarget:self action:@selector(didPressSync:) forControlEvents:UIControlEventTouchUpInside];
    
    [((UIButton*)[self withView:cell tag:104]) addTarget:self action:@selector(didPressShare:) forControlEvents:UIControlEventTouchUpInside];
    
    if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
    {
        ((UIButton*)[self withView:cell tag:103]).hidden = YES;
    }
    
    return cell;
}

- (void)didPressMenu:(UIButton*)sender
{
    int indexing = [self inDexOf:sender andTable:tableView];
    
    int index = 0;
    
    for(int i = 0; i< dataList.count; i++)
    {
        if([((NSDictionary*)dataList[i])[@"active"] isEqualToString:@"1"])
        {
            index = i;
        }
        
        ((NSMutableDictionary*)dataList[i])[@"active"] = i == indexing ? [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? @"1" : @"0" : @"0";
    }
    
    [sender.layer setAffineTransform:CGAffineTransformMakeScale(1, [((NSDictionary*)dataList[indexing])[@"active"] isEqualToString:@"0"] ? -1 : 1)];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexing inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    if([[self autoIncrement:@"menu123"] intValue] % 6 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([[self autoIncrement:@"cell123"] intValue] % 5 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
    
    if(![[LTRequest sharedInstance] isConnectionAvailable])
    {
        [self showToast:@"Please check your Internet Connection" andPos:0];
        
        return;
    }
    
    [[self ROOT] embed];
    
    NSDictionary * dict = dataList[indexPath.row];
    
    NSMutableDictionary * data = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    ItemCell * cell = (ItemCell*)[_tableView cellForRowAtIndexPath:indexPath];
    
    
    if([dataList[indexPath.row][@"active"] boolValue])
    {
        [self didPressMenu:(UIButton*)[self withView:cell tag:101]];
    }
    
    
    UIImageView * logoDisc = (UIImageView*)[self withView:cell tag:10];
    
    data[@"img"] = logoDisc.image;
    
    if([[dict getValueFromKey:@"id"] isEqualToString:[self PLAYER].uID] && [self PLAYER].playState == Search)
    {
        [self PLAYER].playState = Search;
        
        [[self ROOT] goUp];
        
        return;
    }
    
    [[self PLAYER].playerView pause];
    
    [self startPlaying:[dict getValueFromKey:@"id"] andInfo:data];
    
    [[self PLAYER] initAvatar:[dict getValueFromKey:@"artwork_url"]];
    
    [self PLAYER].playState = Search;
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

- (void)didPressSync:(UIButton*)sender
{
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
    
    [self didPressMenu:((UIButton*)[self withView:cell tag:101])];
    
    NSDictionary * pro = dataList[indexing];
    
    int count = [Records getFormat:@"vid=%@" argument:@[[pro getValueFromKey:@"id"]]].count;
    
    if(count > 0)
    {
        [self showToast:@"Already synced" andPos:0];
        
        return;
    }
    
    NSMutableDictionary * information = [[NSMutableDictionary alloc] initWithDictionary:pro];
    
    information[@"img"] = ((UIImageView*)[self withView:cell tag:10]).image;
    
    [self didStartSyncingWith:@{@"url":information[@"stream_url"],
                                @"cover":information[@"img"],
                                @"info":information
                                }];
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
                [[self PLAYER] updateList:dataList[indexing]];
            }
            
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
            
            [self didPressMenu:((UIButton*)[self withView:cell tag:101])];
        }
    }];
}

- (void)didPressFavorite:(UIButton*)sender
{
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];

    NSDictionary * dict = dataList[indexing];
    
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
                                
                                [Item addValue:dict andKey:[dict getValueFromKey:@"id"] andName:object[@"uName"]];
                                
                                [menu didClose];
                                
                                [self showToast:@"Song added to Playlist" andPos:0];
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
            
            [self showToast:@"Song added to Playlist" andPos:0];
        }
        else
        {
            UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:0]];
        }
    }];
}

- (void)didPressShare:(UIButton*)sender
{
    int indexing = [[self inForOf:sender andTable:tableView][@"index"] intValue];
    
    int section = [[self inForOf:sender andTable:tableView][@"section"] intValue];
    
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexing inSection:section]];
    
    [self didPressMenu:((UIButton*)[self withView:cell tag:101])];
    
    NSDictionary * pro = dataList[indexing];
}

- (void)presentAds
{
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
