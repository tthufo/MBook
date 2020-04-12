//
//  UIViewController+Additional.m
//  Music
//
//  Created by thanhhaitran on 1/5/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "UIViewController+Additional.h"

@implementation UIViewController (Additional)

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[AVHexColor colorWithHexString:@"#FFFFFF"]}];
    
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
     
}

- (void)registerForKeyboardNotifications:(BOOL)isRegister andSelector:(NSArray*)selectors
{
    if(isRegister)
    {
        [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:NSSelectorFromString(selectors[0]) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addUniqueObserver:self selector:NSSelectorFromString(selectors[1]) name:UIKeyboardWillHideNotification object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

- (BOOL)isIphoneX {
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        CGFloat topPadding = window.safeAreaInsets.top;
        if(topPadding > 20) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

- (NSAttributedString *)attributeHTML:(NSString*)htmlString {
    NSString * string = [NSString stringWithFormat:@"<span style=\"font-size: 14;\">%@</span>", htmlString];
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[string dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    return attrStr;
}

@end
