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
    
    NSMutableArray * dataList;
    
    NSMutableDictionary * config;
        
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
    
    [self didEmbed];
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
    
    tagView.callBack = ^(NSDictionary *infor) {
        NSLog(@"%@", infor);
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
    [[self ROOT] toggleLeftPanel:sender];
}

- (IBAction)didPressSearch:(id)sender {
    [[self CENTER] pushViewController:[Search_ViewController new] animated:YES];
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
    UIView * header = [[NSBundle mainBundle] loadNibNamed:@"Book_List_Header" owner:self options:nil][0];
    
    UIButton * hot = (UIButton*)[self withView:header tag:1];
    
    UIButton * top = (UIButton*)[self withView:header tag:2];

    [hot setTitleColor:[AVHexColor colorWithHexString: isHot ? @"#1E928C" : @"#FFFFFF"] forState:UIControlStateNormal];
    [hot setBackgroundImage:[UIImage imageNamed: isHot ? @"ico_tab_white" : @"ico_tab_teal"] forState:UIControlStateNormal];
    
    [top setTitleColor:[AVHexColor colorWithHexString: isHot ? @"#FFFFFF" : @"1E928C"] forState:UIControlStateNormal];
    [top setBackgroundImage:[UIImage imageNamed: isHot ? @"ico_tab_teal" : @"ico_tab_white"] forState:UIControlStateNormal];
    
    [top actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        isHot = NO;
        [tableView beginUpdates];
        [tableView reloadData];
//        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }];
    
    [hot actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        isHot = YES;
        [tableView beginUpdates];
        [tableView reloadData];
//        [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        [tableView endUpdates];
    }];
        
    return section == 0 ? nil : header;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)_tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewAutomaticDimension;
//}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 1 : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%f", tempHeight);
    return indexPath.section == 0 ? tempHeight == 0 ? [config[@"height"] floatValue] : tempHeight : 155;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: indexPath.section == 0 ? @"TG_Room_Cell_0" : @"Book_List_Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 1) {
        
        cell.contentView.backgroundColor = [AVHexColor colorWithHexString:@"#ECEDE7"];
        
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

    } else {
        ((TG_Room_Cell_N *)cell).config = self->config;
        ((TG_Room_Cell_N *)cell).returnValue = ^(float value) {
            self->config[@"height"] = [NSString stringWithFormat:@"%f", value];
            self->config[@"loaded"] = @YES;
            self->tempHeight = value;
            [tableView reloadData];
        };
        ((TG_Room_Cell_N *)cell).callBack = ^(id infor) {
            if ([[(NSDictionary*)infor getValueFromKey:@"book_type"] isEqualToString:@"3"]) {
                [self didRequestUrlWithInfo:(NSDictionary*)infor];
                return;
            }
            
            Book_Detail_ViewController * bookDetail = [Book_Detail_ViewController new];
            NSMutableDictionary * bookInfo = [[NSMutableDictionary alloc] initWithDictionary:[self removeKey:self->config]];
            [bookInfo addEntriesFromDictionary:(NSDictionary*)infor];
            bookDetail.config = bookInfo;
            [[self CENTER] pushViewController:bookDetail animated:YES];
        };

        UIButton * more = (UIButton*)[self withView:cell tag:12];
        
        [more actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            List_Book_ViewController * list = [List_Book_ViewController new];
            list.config = [self removeKey:self->config];
            [self.navigationController pushViewController:list animated:YES];
        }];

    }
 
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
