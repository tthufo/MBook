//
//  Third_Tab_New_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 8/9/21.
//  Copyright © 2021 Thanh Hai Tran. All rights reserved.
//

#import "Third_Tab_New_ViewController.h"

#import "MeBook-Swift.h"

@interface Third_Tab_New_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIRefreshControl * refreshControl;
    
    IBOutlet Tag_View * tagView;
    
    IBOutlet UIImageView * searchBtn;
    
    IBOutlet UITextField * searchView;
    
    IBOutlet UIButton * buyBtn;

    IBOutlet UIButton * notiBtn;

    NSMutableArray * dataList;
    
    NSMutableDictionary * config;
    
    NSDictionary * userTag;
        
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore, isHot;
    
    float tempHeight;
    
    IBOutlet NSLayoutConstraint * buy_width;
}

@end

@implementation Third_Tab_New_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reLayout];

    searchView.text = Information.searchValue == nil ? @"" : Information.searchValue;
        
    if (![[Information.userInfo getValueFromKey: @"total_unread"]  isEqualToString:@"0"]) {
        notiBtn.badgeValue = [Information.userInfo getValueFromKey: @"total_unread"];
    } else {
        notiBtn.badgeValue = @"";
    }
    notiBtn.shouldHideBadgeAtZero = YES;
    notiBtn.badgeOriginX = 20;
    notiBtn.badgeOriginY = 5;
    
    [self didEmbed];
}

- (void)reLayout{
    buyBtn.hidden = Information.isVip;
    buyBtn.widthConstaint.constant = Information.isVip ? 0 : 44;
    buy_width.constant = Information.isVip ? 0 : 44;
    [self.view layoutIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userTag = @{@"book_type": @(0),
               @"cmd_code":@"getListBookPurchaseByUser",
                @"price": @(1)};
    
    tempHeight = 0;
    
    pageIndex = 1;
    
    totalPage = 1;
    
    isHot = YES;
    
    dataList = [NSMutableArray new];
    
    [tableView withCell: @"Book_List_Cell"];
    
    [tableView withCell: @"TG_Room_Cell_0"];

    refreshControl = [UIRefreshControl new];
    
    tableView.refreshControl = refreshControl;
    
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    
    [self didRequestData:YES];
    
    __weak typeof(self) weakSelf = self;

    tagView.callBack = ^(NSDictionary *infor) {
//        NSLog(@"%@", infor);
        if ([[infor getValueFromKey:@"action"] isEqualToString:@"custom"]) {
            ((HT_Root_ViewController*)[weakSelf TABBAR]).selectedIndex = 1;
        } else {
            userTag = infor;
            [weakSelf didReloadData];
        }
    };
    
    config = [@{
        @"title": @"EBOOK Mới Nhất", @"url": [@{
                @"CMD_CODE" : @"getListBook",
                @"page_index": @1,
                @"page_size": @24,
                @"book_type": @0,
                @"price": @0,
                @"sorting": @1 } mutableCopy],
        @"height": @0,
        @"directon": @"horizontal",
        @"loaded": @NO
    } mutableCopy];
    
    [searchBtn imageColorWithColor:[UIColor lightGrayColor]];
    
    [searchBtn actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self didPressSearch];
    }];
    
    [searchView addTarget:self action:@selector(textIsChanging:) forControlEvents:UIControlEventValueChanged];
}

- (void)textIsChanging:(UITextField*)textField {
    Information.searchValue = textField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [searchView resignFirstResponder];
    return YES;
}

- (void)didReloadData
{
    isLoadMore = NO;
    pageIndex = 1;
    totalPage = 1;
    [self didRequestData:YES];
}

- (void)didRequestData:(BOOL)isShow
{
    NSMutableDictionary * requestInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"header":@{@"session":Information.token == nil ? @"" : Information.token},
        @"page_index": @(pageIndex),
        @"page_size": @(12),
        @"overrideError":@"1",
        @"overrideLoading":@"1",
        @"host":self
    }];
    
    [requestInfo addEntriesFromDictionary:userTag];
    
    [[LTRequest sharedInstance] didRequestInfo:requestInfo withCache:^(NSString *cacheString) {
    } andCompletion:^(NSString *responseString, NSString* errorCode, NSError *error, BOOL isValidated, NSDictionary * object) {
        
        [refreshControl endRefreshing];
        
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.5];
                        
        if(isValidated)
        {
            NSDictionary * dict = [responseString objectFromJSONString];
            
            if (![dict[@"result"] isEqual:[NSNull null]]) {
            
                totalPage = [dict[@"result"][@"total_page"] intValue];
                  
                pageIndex += 1;
                  
                if(!isLoadMore)
                {
                    [dataList removeAllObjects];
                }
                
                [dataList addObjectsFromArray:[self filterArrayWithData: dict[@"result"][@"data"]]];
            } else {
                [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
            }
        }
        
        [tableView reloadData];
        
    }];
}

- (NSDictionary *)removeKey:(NSMutableDictionary *)info {
    [(NSMutableDictionary*)info[@"url"] removeObjectsForKeys:@[@"page_index", @"page_size"]];
    return info;
}

- (IBAction)didPressMenu:(id)sender {
    [self.view endEditing:YES];
    [[self ROOT] toggleLeftPanel:sender];
}

- (IBAction)didPressNoti:(id)sender {
    [self.view endEditing:YES];
    [[self CENTER] pushViewController: [PC_Notification_ViewController new] animated:YES];
}

- (IBAction)didPressBuy:(id)sender {
    VIP_ViewController * vip = [VIP_ViewController new];
    vip.callBack = ^(NSDictionary *infor) {
//        NSLog(@"%@", infor);
    };
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vip];
    nav.navigationBarHidden = YES;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self CENTER] presentViewController:nav animated:YES completion:nil];
}

- (void)didPressSearch {
    Search_ViewController * search = [Search_ViewController new];
    search.config = @{@"search": searchView.text};
    [[self CENTER] pushViewController:search animated:YES];
}

#pragma TableView


- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: @"Book_List_Cell" forIndexPath:indexPath];
        
    NSDictionary * list = dataList[indexPath.row];
    
    UIView * bg = (UIView*)[self withView:cell tag:100];
    
    UIImageView * booking = (UIImageView*)[self withView:cell tag:1];
    
    UIImageView * covering = (UIImageView*)[self withView:cell tag:22];

    [booking imageUrlWithUrl: [list getValueFromKey:@"avatar"]];
    
    booking.widthConstaint.constant = [bg bookWidth];
 
    bg.widthConstaint.constant = [bg bookWidth];

    covering.widthConstaint.constant = [bg bookWidth];

    booking.heightConstaint.constant = [bg bookHeight];
    
    bg.heightConstaint.constant = [bg bookHeight];
        
    covering.heightConstaint.constant = [bg bookHeight];
    
    [(UILabel*)[self withView:cell tag:2] setText: [list getValueFromKey:@"name"]];

    [(UILabel*)[self withView:cell tag:3] setText: ((NSArray*)list[@"author"]).count > 1 ? @"Nhiều tác giả" : list[@"author"][0][@"name"]];

    [(UILabel*)[self withView:cell tag:4] setText: [list responseForKey:@"category"] ? ((NSArray*)list[@"category"]).count > 1 ? @"Đang cập nhật" : list[@"category"][0][@"name"] : @"Đang cập nhật"];

    ((UILabel*)[self withView:cell tag:5]).hidden = YES;
    
//    [(UILabel*)[self withView:cell tag:5] setText: [NSString stringWithFormat:@"%@ chương", [list getValueFromKey:@"total_chapter"]]];

//        [(UILabel*)[self withView:cell tag:6] setText: [list[@"newest_chapter"] isEqual:[NSNull null]] ? @"Đang cập nhật" : list[@"newest_chapter"][@"name"]];
    
    [(UILabel*)[self withView:cell tag:11] setText: [NSString stringWithFormat:@"%li", indexPath.row + 1]];
    
    Progress * progress = ((Progress*)[self withView:cell tag:12]);
    
    progress.hidden = YES;
    
    progress.percentage.text = indexPath.row % 2 == 0 ? @"16 %" : @"30 %";
    
    CGRect rect = progress.outer.frame;
    
    CGRect rectIn = progress.inner.frame;

    rectIn.size.width = rect.size.width * (indexPath.row % 2 == 0 ? 16 : 30) / 100;
    
    progress.inner.frame = rectIn;
    
    UIImageView * audio = ((Progress*)[self withView:cell tag:16]);

    audio.hidden = ![[list getValueFromKey: @"book_type"] isEqualToString:@"3"];
 
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * list = dataList[indexPath.row];

    NSMutableDictionary * config = [[NSMutableDictionary alloc] initWithDictionary:list];
    
    config[@"url"] = @{@"CMD_CODE":@"getListBook"};

    if ([[list getValueFromKey: @"book_type"] isEqualToString:@"3"]) {
        [self didRequestMP3LinkWithInfo:config];
        return;
    }
    Book_Detail_ViewController * bookDetail = [Book_Detail_ViewController new];
            
    bookDetail.config = config;
    
    [[self CENTER] pushViewController:bookDetail animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (pageIndex == 1) {
        return;
    }
    
    if (indexPath.row == dataList.count - 1) {
        if (pageIndex <= totalPage) {
            isLoadMore = YES;
            [self didRequestData:NO];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
