//
//  EM_MenuView.h
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "CustomIOS7AlertView.h"

@class EM_MenuView;

typedef void (^MenuCompletion)(int index, id object, EM_MenuView * menu);

@interface EM_MenuView : CustomIOS7AlertView

- (id)initWithRate:(NSDictionary*)info;

- (id)initWithDate:(NSDictionary*)info;

- (id)initWithWebView:(NSDictionary*)info;

- (id)initWithTime:(NSDictionary*)info;

- (id)initWithLogIn:(NSDictionary*)info;

- (id)initWithSubMenu:(NSDictionary*)info;

- (id)initWithAlert:(NSDictionary*)info;

- (id)initWithSubDetailMenu:(NSDictionary*)info;

- (id)initWithSubList_DynamicMenu:(NSDictionary*)info;

- (id)initWithSettingMenu:(NSDictionary*)info;

- (id)initWithPreviewMenu:(NSDictionary*)info;

- (id)initWithConfirm:(NSDictionary*)info;

- (id)initWithCancel:(NSDictionary*)info;

- (id)initWithRestrict:(NSDictionary*)info;

- (id)initWithPage:(NSDictionary*)info;

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion;

- (EM_MenuView*)disableCompletion:(MenuCompletion)_completion;

@property(nonatomic,copy) MenuCompletion menuCompletion;

@end
