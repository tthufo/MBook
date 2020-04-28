//
//  SC_Menu_ViewController.m
//  SoundC
//
//  Created by thanhhaitran on 9/9/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "SC_Menu_ViewController.h"

#import "MeBook-Swift.h"

@interface SC_Menu_ViewController ()
{
    IBOutlet UITableView * tableView;
    
    IBOutlet UIImageView * blurBack;
    
    NSMutableArray * dataList;
    
    IBOutlet NSLayoutConstraint * widthConstant;
}

@end

@implementation SC_Menu_ViewController

- (void)reloadData
{
    if([[self getObject:@"adsInfo"][@"itune"] boolValue])
    {
        if(dataList.count == 4)
        {
            [dataList addObject:@{@"title":@"Synced",@"img":@""}];
        }
    }
    
    [tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    widthConstant.constant = [self screenWidth] * 0.8;
    
    blurBack.image = [[UIImage imageNamed:@"blurBack"] boxblurImageWithBlur:0.5];
    
    dataList = [[NSMutableArray alloc] initWithArray:[self arrayWithPlist:@"MenuList"]];
    
    if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
    {
        [dataList removeLastObject];
    }
    
    if(![[LTRequest sharedInstance] isConnectionAvailable])
    {
        if(dataList.count == 4)
        {
            [dataList addObject:@{@"title":@"Synced",@"img":@""}];
        }
    }
    
    [tableView registerNib:[UINib nibWithNibName:@"SC_Menu" bundle:nil] forCellReuseIdentifier:@"menuCell"];
    
    tableView.frame = CGRectMake(0, (screenHeight1 - 35 * dataList.count) / 2, 150, 35 * dataList.count);
    
    [self addValue:@"0" andKey:@"menuI"];
}

#pragma TableView

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"menuCell" forIndexPath:indexPath];
    
    NSDictionary * list = dataList[indexPath.row];
    
//    [((UIImageView*)[self withView:cell tag:10]) sd_setImageWithURL:[NSURL URLWithString:[list getValueFromKey:@"artwork_url"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        if (error) return;
//        if (image && cacheType == SDImageCacheTypeNone)
//        {
//            [UIView transitionWithView:((UIImageView*)[self withView:cell tag:10])
//                              duration:0.5
//                               options:UIViewAnimationOptionTransitionCrossDissolve
//                            animations:^{
//                                [((UIImageView*)[self withView:cell tag:10]) setImage:image];
//                            } completion:NULL];
//        }
//    }];
    
    ((UILabel*)[self withView:cell tag:11]).text = list[@"title"];
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if(indexPath.row == [[self getValue:@"menuI"] intValue])
//    {
//        [[self ROOT] showCenterPanelAnimated:YES];
//
//        return;
//    }
    
    [self addValue:[NSString stringWithFormat:@"%i",indexPath.row] andKey:@"menuI"];
    
    switch (indexPath.row) {
        case 0:
        {
            [[self CENTER] pushViewController:[List_Book_ViewController new] animated:YES];
        }
            break;
        case 1:
        {
//            [[self CENTER] pushViewController:[SC_Search_ViewController new] animated:NO];
        }
            break;
        case 2:
        {
//            [[self CENTER] pushViewController:[M_History_ViewController new] animated:NO];
        }
            break;
        case 3:
        {
//            [[self CENTER] pushViewController:[TT_More_ViewController new] animated:NO];
        }
            break;
        case 4:
        {
//            [[self CENTER] pushViewController:[TT_Synced_ViewController new] animated:NO];
        }
            break;
        default:
            break;
    }
    
    [[self ROOT] showCenterPanelAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
