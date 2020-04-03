//
//  iTemCell.m
//  SoundC
//
//  Created by thanhhaitran on 9/6/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    self.clickedLocation = [touch locationInView:touch.view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
