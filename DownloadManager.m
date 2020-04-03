//
//  DownloadManager.m
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "DownloadManager.h"

static DownloadManager * instan = nil;

@implementation DownloadManager

@synthesize dataList, data, array, timer, timeCompletion;

+ (DownloadManager*)share
{
    if(!instan)
    {
        instan = [DownloadManager new];
    }
    
    return instan;
}

- (void)initTime:(int)time
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1
                                             target:self
                                           selector:@selector(countDown)
                                           userInfo:nil
                                            repeats:YES];
    
    tempTotal =  [[self getValue:@"timer"] intValue] * 60;
}

- (void)completion:(timerCompletion)_completion
{
    self.timeCompletion = _completion;
}

- (void)countDown
{
    self.timeCompletion(tempTotal == 0 ? 0 : 1, tempTotal -= 1, self);
}

- (void)timerStop
{
    if(timer)
    {
        [timer invalidate];
        
        timer = nil;
    }
    
    tempTotal = 0;
}

- (NSMutableArray*)doneDownload
{
    NSMutableArray * dataDone = [NSMutableArray new];
    
    for(Records * r in [Records getFormat:@"finish=%@" argument:@[@"1"]])
    {
        NSDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];
        
        DownLoad * pre = [[DownLoad shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoad *menu, NSDictionary *info) {
            
        }];
        
        [dataDone addObject:pre];
    }
    
    if([[self getValue:@"ipod"] boolValue])
    {
        [dataDone addObjectsFromArray:[self loadMusicItem]];
    }
    
    return  dataDone;
}

- (NSArray*)activeSection
{
    NSMutableArray * arr = [NSMutableArray new];
    
    for(NSString * key in [[DownloadManager share].array.allKeys order])
    {
        if(((NSMutableArray*)[DownloadManager share].array[key]).count != 0)
        {
            [arr addObject:key];
        }
    }
    
    return arr;
}


- (void)loadSort
{
    if(!array)
    {
        array = [NSMutableDictionary new];
        
        for(NSString * alpha in alphabet)
        {
            array[alpha] = [@[] mutableCopy];
        }
    }
 
    for(Records * r in [Records getAll])
    {
        NSMutableDictionary * dataLeft = [NSKeyedUnarchiver unarchiveObjectWithData:r.data];

        dataLeft[@"infor"][@"active"] = @"0";
        
        DownLoad * pre = [[DownLoad shareInstance] forceResume:dataLeft andCompletion:^(int index, DownLoad *obj, NSDictionary *info) {

        }];

        [(NSMutableArray*)array[[[[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] isCharacter] ? [[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] : @"#"] insertObject:pre atIndex:0];
    }
}

- (void)mergeIpod
{
    [self unmergeIpod];

    for(MPMediaItem * ipod in [self loadMusicItem])
    {
        [(NSMutableArray*)array[[[[[ipod valueForProperty:MPMediaItemPropertyTitle] substringToIndex:1] uppercaseString] isCharacter] ? [[[ipod valueForProperty:MPMediaItemPropertyTitle] substringToIndex:1] uppercaseString] : @"#"] insertObject:ipod atIndex:0];
    }
}

- (int)ipodSongs
{
    int count = 0;
    
    for(id item in [self doneDownload])
    {
        if([item isKindOfClass:[MPMediaItem class]])
        {
            count += 1;
        }
    }
    
    return count;
}

- (void)unmergeIpod
{
    for(NSMutableArray * ipod in array.allValues)
    {
        NSMutableArray * temp = [NSMutableArray new];
        
        for(id obj in ipod)
        {
            if([obj isKindOfClass:[MPMediaItem class]])
            {
                [temp addObject:obj];
            }
        }
        
        [ipod removeObjectsInArray:temp];
    }
}

- (NSArray*)loadMusicItem
{
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    
    [everything addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:NO] forProperty:MPMediaItemPropertyIsCloudItem]];
    
    NSArray *itemsFromGenericQuery = [everything items];
    
    return itemsFromGenericQuery;
}

- (void)insertAll:(id)obj
{
    DownLoad * down = (DownLoad*)obj;
    
    NSDictionary * dataLeft = down.downloadData;
    
    if(![self isAllowAll])
    {
        [down forceStop];
    }
    
    [(NSMutableArray*)array[[[[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] isCharacter] ? [[dataLeft[@"infor"][@"title"] substringToIndex:1] uppercaseString] : @"#"] insertObject:down atIndex:0];
    
    if(![UIApplication sharedApplication].isStatusBarHidden)
    {
        [CRToastManager dismissAllNotifications:YES];

        NSDictionary *options = @{
                                  kCRToastTextKey : [NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]],
                                  kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
                                  kCRToastBackgroundColorKey : [AVHexColor colorWithHexString:@"#00A3E2"],
                                  kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
                                  kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                                  kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                                  };
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{
                                    }];
    }
    else
    {
        [self showToast:[NSString stringWithFormat:@"Syncing: %@", down.downloadData[@"infor"][@"title"]] andPos:0];
    }
}

- (BOOL)isAllowAll
{
    int count = 0;
    
    for(NSMutableArray * arr in array.allValues)
    {
        for(id down in arr)
        {
            if([down isKindOfClass:[DownLoad class]])
            {
                if(!((DownLoad*)down).operationFinished && !((DownLoad*)down).operationBreaked)
                {
                    count += 1;
                }
            }
        }
    }
    
    return count >= 5 ? NO : YES;
}

- (void)removeAll:(id)obj
{
    DownLoad * down = (DownLoad*)obj;
    
    for(NSMutableArray * arr in array.allValues)
    {
        for(id downy in arr)
        {
            if([down isKindOfClass:[DownLoad class]])
            {
                if([downy isEqual:down])
                {
                    [arr removeObject:downy];
                    
                    break;
                }
            }
        }
    }
}

- (void)replaceAll:(id)obj index:(int)indexing andSection:(NSString*)section
{
    [((NSMutableArray*)array[section]) replaceObjectAtIndex:indexing withObject:obj];
}

- (void)queueDownloadAll
{
    if([self isAllowAll])
    {
        for(NSMutableArray * arr in array.allValues)
        {
            for(id down in arr)
            {
                if([down isKindOfClass:[DownLoad class]])
                {
                    if((!((DownLoad*)down).operationFinished && ((DownLoad*)down).operationBreaked) && [self isAllowAll])
                    {
                        [down forceContinue];
                    }
                }
            }
        }
    }
}

@end

@implementation NSString (character)

- (BOOL)isCharacter
{
    NSString *myRegex = @"[A-Z]*";
    NSPredicate *myTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", myRegex];
    return  [myTest evaluateWithObject:self];
}

@end

