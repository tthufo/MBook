//
//  HT_Search_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "Second_Tab_ViewController.h"

#import "MeBook-Swift.h"

@interface Second_Tab_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIRefreshControl * refreshControl;
    
    IBOutlet Tag_View * tagView;
    
    IBOutlet Tag_View_Vip * tagView_Vip;
    
    IBOutlet UIImageView * searchBtn;
    
    IBOutlet UITextField * searchView;
    
    IBOutlet UIButton * buyBtn;

    NSMutableArray * dataList;
    
    NSMutableArray * config;
        
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore, isHot;
    
    float tempHeight;
}

@end

@implementation Second_Tab_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    buyBtn.hidden = Information.isVip;
    
    tagView.hidden = Information.isVip;
    
    tagView_Vip.hidden = !Information.isVip;
    
    searchView.text = Information.searchValue == nil ? @"" : Information.searchValue;
    
    [self didEmbed];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        
    [self.view endEditing:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
        NSLog(@"%@", infor);
        if ([[infor getValueFromKey:@"action"] isEqualToString:@"custom"]) {
            [weakSelf didPressVip];
        } else {
            List_Book_ViewController * listBook = [List_Book_ViewController new];
            NSMutableDictionary * bookInfo = [[NSMutableDictionary alloc] initWithDictionary:@{
                @"url": @{
                        @"CMD_CODE":@"getListBook",
                        @"book_type":@(0),
                        @"price": @(0),
                        @"sorting": @(1),
                        @"tag_id": [infor getValueFromKey:@"id"]
                },
                @"title": [infor getValueFromKey:@"name"]
            }];
            listBook.config = bookInfo;
            [weakSelf.CENTER pushViewController:listBook animated:YES];
        }
    };
    
    config = [@[
        [@{
                @"title": @"EBOOK MỚI NHẤT", @"url": [@{
                        @"CMD_CODE" : @"getListBook",
                        @"page_index": @1,
                        @"page_size": @25,
                        @"book_type": @1,
                        @"price": @0,
                        @"sorting": @1 } mutableCopy],
                @"height": @0,
                @"directon": @"horizontal",
                @"loaded": @NO
            } mutableCopy],
        [@{
                @"title": @"KHUYÊN ĐỌC", @"url": [@{
                        @"CMD_CODE" : @"getListPromotionBook",
                        @"page_index": @1,
                        @"page_size": @24
                        } mutableCopy],
                @"height": @0,
                @"directon": @"horizontal",
                @"loaded": @NO
            } mutableCopy]
    ] mutableCopy];
    
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

- (void)didPressVip {
    VIP_ViewController * vip = [VIP_ViewController new];
    vip.callBack = ^(NSDictionary *infor) {
        
    };
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:vip];
    nav.navigationBarHidden = YES;
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [[self CENTER] presentViewController:nav animated:YES completion:nil];
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
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getListStory",
                                                 @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                 @"session":Information.token,
                                                 @"page_index": @(pageIndex),
                                                 @"page_size": @(12),
                                                 @"price": @(0),
                                                 @"sorting": @(1),
                                                 @"overrideError":@"1",
                                                 @"overrideLoading":@"1",
                                                 @"host":self
    } withCache:^(NSString *cacheString) {
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
                
                [dataList addObjectsFromArray:dict[@"result"][@"data"]];
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

- (IBAction)didPressBuy:(id)sender {
    VIP_ViewController * vip = [VIP_ViewController new];
    vip.callBack = ^(NSDictionary *infor) {
        NSLog(@"%@", infor);
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 1 : 40;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[NSBundle mainBundle] loadNibNamed:@"Book_List_Header" owner:self options:nil][1];
    
    UILabel * title = (UILabel*)[self withView:header tag:22];
    
    title.text = @"MỚI CẬP NHẬT";
    
    UIButton * extra = (UIButton*)[self withView:header tag:12];
        
    [extra actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        List_Book_List_ViewController * list = [List_Book_List_ViewController new];
        [[self CENTER] pushViewController:list animated:YES];
    }];
    
    return section == 0 ? nil : header;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? config.count : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? tempHeight == 0 ? [config[indexPath.row][@"height"] floatValue] : tempHeight : UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: indexPath.section == 0 ? @"TG_Room_Cell_0" : @"Book_List_Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 1) {
                
        NSDictionary * list = dataList[indexPath.row];
        
        UIView * bg = (UIView*)[self withView:cell tag:100];
        
        UIImageView * booking = (UIImageView*)[self withView:cell tag:1];
        
        [booking imageUrlWithUrl: [list getValueFromKey:@"avatar"]];
        
        booking.widthConstaint.constant = [bg bookWidth];
     
        bg.widthConstaint.constant = [bg bookWidth];

        booking.heightConstaint.constant = [bg bookHeight];
        
        bg.heightConstaint.constant = [bg bookHeight];
        
        
        [(UILabel*)[self withView:cell tag:2] setText: [list getValueFromKey:@"name"]];

        [(UILabel*)[self withView:cell tag:3] setText: ((NSArray*)list[@"author"]).count > 1 ? @"Nhiều tác giả" : list[@"author"][0][@"name"]];

        [(UILabel*)[self withView:cell tag:4] setText: ((NSArray*)list[@"category"]).count > 1 ? @"Đang cập nhật" : list[@"category"][0][@"name"]];

        [(UILabel*)[self withView:cell tag:5] setText: [NSString stringWithFormat:@"%@ chương", [list getValueFromKey:@"total_chapter"]]];

        [(UILabel*)[self withView:cell tag:14] setText: [list[@"newest_chapter"] isEqual:[NSNull null]] ? @"Đang cập nhật" : list[@"newest_chapter"][@"name"]];
        
        ((UILabel*)[self withView:cell tag:14]).alpha = 1;
        
        [(UILabel*)[self withView:cell tag:11] setText: [NSString stringWithFormat:@"%li", indexPath.row + 1]];
        
        ((UIImageView*)[self withView:cell tag:15]).alpha = 1;
        
        Progress * progress = ((Progress*)[self withView:cell tag:12]);
        
        progress.alpha = 0;
        
        progress.percentage.text = indexPath.row % 2 == 0 ? @"16 %" : @"30 %";
        
        CGRect rect = progress.outer.frame;
        
        CGRect rectIn = progress.inner.frame;

        rectIn.size.width = rect.size.width * (indexPath.row % 2 == 0 ? 16 : 30) / 100;
        
        progress.inner.frame = rectIn;

    } else {
        ((TG_Room_Cell_N *)cell).config = self->config[indexPath.row];
        ((TG_Room_Cell_N *)cell).returnValue = ^(float value) {
            self->config[indexPath.row][@"height"] = [NSString stringWithFormat:@"%f", value];
            self->config[indexPath.row][@"loaded"] = @YES;
            self->tempHeight = value;
            [tableView reloadData];
        };
        ((TG_Room_Cell_N *)cell).callBack = ^(id infor) {
            if ([[(NSDictionary*)infor getValueFromKey:@"book_type"] isEqualToString:@"3"]) {
                [self didRequestMP3LinkWithInfo:(NSDictionary*)infor];
                return;
            }
            
            Book_Detail_ViewController * bookDetail = [Book_Detail_ViewController new];
            NSMutableDictionary * bookInfo = [[NSMutableDictionary alloc] initWithDictionary:[self removeKey:self->config[indexPath.row]]];
            [bookInfo addEntriesFromDictionary:(NSDictionary*)infor];
            bookDetail.config = bookInfo;
            [[self CENTER] pushViewController:bookDetail animated:YES];
        };

        UIButton * more = (UIButton*)[self withView:cell tag:12];
        
        [more actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            List_Book_ViewController * list = [List_Book_ViewController new];
            list.config = [self removeKey:self->config[indexPath.row]];
            [self.navigationController pushViewController:list animated:YES];
        }];

    }
 
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary * list = dataList[indexPath.row];

    NSMutableDictionary * configuration = [[NSMutableDictionary alloc] initWithDictionary:list];
    
    configuration[@"url"] = @{@"CMD_CODE":@"getListBook"};

    Book_Detail_ViewController * bookDetail = [Book_Detail_ViewController new];
            
    bookDetail.config = configuration;
    
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
