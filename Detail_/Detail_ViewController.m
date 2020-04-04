//
//  Detail_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 4/4/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import "Detail_ViewController.h"

@interface Detail_ViewController ()

@end

@implementation Detail_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)didPressBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
