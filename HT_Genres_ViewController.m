//
//  HT_Genres_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/5/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_Genres_ViewController.h"

#import "HT_Detail_ViewController.h"

@interface HT_Genres_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
}

@end

@implementation HT_Genres_ViewController

@synthesize previousContentOffset;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didEmbed];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __block HT_Genres_ViewController * weakSelf  = self;
    
    [tableView addHeaderWithBlock:^{
        
        [weakSelf didRequestData];
        
    } withIndicatorColor:[UIColor grayColor]];

    
    dataList = [NSMutableArray new];
    
    [tableView withCell:@"HT_Genres_Cell"];
    
    [self didRequestData];
}

- (void)didRequestData
{
    NSString * url = [NSString stringWithFormat:@"https://api-v2.hearthis.at/categories/"];
    
    [[LTRequest sharedInstance] didRequestInfo:@{@"absoluteLink":[url encodeUrl],@"method":@"GET",@"overrideError":@(1),@"host":self} withCache:^(NSString *cacheString) {
        
        if(cacheString.length != 0)
        {
            NSDictionary * dict = [cacheString objectFromJSONString];
            
            [dataList removeAllObjects];
            
            [self reAddData:dict[@"array"]];
        }
        
        [tableView reloadData];
        
    } andCompletion:^(NSString *responseString, NSString* errorCode, NSError *error, BOOL isValidated, NSDictionary * object) {
        
        [tableView performSelector:@selector(footerEndRefreshing) withObject:nil afterDelay:0.5];
        
        [tableView headerEndRefreshing];
        
        if(isValidated)
        {
            NSDictionary * dict = [responseString objectFromJSONString];
            
            [dataList removeAllObjects];
            
            [self reAddData:dict[@"array"]];
        }
        
        [tableView reloadData];
        
    }];
}

- (void)reAddData:(NSArray*)arr
{
    for(NSDictionary * dict in arr)
    {
        if([dict getValueFromKey:@"name"].length != 0)
        {
            [dataList addObject:dict];
        }
    }
}

#pragma mark TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"HT_Genres_Cell" forIndexPath:indexPath];
    
    NSDictionary * list = dataList[indexPath.row];
    
    ((UILabel*)[self withView:cell tag:11]).text = list[@"name"];
    
    ((UIImageView*)[self withView:cell tag:12]).image = [[UIImage imageNamed:@"note"] tintedImage:kColor];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [[self CENTER] didHideTabbar];
    
    if([[self autoIncrement:@"genres123"] intValue] % 4 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
    
//    [[self ROOT] toggleLeftPanel:nil];
    
    [APPDELEGATE changeRoot:YES];
    
//    [[self WINDOW] setRootViewController:[HT_Detail_ViewController new]];

//    HT_Detail_ViewController * detail = [HT_Detail_ViewController new];
//
//    detail.url = dataList[indexPath.row][@"api_url"];
//
//    detail.titleText = dataList[indexPath.row][@"name"];
//
//    [self.navigationController pushViewController:detail animated:YES];
}

- (void)presentAds
{
   
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat currentContentOffset = scrollView.contentOffset.y;
//
//    float scrollViewHeight = scrollView.frame.size.height;
//    float scrollContentSizeHeight = scrollView.contentSize.height;
//
//    if (currentContentOffset < 0 || currentContentOffset + scrollViewHeight >= scrollContentSizeHeight) return;
//    NSLog(@"%f", currentContentOffset);
//
//    if (currentContentOffset > self.previousContentOffset) {
////        [[self CENTER] didHideTabbar];
//        [self setTabBarVisible:NO animated:YES completion:^(BOOL finished) {
//            NSLog(@"finished");
//        }];
//    } else {
////        [[self CENTER] didShowTabbar];
//        [self setTabBarVisible:YES animated:YES completion:^(BOOL finished) {
//            NSLog(@"finished");
//        }];
//    }
//    self.previousContentOffset = currentContentOffset;
}

- (void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {

    // bail if the current state matches the desired state
    if ([self tabBarIsVisible] == visible) return (completion)? completion(YES) : nil;

    // get a frame calculation ready
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height : height;

    // zero duration means no animation
    CGFloat duration = (animated)? 0.3 : 0.0;

    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}

//Getter to know the current state
- (BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
