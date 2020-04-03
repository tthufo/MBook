//
//  DownloadManager.h
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DownloadManager;

typedef void (^timerCompletion)(int index, int time, DownloadManager * manager);

@interface DownloadManager : NSObject
{
    int tempTotal;
}

@property(nonatomic, retain) NSMutableArray * dataList, * data;

@property(nonatomic, retain) NSMutableDictionary * array;

@property(nonatomic, retain) NSTimer * timer;

@property(nonatomic,copy) timerCompletion timeCompletion;

+ (DownloadManager*)share;

- (void)initTime:(int)time;

- (void)completion:(timerCompletion)_completion;

- (void)timerStop;

- (NSMutableArray*)doneDownload;

- (NSArray*)activeSection;

- (int)ipodSongs;

- (void)loadSort;

- (void)mergeIpod;

- (void)unmergeIpod;

- (void)insertAll:(id)obj;

- (void)removeAll:(id)obj;

- (void)replaceAll:(id)obj index:(int)indexing andSection:(NSString*)section;

- (void)queueDownloadAll;

- (BOOL)isAllowAll;

@end


@interface NSString (character)


- (BOOL)isCharacter;

@end
