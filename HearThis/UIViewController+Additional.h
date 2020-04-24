//
//  UIViewController+Additional.h
//  Music
//
//  Created by thanhhaitran on 1/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Additional)

- (void)registerForKeyboardNotifications:(BOOL)isRegister andSelector:(NSArray*)selectors;

- (BOOL)isIphoneX;

- (NSAttributedString *)attributeHTML:(NSString*)htmlString;

- (NSString *)attributeHTMLRaw:(NSString*)htmlString;

@end
