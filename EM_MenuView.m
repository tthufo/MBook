//
//  EM_MenuView.m
//  Emoticon
//
//  Created by thanhhaitran on 2/7/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "EM_MenuView.h"

#import "MBCircularProgressBarView.h"

#import "MeBook-Swift.h"

@interface EM_MenuView ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITextFieldDelegate>
{
    NSMutableArray * dataList;
}
@end

@implementation EM_MenuView

@synthesize menuCompletion;

- (id)initWithPage:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreatePageView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreatePageView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 78)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor], @"Bcorner":@(5), @"Bwidth":@(0)}];

    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][14];
    
    contentView.frame = CGRectMake(0, 0, 300, 78);
    
    UITextField * paging = ((UITextField*)[self withView:contentView tag: 2]);
            
//    [paging becomeFirstResponder];
    
//    UILabel * total = ((UILabel*)[self withView:contentView tag: 3]);
//
//    total.text = [dict getValueFromKey:@"total"];

    UIButton * action = ((UIButton*)[self withView:contentView tag: 4]);
        
    [action actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
//        if ([paging.text integerValue] > [[dict getValueFromKey:@"total"] integerValue]) {
//            [paging resignFirstResponder];
//            [self showToast:@"Số trang không chính xác" andPos:0];
//            return;
//        }
        
        if(self.menuCompletion)
        {
            self.menuCompletion(3, @{@"page": paging.text}, self);
        }
        
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (id)initWithRate:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateRateView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateRateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 315)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][13];
    
    contentView.frame = CGRectMake(0, 0, 300, 315);
    
    __block double ratingStar = 0;
    CosmosView * rating = ((CosmosView*)[self withView:contentView tag: 1]);

    rating.didTouchCosmos = ^(double rating) {
        ratingStar = rating;
    };
    
    UITextView * comment = ((UITextView*)[self withView:contentView tag: 2]);
    comment.placeHolder = @"Viết đánh giá ...";
    
    UIButton * rate = ((UIButton*)[self withView:contentView tag: 3]);
        
    [rate actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(3, @{@"comment":comment.text, @"rating": [NSString stringWithFormat:@"%.1f", ratingStar]}, self);
        }
        
        [comment resignFirstResponder];
    }];
    
    UIButton * action = ((UIButton*)[self withView:contentView tag: 4]);
        
    [action actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
    return YES;
}

- (id)initWithRestrict:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateRestrictView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateRestrictView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight - 0)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][12];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UIButton * action = ((UIButton*)[self withView:contentView tag: 4]);
    
    [action setTitle: dict[@"line3"] forState:UIControlStateNormal];
    
    [action actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(4, @{}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithCancel:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateCancelView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateCancelView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 319, 198)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][11];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UILabel * line1 = ((UILabel*)[self withView:contentView tag: 1]);
    
    line1.text = dict[@"line1"];
        
    
    UIButton * action = ((UIButton*)[self withView:contentView tag: 2]);
        
    [action actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(2, @{}, self);
        }
        
        [self close];
    }];
    
    
    UIButton * cancel = ((UIButton*)[self withView:contentView tag: 3]);
        
    [cancel actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(3, @{}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithConfirm:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateConfirmView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateConfirmView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight - 0)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][10];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    ((UIImageView*)[self withView:contentView tag: 1]).image = [UIImage imageNamed: [NSString stringWithFormat:@"ico_%@", dict[@"image"]]];

    
    UILabel * line1 = ((UILabel*)[self withView:contentView tag: 2]);
    
    line1.text = dict[@"line1"];
    
    if (![[dict getValueFromKey:@"image"] isEqualToString:@"success"]) {
        [line1 setTextColor:[UIColor systemRedColor]];
    }
    
    ((UILabel*)[self withView:contentView tag: 3]).text = dict[@"line2"];
    
    
    UIButton * action = ((UIButton*)[self withView:contentView tag: 4]);
    
    [action setTitle: dict[@"line3"] forState:UIControlStateNormal];
    
    [action actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(4, @{}, self);
        }
        
//        [self close];
    }];
    
    
    UIButton * cancel = ((UIButton*)[self withView:contentView tag: 5]);
    
    cancel.hidden = ![dict responseForKey:@"isCancel"];
    
    [cancel actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(5, @{}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithDate:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateDateView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (NSDate *)getDateFromDateString:(NSString *)dateString
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (UIView*)didCreateDateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 247)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(5),@"Bwidth":@(0)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][9];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UIDatePicker * datePicker = ((UIDatePicker*)[self withView:contentView tag:11]);

    if([dict responseForKey:@"date"])
    {
        [datePicker setDate:[self getDateFromDateString:dict[@"date"]] animated:YES];
    }
    
    [(UIButton*)[self withView:contentView tag:14] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        [self close];
        
    }];
    
    [(UIButton*)[self withView:contentView tag:15] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        
        if(self.menuCompletion)
        {
            self.menuCompletion(0, @{@"date":[datePicker.date stringWithFormat:@"dd/MM/yyyy"]}, self);
        }
        
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}


- (id)initWithPreviewMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreatePreviewView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreatePreviewView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.screenWidth, self.screenHeight - 0)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][7];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    if ([dict[@"image"] isKindOfClass:[NSString class]]) {
        [(UIImageView*)[self withView:contentView tag:11] sd_setImageWithURL:[NSURL URLWithString:dict[@"image"]] placeholderImage:[UIImage imageNamed:@"ic_avatar"]];
    } else {
        ((UIImageView*)[self withView:contentView tag:11]).image = dict[@"image"];
    }
    
    [((UIButton*)[self withView:contentView tag:12]) actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        [self close];
    }];
    
    [commentView addSubview:contentView];
    
    return commentView;
}


- (id)initWithSettingMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateSettingView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateSettingView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 310, 135)];
    
    [commentView setBackgroundColor:[UIColor clearColor]];
    
    UIView *contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][8];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    [(UIView*)[self withView:contentView tag:111] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        self.menuCompletion(1, @{}, self);
        [self close];
    }];
    
    
    [(UIView*)[self withView:contentView tag:222] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        self.menuCompletion(2, @{}, self);
        [self close];
    }];
    
    [(UIView*)[self withView:contentView tag:333] actionForTouch:@{} and:^(NSDictionary *touchInfo) {
        self.menuCompletion(3, @{}, self);
        [self close];
    }];
  
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithWebView:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateWebView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateWebView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, screenHeight1 - 100)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][6];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
     
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithTime:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateTime:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateTime:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 115)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][3];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    if(dict[@"time"])
    {        
        ((UILabel*)[self withView:contentView tag:11]).text = [dict[@"time"] intValue] == 0 ? @"Turn off after: ∞" : [NSString stringWithFormat:@"Turn off after: %i min(s)",[dict[@"time"] intValue]];
        
        ((UISlider*)[self withView:contentView tag:12]).value = [dict[@"time"] intValue];
        
        [((UISlider*)[self withView:contentView tag:12]) addTarget:self action:@selector(didSlideTo:) forControlEvents:UIControlEventValueChanged];
    }
    
    [((UIButton*)[self withView:contentView tag:16]) addTarget:self action:@selector(didPressSet:) forControlEvents:UIControlEventTouchUpInside];

    [commentView addSubview:contentView];
    
    return commentView;
}

- (void)didPressSet:(UIButton*)sender
{
    menuCompletion(1983, ((UISlider*)[self withView:self tag:12]), self);
}

- (void)didSlideTo:(UISlider*)slider
{
    ((UILabel*)[self withView:[self withView:self tag:15] tag:11]).text = (int)slider.value == 0 ? @"Turn off after: ∞" : [NSString stringWithFormat:@"Turn off after: %i min(s)",(int)slider.value];
}

- (void)didPressTimer:(UIButton*)sender
{
    NSArray * total = [[((UIDatePicker*)[self withView:self tag:11]).date stringWithFormat:@"HH:mm"] componentsSeparatedByString:@":"];
        
    int time = ([[total firstObject] intValue] * 60 * 60) + ([[total lastObject] intValue] * 60);
    
    [self addValue:@{@"time":[((UIDatePicker*)[self withView:self tag:11]).date stringWithFormat:@"HH:mm"],@"title":[sender.titleLabel.text isEqualToString:@"Set"] ? @"Stop" : @"Set"} andKey:@"timer"];
    
    menuCompletion([sender.titleLabel.text isEqualToString:@"Set"] ? 1 : 0, @(time), self);
}

- (id)initWithSubList_DynamicMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateSubList_DynamicView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateSubList_DynamicView:(NSDictionary*)dict
{
    dataList = [[NSMutableArray alloc] initWithArray:dict[@"subs"]];
    
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 270)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][4];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    UITableView * tableView = (UITableView*)[self withView:contentView tag:11];
    
    tableView.delegate = self;
    
    tableView.dataSource = self;
    
    [(UIButton*)[self withView:contentView tag:16] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}


- (id)initWithSubDetailMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateSubListDetailView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateSubListDetailView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 206)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][3];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    ((UILabel*)[self withView:contentView tag:11]).text = dict[@"sub_description"];

    ((UIButton*)[self withView:contentView tag:12]).accessibilityLabel = [dict bv_jsonStringWithPrettyPrint:NO];
    
    [((UIButton*)[self withView:contentView tag:12]) addTarget:self action:@selector(didPressButtonSubs:) forControlEvents:UIControlEventTouchUpInside];
    
    [(UIButton*)[self withView:contentView tag:16] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}


- (id)initWithSubListMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateSubListView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateSubListView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 282)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][2];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    int i = 0;
        
    for(UIView * button in contentView.subviews)
    {
        if([button isKindOfClass:[UIButton class]] && button.tag != 16)
        {
            [(UIButton*)button addTarget:self action:@selector(didPressButtonSubs:) forControlEvents:UIControlEventTouchUpInside];
            
            if(i > ((NSArray*)dict[@"subs"]).count || ((NSArray*)dict[@"subs"]).count == 0) continue;

            [(UIButton*)button setTitle:dict[@"subs"][i][@"sub_name"] forState:UIControlStateNormal];
            
            ((UIButton*)button).accessibilityLabel = [dict[@"subs"][i] bv_jsonStringWithPrettyPrint:NO];
            
            i++;
        }
    }
    
    [(UIButton*)[self withView:contentView tag:16] addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (id)initWithAlert:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateAlertView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateAlertView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 100, 100)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][2];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    ((UILabel*)[self withView:contentView tag:11]).text = dict[@"message"];
    
    [commentView addSubview:contentView];
    
    [self performSelector:@selector(close) withObject:nil afterDelay:0.9];
    
    return commentView;
}

- (id)initWithSubMenu:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateSubView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateSubView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 211)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][1];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    ((UITextView*)[self withView:contentView tag:11]).text = dict[@"message"];
    
    [(UIButton*)[self withView:contentView tag:15] addTarget:self action:@selector(didPressView) forControlEvents:UIControlEventTouchUpInside];
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (void)didPressView
{
    menuCompletion(0, @"go", self);
}

- (id)initWithLogIn:(NSDictionary*)info
{
    self = [self init];
    
    [self setContainerView:[self didCreateView:info]];
    
    [self setUseMotionEffects:true];
    
    return self;
}

- (UIView*)didCreateView:(NSDictionary*)dict
{
    UIView *commentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth1 - 30, 207)];
    
    [commentView withBorder:@{@"Bcolor":[UIColor whiteColor],@"Bcorner":@(12),@"Bwidth":@(2)}];
    
    UIView* contentView = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:self options:nil][0];
    
    contentView.frame = CGRectMake(0, 0, commentView.frame.size.width, commentView.frame.size.height);
    
    
    [((MBCircularProgressBarView*)[self withView:contentView tag:100]) setValue:[YouTube freeDiskSpaceInBytes] / [YouTube totalDiskSpaceInBytes] * 100 animateWithDuration:20];
    
    
    ((UILabel*)[self withView:contentView tag:11]).text = [NSString stringWithFormat:@"Free: %@", [YouTube freeDiskSpace]];

    ((UILabel*)[self withView:contentView tag:12]).text = [NSString stringWithFormat:@"Synced: %@", dict[@"sync"]];

    ((UILabel*)[self withView:contentView tag:15]).text = [NSString stringWithFormat:@"Synced song(s): %lu",(unsigned long)[Records getAll].count];

    ((UILabel*)[self withView:contentView tag:16]).text = [NSString stringWithFormat:@"iPod song(s): %lu",(unsigned long)[[DownloadManager share] ipodSongs]];
    
    ((UILabel*)[self withView:contentView tag:14]).text = @"Space Left Percentage";

    
    
    [commentView addSubview:contentView];
    
    return commentView;
}

- (void)didPressButtonSubs:(UIButton*)button
{
    if(button.accessibilityLabel.length == 0)
    {
        [self showToast:@"Lỗi xảy ra, vui lòng thử lại" andPos:0];
        
        return;
    }
    
    menuCompletion(button.tag, button.accessibilityLabel, self);
}

- (void)didPressButton:(UIButton*)button
{
    [self endEditing:YES];

    NSMutableArray * arr = [NSMutableArray new];
    
    for(UIView * v in [[[self.subviews lastObject].subviews lastObject].subviews lastObject].subviews)
    {
        if([v isKindOfClass:[UITextField class]])
        {
            [arr addObject:((UITextField*)v).text];
        }
    }
        
    menuCompletion(button.tag, arr, self);
}

- (EM_MenuView*)showWithCompletion:(MenuCompletion)_completion
{
    menuCompletion = _completion;
    
    [self show];
    
    return self;
}

- (EM_MenuView*)disableCompletion:(MenuCompletion)_completion
{
    menuCompletion = _completion;
    
    [self show:NO];
    
    return self;
}

- (void)close
{
    [super close];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self endEditing:YES];
    
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return dataList.count == 0 ? 100 : 64;
}

- (UITableViewCell*)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataList.count == 0)
    {
        return [[NSBundle mainBundle] loadNibNamed:@"LT_Header" owner:self options:nil][4];
    }
    
    UITableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:@"buttonCell"];
    
    if (!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"EM_Menu" owner:nil options:nil][5];
    }
    
    [(UIButton*)[self withView:cell tag:11] addTarget:self action:@selector(didPressButtonSubs:) forControlEvents:UIControlEventTouchUpInside];

    [(UIButton*)[self withView:cell tag:11] setTitle:dataList[indexPath.row][@"sub_name"] forState:UIControlStateNormal];

    ((UIButton*)[self withView:cell tag:11]).accessibilityLabel = [dataList[indexPath.row] bv_jsonStringWithPrettyPrint:NO];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataList.count == 0 ? 1 : dataList.count;
}


@end
