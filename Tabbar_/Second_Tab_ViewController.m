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

    NSMutableArray * dataList, *topList, *proList;
    
    NSMutableArray * config;
    
    NSMutableDictionary * state;
        
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore, isHot;
    
    float tempHeight;
    
    IBOutlet NSLayoutConstraint * login_bg_height;

}

@end

@implementation Second_Tab_ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    state = [@{@"hot": @"0", @"top": @"0"} mutableCopy];
    
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
    
    if (IS_IPAD) {
        login_bg_height.constant = 550;
    }
    
    tempHeight = 0;
    
    pageIndex = 1;
    
    totalPage = 1;
    
    isHot = YES;
    
    dataList = [NSMutableArray new];
    
    topList = [NSMutableArray new];

    proList = [NSMutableArray new];

    [tableView withCell: @"Book_List_Cell"];
    
    [tableView withCell: @"Book_Top_Cell"];

    [tableView withCell: @"TG_Room_Cell_0"];
    
    [tableView withCell: @"TG_Room_Cell_1"];

    [tableView withCell: @"TG_Room_Cell_2"];

    refreshControl = [UIRefreshControl new];
    
    tableView.refreshControl = refreshControl;
    
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    
    [self showSVHUD:@"" andOption:0];
//    [self didRequestData:YES];
//
//    [self didRequestTop:NO];
//
//    [self didRequestPromo];
        
    __weak typeof(self) weakSelf = self;
    tagView.callBack = ^(NSDictionary *infor) {
//        NSLog(@"%@", infor);
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
    
    tagView_Vip.callBack = ^(NSDictionary *infor) {
//        NSLog(@"%@", infor);
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
                        @"group_type":@(1),
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
                        @"group_type":@(1),
                        @"page_index": @1,
                        @"page_size": @25
                        } mutableCopy],
                @"height": @0,
                @"directon": @"horizontal",
                @"loaded": @NO
            } mutableCopy]
    ] mutableCopy];
    
    NSTimeInterval delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self didReloadData];
    });
    
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
    for (NSMutableDictionary* dict in config) {
        dict[@"loaded"] = @NO;
    }
    
    NSTimeInterval delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self->refreshControl endRefreshing];
        [self->tableView reloadData];
    });
    
    isLoadMore = NO;
    pageIndex = 1;
    totalPage = 1;
    
    NSTimeInterval delayInSeconds_1 = 0.6;
    dispatch_time_t popTime_1 = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds_1 * NSEC_PER_SEC));
    dispatch_after(popTime_1, dispatch_get_main_queue(), ^(void){
        [self didRequestData:YES];
        [self didRequestTop:NO];
        [self didRequestPromo];
    });
}

- (void)didRequestPromo
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getListStory",
                                                 @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                 @"session":Information.token,
                                                 @"group_type": @(1),
                                                 @"page_index": @(1),
                                                 @"page_size": @(6),
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
            
                [proList removeAllObjects];
                
                [proList addObjectsFromArray:[self filterArrayWithData: dict[@"result"][@"data"]]];
            } else {
                [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
            }
        }
        
        [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

    }];
}

- (void)didRequestTop:(BOOL)isShow
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getUserTable",
                                                 @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                 @"session":Information.token,
                                                 @"type": @(1),
                                                 @"total_item": @(10),
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
            
                [topList removeAllObjects];
                
                [topList addObjectsFromArray:dict[@"result"]];
            } else {
                [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
            }
        }
        
        [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

    }];
}

- (void)didRequestData:(BOOL)isShow
{
    [[LTRequest sharedInstance] didRequestInfo:@{@"CMD_CODE":@"getBookTable", //getListStory
                                                 @"header":@{@"session":Information.token == nil ? @"" : Information.token},
                                                 @"session":Information.token,
                                                 @"type": @(2),
                                                 @"total_item": @(10),
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
                [dataList removeAllObjects];
        
                [dataList addObjectsFromArray:[self filterArrayWithData: dict[@"result"]]];
            } else {
                [self showToast:[[dict getValueFromKey:@"error_msg"] isEqualToString:@""] ? @"Lỗi xảy ra, mời bạn thử lại" : [dict getValueFromKey:@"error_msg"] andPos:0];
            }
        }
        
        [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

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

- (UITableViewCell*)topCell:(UITableViewCell*)cell andInfo:(NSDictionary*)top andIndex:(NSIndexPath*)indexPath {
    
    cell.backgroundColor = [AVHexColor colorWithHexString:@"#ECECE7"];

    UIView * bg = (UIView*)[self withView:cell tag:100];
    
    UIImageView * booking = (UIImageView*)[self withView:cell tag:1];
    
    [booking imageUrlWithUrl: [top getValueFromKey:@"avatar"]];
    
    booking.widthConstaint.constant = [bg bookWidth];
 
    bg.widthConstaint.constant = [bg bookWidth];

    booking.heightConstaint.constant = [bg bookWidth];
    
    bg.heightConstaint.constant = [bg bookWidth];
    
    bg.layer.cornerRadius = [bg bookWidth] / 2;
    
    booking.layer.cornerRadius = [bg bookWidth] / 2;

    [(UILabel*)[self withView:cell tag:2] setText: [top getValueFromKey:@"name"]];

    [(UILabel*)[self withView:cell tag:3] setText: [NSString stringWithFormat:@"Đã đọc %@ tác phẩm", [top getValueFromKey:@"total_book"]]];

    [(UILabel*)[self withView:cell tag:4] setText: [NSString stringWithFormat:@"Tham gia từ %@", [top getValueFromKey:@"register_date"]]];
    
    ((UILabel*)[self withView:cell tag:11]).hidden = NO;
    
    [(UILabel*)[self withView:cell tag:11] setText: [NSString stringWithFormat:@"%li", indexPath.row + 1]];

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 1 : 45;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * header = [[NSBundle mainBundle] loadNibNamed:@"Book_List_Header" owner:self options:nil][section == 2 ? 1 : isHot ? 0 : 2];
    
    if (section == 2) {
        UILabel * title = (UILabel*)[self withView:header tag:22];
    
        title.text = @"MỚI CẬP NHẬT";
    
        UIButton * extra = (UIButton*)[self withView:header tag:12];
    
        [extra actionForTouch:@{} and:^(NSDictionary *touchInfo) {
            List_Book_List_ViewController * list = [List_Book_List_ViewController new];
            [[self CENTER] pushViewController:list animated:YES];
        }];
    } else {
        if (isHot) {
            UIButton * top = [self withView:header tag:2];
            [top actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                isHot = NO;
                [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }];
        } else {
            UIButton * hot = [self withView:header tag:1];
            [hot actionForTouch:@{} and:^(NSDictionary *touchInfo) {
                isHot = YES;
                [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
    
    return section == 0 ? nil : header;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForFooterInSection:(NSInteger)section
{
    return section != 1 ? 1 : 35;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    int condition = isHot && [state[@"hot"] isEqualToString:@"0"] ? 3 : !isHot && [state[@"top"] isEqualToString:@"0"] ? 3 : 4;
    
    UIView * footer = [[NSBundle mainBundle] loadNibNamed:@"Book_List_Header" owner:self options:nil][condition];
    
    UIButton * viewMore = [self withView:footer tag:1];
    
    viewMore.hidden = section != 1;
    
    footer.backgroundColor = section == 0 ? [UIColor clearColor] : [AVHexColor colorWithHexString:@"#ECECE7"];
    
    footer.backgroundColor = section == 0 ? [UIColor clearColor] : [AVHexColor colorWithHexString:@"#ECECE7"];

    [viewMore actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        if(isHot) {
            state[@"hot"] = [state[@"hot"] isEqualToString:@"0"] ? @"1" : @"0";
        } else {
            state[@"top"] = [state[@"top"] isEqualToString:@"0"] ? @"1" : @"0";
        }
        [self->tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    return section == 2 ? nil : footer;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 2 ? proList.count : section == 0 ? config.count : isHot ? dataList.count == 0 ? 0 : ([state[@"hot"] isEqualToString:@"0"] ? dataList.count < 3 ? dataList.count : 3 : dataList.count) : topList.count == 0 ? 0 : ([state[@"top"] isEqualToString:@"0"] ? topList.count < 3 ? topList.count : 3 : topList.count);
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 0 ? tempHeight == 0 ? [config[indexPath.row][@"height"] floatValue] : tempHeight : UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier: indexPath.section == 2 ? @"Book_List_Cell" : indexPath.section == 0 ? [NSString stringWithFormat:@"TG_Room_Cell_%li", (long)indexPath.row] : isHot ? @"Book_List_Cell" : @"Book_Top_Cell" forIndexPath:indexPath];
    
    if (indexPath.section == 1 || indexPath.section == 2) {
        
        if (indexPath.section == 1) {
            if (!isHot) {
                NSDictionary * top = topList[indexPath.row];
                return [self topCell:cell andInfo:top andIndex:indexPath];
            }
        }
                
        cell.backgroundColor = indexPath.section == 1 ? [AVHexColor colorWithHexString: @"#ECECE7"] : [UIColor clearColor];
        
        NSDictionary * list = indexPath.section == 1 ? dataList[indexPath.row] : proList[indexPath.row];
                
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

        NSString * author = [list[@"author"] isEqual: [NSNull null]] ? @"" : ((NSArray*)list[@"author"]).count > 1 ? @"Nhiều tác giả" : ((NSArray*)list[@"author"]).count == 0 ? @"Đang cập nhật" : list[@"author"][0][@"name"];
        
        [(UILabel*)[self withView:cell tag:3] setText: author];
        
        NSString * category = [list[@"category"] isEqual: [NSNull null]] ? @"" : ((NSArray*)list[@"category"]).count > 1 ? @"Đang cập nhật" : ((NSArray*)list[@"category"]).count == 0 ? @"Đang cập nhật" : list[@"category"][0][@"name"];

        [(UILabel*)[self withView:cell tag:4] setText: category];

        [(UILabel*)[self withView:cell tag:5] setText: [NSString stringWithFormat:@"%@ chương", [list getValueFromKey:@"total_chapter"]]];

        ((UILabel*)[self withView:cell tag:5]).hidden = indexPath.section == 1;
        
        [(UILabel*)[self withView:cell tag:14] setText: [list[@"newest_chapter"] isEqual:[NSNull null]] ? @"Đang cập nhật" : list[@"newest_chapter"][@"name"]];
        
        ((UILabel*)[self withView:cell tag:14]).alpha = 1;
        
        [(UILabel*)[self withView:cell tag:11] setText: [NSString stringWithFormat:@"%li", indexPath.row + 1]];
        
        ((UILabel*)[self withView:cell tag:11]).hidden = indexPath.section == 1 ? NO : YES;
        
        ((UIImageView*)[self withView:cell tag:99]).hidden = indexPath.section == 1 ? NO : YES;

        ((UIImageView*)[self withView:cell tag:15]).alpha = 1;
        
        Progress * progress = ((Progress*)[self withView:cell tag:12]);
        
        progress.alpha = 0;
        
        progress.percentage.text = indexPath.row % 2 == 0 ? @"16 %" : @"30 %";
        
        CGRect rect = progress.outer.frame;
        
        CGRect rectIn = progress.inner.frame;

        rectIn.size.width = rect.size.width * (indexPath.row % 2 == 0 ? 16 : 30) / 100;
        
        progress.inner.frame = rectIn;
        
        UIImageView * audio = ((Progress*)[self withView:cell tag:16]);

        audio.hidden = ![[list getValueFromKey: @"book_type"] isEqualToString:@"3"];

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
            [[self CENTER] pushViewController:list animated:YES];
        }];

    }
 
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        if (!isHot) {
            return;
        }
    }
    
    NSDictionary * list = indexPath.section == 1 ? dataList[indexPath.row] : proList[indexPath.row];

    NSMutableDictionary * configuration = [[NSMutableDictionary alloc] initWithDictionary:list];
    
    configuration[@"url"] = @{@"CMD_CODE":@"getListBook"};
    
    if ([[list getValueFromKey: @"book_type"] isEqualToString:@"3"]) {
        [self didRequestMP3LinkWithInfo: configuration];
        return;
    }

    Book_Detail_ViewController * bookDetail = [Book_Detail_ViewController new];
            
    bookDetail.config = configuration;
    
    [[self CENTER] pushViewController:bookDetail animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (pageIndex == 1) {
//        return;
//    }
//
//    if (indexPath.row == proList.count - 1) {
//        if (pageIndex <= totalPage) {
//            isLoadMore = YES;
//            [self didRequestPromo];
//        }
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
