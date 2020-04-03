//
//  M_Detail_ViewController.h
//  Music
//
//  Created by thanhhaitran on 11/25/15.
//  Copyright © 2015 thanhhaitran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DetailDelegate <NSObject>

@optional

- (void)didReloadPlayList:(NSDictionary*)dict;

@end

@interface M_Detail_ViewController : UIViewController

@property (nonatomic, retain) NSString * playListName, * titleName;

@property (nonatomic, assign) id <DetailDelegate> delegate;

- (void)didReloadData;

@end
