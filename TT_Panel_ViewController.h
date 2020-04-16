//
//  M_Panel_ViewController.h
//  ProTube
//
//  Created by thanhhaitran on 8/4/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "JASidePanelController.h"

@interface TT_Panel_ViewController : JASidePanelController

//- (void)show;
//
//- (void)hide;
//
//- (void)embed;
//
//- (void)unEmbed;

@end

@interface JASidePanelController (extend)

- (CGRect)_adjustCenterFrame;

@end
