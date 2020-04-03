//
//  HT_Player_Item.h
//  HearThis
//
//  Created by Thanh Hai Tran on 10/21/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HT_Player_Item : UITableViewCell

@property(nonatomic, readwrite) BOOL isActive;

- (void)reActive;

@end
