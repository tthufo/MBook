//
//  M_Menu.h
//  MusicTube
//
//  Created by thanhhaitran on 8/10/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class M_Menu;

typedef void (^Completion)(int index, M_Menu * menu, NSDictionary* info);

@interface M_Menu : UIView

- (void)resetInfo:(NSDictionary*)dict;

- (id)initWithInfo:(NSMutableDictionary*)dict;

- (void)didShow:(Completion)_completion;

- (void)didClose;

- (void)didCloseWithAction;

@property(nonatomic,copy) Completion completion;

@end
