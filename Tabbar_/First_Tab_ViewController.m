//
//  First_Tab_ViewController.m
//  HearThis
//
//  Created by Thanh Hai Tran on 4/4/20.
//  Copyright © 2020 Thanh Hai Tran. All rights reserved.
//

#import "First_Tab_ViewController.h"

@interface First_Tab_ViewController ()

@end

@implementation First_Tab_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didPressMenu:(id)sender {
    [[self ROOT] toggleLeftPanel:sender];
}

@end
