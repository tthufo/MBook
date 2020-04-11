//
//  HT_Search_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/4/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "Second_Tab_ViewController.h"

#import "HearThis-Swift.h"

@interface Second_Tab_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIRefreshControl * refreshControl;
    
    NSMutableArray * dataList;
        
    int pageIndex;
    
    int totalPage;
    
    BOOL isLoadMore;
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
    
    pageIndex = 1;
    
    totalPage = 1;
    
    dataList = [NSMutableArray new];
    
    [tableView withCell: @"Book_List_Cell"];
    
    refreshControl = [UIRefreshControl new];
    
    tableView.refreshControl = refreshControl;
    
    [refreshControl addTarget:self action:@selector(didReloadData) forControlEvents:UIControlEventValueChanged];
    
    [self didRequestData:YES];
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
            
            totalPage = [dict[@"result"][@"total_page"] intValue];
              
            pageIndex += 1;
              
            if(!isLoadMore)
            {
                [dataList removeAllObjects];
            }
            
            [dataList addObjectsFromArray:dict[@"result"][@"data"]];
        }
        
        [tableView reloadData];
        
    }];
}

- (NSDictionary *)removeKey:(NSMutableDictionary *)info {
    [(NSMutableDictionary*)info[@"url"] removeObjectsForKeys:@[@"page_index", @"page_size"]];
    return info;
}

#pragma TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 165;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"Book_List_Cell" forIndexPath:indexPath];
    
    NSDictionary * list = dataList[indexPath.row];
    
    [(UIImageView*)[self withView:cell tag:1] imageUrlWithUrl: [list getValueFromKey:@"avatar"]];
    
    [(UILabel*)[self withView:cell tag:2] setText: [list getValueFromKey:@"name"]];

    [(UILabel*)[self withView:cell tag:3] setText: ((NSArray*)list[@"author"]).count > 1 ? @"Nhiều tác giả" : list[@"author"][0][@"name"]];

    [(UILabel*)[self withView:cell tag:4] setText: ((NSArray*)list[@"category"]).count > 1 ? @"Đang cập nhật" : list[@"category"][0][@"name"]];

    [(UILabel*)[self withView:cell tag:5] setText: [NSString stringWithFormat:@"%@ chương", [list getValueFromKey:@"total_chapter"]]];

    [(UILabel*)[self withView:cell tag:6] setText: [list[@"newest_chapter"] isEqual:[NSNull null]] ? @"Đang cập nhật" : list[@"newest_chapter"][@"name"]];

    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary * list = dataList[indexPath.row];

    Book_Detail_ViewController * detail = [Book_Detail_ViewController new];
        
    NSLog(@"%@", list);
    
//    NSMutableDictionary
//    let bookDetail = Book_Detail_ViewController.init()
//
//    let bookInfo = NSMutableDictionary.init(dictionary: self.removeKey(info: conf))
//    bookInfo.addEntries(from: info as! [AnyHashable : Any])
//
//    bookDetail.config = bookInfo
//
//    self.center()?.pushViewController(bookDetail, animated: true)
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
