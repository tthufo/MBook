//
//  M_Detail_ViewController.m
//  Music
//
//  Created by thanhhaitran on 11/25/15.
//  Copyright © 2015 thanhhaitran. All rights reserved.
//

#import "M_Detail_ViewController.h"

@interface M_Detail_ViewController ()
{
    NSMutableArray * dataList;
    
    IBOutlet UITableView * tableView;
    
    IBOutlet UIView * topView;
    
    UIBarButtonItem * rightButton, * leftButton;
    
    BOOL isEdit;
}

@end

@implementation M_Detail_ViewController

@synthesize playListName, titleName, delegate;

- (void)didReloadData
{
    [self reAddData];
    
    [tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reAddData];
    
    if(isEdit)
    {
        rightButton.title = ![self isHasDelete] ? @"Done" : @"Remove";
        
        rightButton.action = ![self isHasDelete] ? @selector(didPressEdit:) :  @selector(didPressRemove);
        
        if([self isHasDelete])
        {
            self.navigationItem.leftBarButtonItem = leftButton;
        }
        else
        {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
    
    [tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if([self isMovingFromParentViewController])
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(didReloadPlayList:)])
        {
            [self.delegate didReloadPlayList:@{}];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = topView;
    
    [(UIButton*)[self withView:topView tag:11] setTitle:titleName forState:UIControlStateNormal];
    
    [(UIButton*)[self withView:topView tag:11] addTapTarget:self action:@selector(didPressTitle:)];

    [self didEmbed];
    
    dataList = [NSMutableArray new];
    
    [self reAddData];
    
    rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleDone target:self action:@selector(didPressEdit:)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(didPressDone:)];
    
    [tableView reloadData];
    
//    [self didShowAdsBanner];
    
    [self adsAction];
}

- (void)didPressTitle:(UIButton*)sender
{
    if(isEdit)
    {
        return;
    }
    
    [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),*/@"text":sender.titleLabel.text,@"cancel":@"Cancel",@"buttons":@[@"Rename"],@"option":@(0),@"title":@"New playlist",@"message":@"Please enter new playlist name"} andCompletion:^(int indexButton, id object) {
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
                        [List modifyList:sender.titleLabel.text newName:object[@"uName"]];
                        
                        [(UIButton*)[self withView:topView tag:11] setTitle:object[@"uName"] forState:UIControlStateNormal];
                        
                        playListName = object[@"uName"];

                        [self reAddData];
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

- (void)reAddData
{
    [dataList removeAllObjects];
    
    for(Item * item in [Item getFormat:@"name=%@" argument:@[playListName]])
    {
        NSMutableDictionary * dict = [NSMutableDictionary new];
        
        dict[@"item"] = item;
        
        dict[@"active"] = @"";
        
        [dataList addObject:dict];
    }
}

- (void)didPressEdit:(UIBarButtonItem*)sender
{
    if(dataList.count == 0) return;
    
    isEdit =! isEdit;
    
    sender.title = isEdit ? @"Done" : @"Edit";
    
    if([self isHasDelete])
    {
        rightButton.title = @"Remove";
        
        rightButton.action = @selector(didPressRemove);
    }
    
    [tableView reloadDataWithAnimation:YES];
    
    [self adsAction];
}

#pragma TableView

-(NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"CellView" owner:self options:nil][2];
    }
    
    NSDictionary * list = dataList[indexPath.row];
    
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:((Item*)list[@"item"]).data];
        
    [((UIImageView*)[self withView:cell tag:11]) sd_setImageWithURL:[NSURL URLWithString:[[dict getValueFromKey:@"artwork_url"] stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) return;
        if (image && cacheType == SDImageCacheTypeNone)
        {
            [UIView transitionWithView:((UIImageView*)[self withView:cell tag:11])
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [((UIImageView*)[self withView:cell tag:11]) setImage:image];
                            } completion:NULL];
        }
    }];
    
 
    ((UILabel*)[self withView:cell tag:12]).text = ((NSString*)[dict getValueFromKey:@"title"]).length == 0 ? @"No description" : [(NSString*)[dict getValueFromKey:@"title"] substringToIndex:((NSString*)[dict getValueFromKey:@"title"]).length > 60 ? 55 : ((NSString*)[dict getValueFromKey:@"title"]).length - 0];
    
    ((UILabel*)[self withView:cell tag:10]).text = [self duration: [dict[@"duration"] ? dict[@"duration"] : @"0" intValue] / 1];
    
    ((UILabel*)[self withView:cell tag:14]).text = ![dict responseForKey:@"description"] ? @"No Description" : ((NSString*)dict[@"description"]).length == 0 ? @"---": dict[@"description"];

    ((UILabel*)[self withView:cell tag:12]).text = ![dict responseForKey:@"title"] ? @"No Title" : ((NSString*)dict[@"title"]).length == 0 ? @"---": dict[@"title"];

    ((UIButton*)[self withView:cell tag:9]).hidden = !isEdit;
    
    [((UIButton*)[self withView:cell tag:9]) setImage:[UIImage imageNamed:[list[@"active"] boolValue] ? @"check_ac" : @"check_in"] forState:UIControlStateNormal];
    
    [((UIButton*)[self withView:cell tag:9]) addTapTarget:self action:@selector(didPressSelect:)];

    return cell;
}

- (void)didPressSelect:(UIButton*)sender
{
    int indexing = [self inDexOf:sender andTable:tableView];
    
    dataList[indexing][@"active"] = [dataList[indexing][@"active"] boolValue] ? @"0" : @"1";
    
    rightButton.title = ![self isHasDelete] ? @"Done" : @"Remove";
    
    rightButton.action = ![self isHasDelete] ? @selector(didPressEdit:) :  @selector(didPressRemove);
    
    if([self isHasDelete])
    {
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    else
    {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    [tableView reloadData];
}

- (void)didPressDone:(UIBarButtonItem*)sender
{
    self.navigationItem.leftBarButtonItem = nil;
    
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSMutableDictionary * dict in dataList)
    {
        dict[@"active"] = @"0";
        
        [arr addObject:dict];
    }
    
    [dataList removeAllObjects];
    
    [dataList addObjectsFromArray:arr];
    
    rightButton.action = @selector(didPressEdit:);
    
    [self didPressEdit:rightButton];
}

- (void)didPressRemove
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"active"] boolValue])
        {
            [arr addObject:dict[@"item"]];
        }
    }
    
    [Item clearItems:arr];
    
    [self reAddData];
    
    rightButton.title = dataList.count ==0 ? @"Edit" : @"Done";
    
    rightButton.action = @selector(didPressEdit:);
    
    self.navigationItem.leftBarButtonItem = nil;
    
    [tableView reloadDataWithAnimation:YES];
    
    [self adsAction];
}

- (BOOL)isHasDelete
{
    BOOL found = NO;
    
    for(NSDictionary * dict in dataList)
    {
        if([dict[@"active"] boolValue])
        {
            found = YES;
            
            break;
        }
    }
    
    return found;
}

- (void)didPressDeleteList:(UIButton*)sender
{
//    [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Delete"],@"title":@"Attention",@"message":@"Delete this playlist will remove all saved songs, do you want to continue?"} andCompletion:^(int indexButton, id object) {
//        switch (indexButton)
//        {
//            case 0:
//            {
//                [Item clearFormat:@"name=%@" argument:@[sender.accessibilityLabel]];
//                
//                [List removeValue:sender.accessibilityLabel];
//                
//                [listData removeAllObjects];
//                
//                [listData addObjectsFromArray:[List getAll]];
//                
//                [tableView reloadData];
//                
//                if(listData.count == 0)
//                {
//                    isAdd =! isAdd;
//                    
//                    rightButton.title = isAdd ? @"Done" : @"Edit";
//                    
//                    [tableView reloadData];
//                }
//            }
//                break;
//            default:
//                break;
//        }
//    }];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(isEdit)
    {
        return;
    }
    
    if(![[LTRequest sharedInstance] isConnectionAvailable])
    {
        [self showToast:@"Please check your Internet Connection" andPos:0];
        
        return;
    }
    
    NSDictionary * list = dataList[indexPath.row];
    
    NSDictionary * dict = [NSKeyedUnarchiver unarchiveObjectWithData:((Item*)list[@"item"]).data];
    
    NSMutableDictionary * info = [[NSMutableDictionary alloc] initWithDictionary:dict];
    
    UITableViewCell * cell = [_tableView cellForRowAtIndexPath:indexPath];

    info[@"img"] = ((UIImageView*)[self withView:cell tag:11]).image ? ((UIImageView*)[self withView:cell tag:11]).image : kAvatar;
    
    if([[dict getValueFromKey:@"id"] isEqualToString:[self PLAYER].uID] && [self PLAYER].playState == Search)
    {
        [self PLAYER].playState = Search;
        
        [[self ROOT] goUp];
        
        return;
    }
    
    [self startPlaying:[dict getValueFromKey:@"id"] andInfo:info];
    
    [[self PLAYER] updateAll:playListName];
    
    [[self PLAYER] initAvatar:[dict getValueFromKey:@"artwork_url"]];
    
    [self didEmbed];
    
    [self adsAction];
    
    [self PLAYER].playState = Search;
}

- (void)adsAction
{
    if(![self getValue:@"detailAds"])
    {
        [self addValue:@"1" andKey:@"detailAds"];
    }
    else
    {
        int k = [[self getValue:@"detailAds"] intValue] + 1 ;
        
        [self addValue:[NSString stringWithFormat:@"%i", k] andKey:@"detailAds"];
    }
    
    if([[self getValue:@"detailAds"] intValue] % 6 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
}

- (void)didShowAdsBanner
{
   
}

- (void)presentAds
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
