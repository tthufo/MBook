//
//  HT_Player_Item.m
//  HearThis
//
//  Created by Thanh Hai Tran on 10/21/16.
//  Copyright © 2016 Thanh Hai Tran. All rights reserved.
//

#import "HT_Player_Item.h"

@implementation HT_Player_Item

@synthesize isActive;

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)prepareForReuse
{
    [self reActive];
}

- (void)reActive
{
    ((UIImageView*)[self withView:self tag:9869]).image = isActive ? [UIImage imageNamed:@""] : [self animate:@[@"s1", @"s2", @"s3", @"s4", @"s5", @"s6"] andDuration:1.5];
    
//    if(!isActive)
//    {
//        [self startOrStop:!isActive];
//    }
}

- (void)startOrStop:(BOOL)start
{
    if(start)
    {
        ((UIImageView*)[self withView:self tag:11]).alpha = 0;
        
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse animations:^{
            
            ((UIImageView*)[self withView:self tag:11]).alpha = 1;
            
        } completion:nil];
        
    }
    else
    {
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            ((UIImageView*)[self withView:self tag:11]).alpha = 1;
            
        } completion:^(BOOL done) {
            
            [((UIImageView*)[self withView:self tag:11]).layer removeAllAnimations];
            
        }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
