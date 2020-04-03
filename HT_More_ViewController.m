//
//  HT_Category_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/11/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_More_ViewController.h"

#import <StoreKit/StoreKit.h>

@interface HT_More_ViewController ()<SKStoreProductViewControllerDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSMutableArray * dataList;
    
    IBOutlet UIImageView * topFire;
}

@end

@implementation HT_More_ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem * rightButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:((NSString*)[self getObject:@"adsInfo"][@"alert"]).length != 0 ?
                                                                             @"info" : @"trans"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleBordered target:self action:@selector(didPressNone)];
    
    self.navigationItem.rightBarButtonItem = rightButton;
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu"] style:UIBarButtonItemStyleBordered target:self action:@selector(didPressMenu)];
    
    self.navigationItem.leftBarButtonItem = leftButton;
    
    dataList = [@[@"Share to Your Friend!",@"Visit and Rate Me",@"More of My Apps Collection",@"Remove Ads"] mutableCopy];
    
    if([[self getValue:purchaseKey] boolValue])
    {
        [dataList removeLastObject];
    }
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    if ([[ver objectAtIndex:0] intValue] >= 7)
    {
        {
            self.navigationController.navigationBar.barTintColor = [AVHexColor colorWithHexString:kColor];
            
            self.navigationController.navigationBar.translucent = NO;
        }
    }
    else
    {
        {
            self.navigationController.navigationBar.tintColor = [AVHexColor colorWithHexString:kColor];
        }
    }
    
    if(![IAPShare sharedHelper].iap)
    {
        NSSet* dataSet = [[NSSet alloc] initWithObjects:productId, nil];
        
        [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    }
    
    [IAPShare sharedHelper].iap.production = YES;
    
    if([[self autoIncrement:@"more"] intValue] % 1 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
}

- (void)didPressNone
{
    if(((NSString*)[self getObject:@"adsInfo"][@"alert"]).length != 0)
    {
        [[[EM_MenuView alloc] initWithSubMenu:@{@"message":[self getObject:@"adsInfo"][@"alert"]}] showWithCompletion:^(int index, id object, EM_MenuView *menu){
            
            [menu close];
            
            [self openStoreProductViewControllerWithITunesItemIdentifier:1073174100];
            
        }];
    }
}

- (void)didPressMenu
{
    [[self ROOT] showLeftPanelAnimated:YES];
    
    [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
}

- (void)didPressFire
{
    if([self PLAYER].view.frame.origin.x >= screenWidth1)
    {
        //        [[self ROOT] show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"detailCell"];
    }

    cell.backgroundColor = [UIColor clearColor];

    
    cell.textLabel.text = dataList[indexPath.row];
    
    cell.textLabel.textColor = [AVHexColor colorWithHexString:kColor];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([[self autoIncrement:@"more"] intValue] % 2 == 0)
    {
        [self performSelector:@selector(presentAds) withObject:nil afterDelay:0.5];
    }
    
    switch (indexPath.row)
    {
        case 0:
        {
           
        }
            break;
        case 1:
        {
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appLink]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appLink]];
            }
        }
            break;
        case 2:
//            if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
//            {
//                //                https://itunes.apple.com/us/developer/huu-huy-nguyen/id1105474508 huy
//                
//                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://itunes.apple.com/us/developer/huu-huy-nguyen/id1105474508"]])
//                {
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/developer/huu-huy-nguyen/id1105474508"]];
//                }
//            }
//            else
//            {
//                [self openStoreProductViewControllerWithITunesItemIdentifier:1105474508]; ///Huy 1105474508
//            }
            
//            if(![[self getObject:@"adsInfo"][@"itune"] boolValue])
//            {
//                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100"]])
//                {
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/developer/thanh-hai-tran/id1073174100"]];
//                }
//            }
//            else
            {
                [self openStoreProductViewControllerWithITunesItemIdentifier:1073174100];
            }
            break;
        case 3:
        {
            [[DropAlert shareInstance] alertWithInfor:@{@"cancel":@"Cancel",@"buttons":@[@"Restore", @"Purchase"],@"title":@"Remove Ads",@"message":@"Do you want to restore or purchase Remove Ads ?"} andCompletion:^(int indexButton, id object) {
                switch (indexButton)
                {
                    case 0:
                    {
                        [self restoreProduct];
                    }
                        break;
                    case 1:
                    {
                        [self buyProduct];
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
            break;
        default:
            break;
    }
}

- (void)buyProduct
{
    [self showSVHUD:@"Loading" andOption:0];
    
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         if(response > 0)
         {
             SKProduct* product = [[IAPShare sharedHelper].iap.products objectAtIndex:0];
             
             [[IAPShare sharedHelper].iap buyProduct:product
                                        onCompletion:^(SKPaymentTransaction* trans)
              {
                  if(trans.error)
                  {
                      NSLog(@"Fail %@",[trans.error localizedDescription]);
                  }
                  
                  else if(trans.transactionState == SKPaymentTransactionStatePurchased)
                  {
                      [[IAPShare sharedHelper].iap checkReceipt:trans.transactionReceipt AndSharedSecret:iapSecret onCompletion:^(NSString *response, NSError *error)
                       {
                           NSDictionary* rec = [IAPShare toJSON:response];
                           
                           if([rec[@"status"] integerValue] == 0)
                           {
                               [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
                               
                               [self addValue:@"1" andKey:purchaseKey];
                               
                               NSLog(@"%@",[self getValue:purchaseKey]);
                               
                               [self addValue:@"0" andKey:@"embed"];
                               
//                               [[self CENTER] reAdsAdd];
                               
                               [dataList removeLastObject];
                               
                               [tableView reloadData];
                               
                               [self alert:@"Remove Ads Notice" message:@"Your purchase was successful. Thanks for purchasing!"];
                               
//                               [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Not now",@"buttons":@[@"Restart"],@"title":@"Application restart required",@"message":@"Do you want to restart application to take Remove Ads effect?"} andCompletion:^(int indexButton, id object) {
//                                   switch (indexButton)
//                                   {
//                                       case 0:
//                                       {
//                                           exit(0);
//                                       }
//                                           break;
//                                       case 1:
//                                           
//                                           break;
//                                       default:
//                                           break;
//                                   }
//                               }];
                           }
                           else
                           {
                               NSLog(@"Fail");
                           }
                       }];
                  }
                  else if(trans.transactionState == SKPaymentTransactionStateFailed)
                  {
                      NSLog(@"Fail");
                  }
                  
                  [self hideSVHUD];
              }];
         }
         else
         {
             [self hideSVHUD];
         }
     }];
}

- (void)restoreProduct
{
    [self showSVHUD:@"Loading" andOption:0];
    
    [[IAPShare sharedHelper].iap restoreProductsWithCompletion:^(SKPaymentQueue *payment, NSError *error) {
        
        BOOL found = NO;
        
        for(SKPaymentTransaction *transaction in payment.transactions)
        {
            NSString *purchased = transaction.payment.productIdentifier;
            
            if([purchased isEqualToString:productId])
            {
                found = YES;
                
                [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Not now",@"buttons":@[@"Restore"],@"title":@"In App Purchase Notice",@"message":@"Do you want to restore purchased Removed Ads ?"} andCompletion:^(int indexButton, id object) {
                    switch (indexButton)
                    {
                        case 0:
                        {
                            [self addValue:@"1" andKey:purchaseKey];
                            
                            NSLog(@"%@",[self getValue:purchaseKey]);
                            
                            [self addValue:@"0" andKey:@"embed"];
                            
//                            [[self CENTER] reAdsAdd];
                            
                            [dataList removeLastObject];
                            
                            [tableView reloadData];
                            
                            [self alert:@"Remove Ads Notice" message:@"Your purchase was successful. Thanks for purchasing!"];

//                            [[DropAlert shareInstance] alertWithInfor:@{/*@"option":@(0),@"text":@"wwww",*/@"cancel":@"Not now",@"buttons":@[@"Restart"],@"title":@"Application restart required",@"message":@"Do you want to restart application to take Remove Ads effect?"} andCompletion:^(int indexButton, id object) {
//                                switch (indexButton)
//                                {
//                                    case 0:
//                                    {
//                                        exit(0);
//                                    }
//                                        break;
//                                    case 1:
//                                        
//                                        break;
//                                    default:
//                                        break;
//                                }
//                            }];
                        }
                            break;
                        case 1:
                            
                            break;
                        default:
                            break;
                    }
                }];
                break;
            }
        }
        
        if(payment.transactions.count == 0 || !found)
        {
            [self alert:@"Remove Ads Notice" message:@"No purchased item was restored, you have to purchase it first"];
        }
        
        [self hideSVHUD];
    }];
}

- (void)presentAds
{
   
}

#define kCOLOR_NON_WHITE_COLOR [UIColor blueColor]

- (void)openStoreProductViewControllerWithITunesItemIdentifier:(NSInteger)iTunesItemIdentifier
{
    [self showSVHUD:@"Loading" andOption:0];
    
    if(SYSTEM_VERSION_GREATER_THAN(@"7"))
    {
        [UINavigationBar appearance].tintColor = [AVHexColor colorWithHexString:kColor];
    }
    
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:iTunesItemIdentifier];
    
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
    UIViewController *viewController = self;
    
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error)
     {
         [self hideSVHUD];
         if (result)
             [viewController presentViewController:storeViewController
                                          animated:YES
                                        completion:nil];
     }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
