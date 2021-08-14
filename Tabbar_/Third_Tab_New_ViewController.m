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
    
    NSMutableArray * dataList;
    
    NSMutableDictionary * config;
        
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore, isHot;
    
    float tempHeight;
}

@end

@implementation Third_Tab_New_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
            ((HT_Root_ViewController*)[weakSelf TABBAR]).selectedIndex = 1;
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
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getListBookPurchaseByUser",
                                                 @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                 @"page_index": @(pageIndex),
                                                 @"page_size": @(12),
                                                 @"price": @(1),
                                                 @"book_type": @(0),
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
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: @"Book_List_Cell" forIndexPath:indexPath];
    
        
//    cell.contentView.backgroundColor = [AVHexColor colorWithHexString:@"#ECEDE7"];
    
    NSDictionary * list = dataList[indexPath.row];
    
    [(UIImageView*)[self withView:cell tag:1] imageUrlWithUrl: [list getValueFromKey:@"avatar"]];
    
    [(UILabel*)[self withView:cell tag:2] setText: [list getValueFromKey:@"name"]];

    [(UILabel*)[self withView:cell tag:3] setText: ((NSArray*)list[@"author"]).count > 1 ? @"Nhiều tác giả" : list[@"author"][0][@"name"]];

    [(UILabel*)[self withView:cell tag:4] setText: ((NSArray*)list[@"category"]).count > 1 ? @"Đang cập nhật" : list[@"category"][0][@"name"]];

    [(UILabel*)[self withView:cell tag:5] setText: [NSString stringWithFormat:@"%@ chương", [list getValueFromKey:@"total_chapter"]]];

//        [(UILabel*)[self withView:cell tag:6] setText: [list[@"newest_chapter"] isEqual:[NSNull null]] ? @"Đang cập nhật" : list[@"newest_chapter"][@"name"]];
    
    [(UILabel*)[self withView:cell tag:11] setText: [NSString stringWithFormat:@"%li", indexPath.row + 1]];
    
    Progress * progress = ((Progress*)[self withView:cell tag:12]);
    
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
