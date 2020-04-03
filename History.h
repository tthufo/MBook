//
//  History.h
//  MusicTube
//
//  Created by thanhhaitran on 8/9/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface History : NSManagedObject

@property (nullable, nonatomic, retain) NSString *hid;

@property (nullable, nonatomic, retain) NSData *data;

@property (nullable, nonatomic, retain) NSString *date;

@property (nullable, nonatomic, retain) NSString *autoid;

@property (nullable, nonatomic, retain) NSNumber *time;

+ (void)addValue:(id)value andKey:(NSString*)key;

+ (id)getValue:(NSString*)key;

+ (void)removeValue:(NSString*)key;

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument;

+ (NSArray*)getAll;

+ (void)clearAll;

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument;


+ (NSArray*)sortByDate;

@end

NS_ASSUME_NONNULL_END
