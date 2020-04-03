//
//  History.m
//  MusicTube
//
//  Created by thanhhaitran on 8/9/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "History.h"

#import "M_Core.h"

@implementation History

@synthesize hid, data, date, autoid, time;

+ (BOOL)addSystem:(NSDictionary*)dict
{
    M_Core *db = [M_Core shareInstance];
    
    NSUInteger count = [[self getFormat:@"(hid=%@) AND (date=%@)" argument:@[dict[@"hid"], [[NSDate date] stringWithFormat:@"dd/MM/yyyy"]]] count];
        
    if (count > 0)
    {
        History *s = [[self getFormat:@"(hid=%@) AND (date=%@)" argument:@[dict[@"hid"], [[NSDate date] stringWithFormat:@"dd/MM/yyyy"]]] lastObject];
                
        s.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
        
        [db saveContext];
        
        return NO;
    }
    
    History *b = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext: [db managedObjectContext]];
    
    if (dict[@"hid"])
    {
        b.hid = dict[@"hid"];
    }
    
    if (dict[@"data"])
    {
        b.data = [NSKeyedArchiver archivedDataWithRootObject:dict[@"data"]];
    }
    
    if(![self getValue:@"autoID"])
    {
        [self addValue:@"1" andKey:@"autoID"];
    }
    else
    {
        [self addValue:[NSString stringWithFormat:@"%i",[[self getValue:@"autoID"] intValue] + 1] andKey:@"autoID"];
    }
    
    b.autoid = [self getValue:@"autoID"];//dict[@"autoid"];
    
    b.date = [[NSDate date] stringWithFormat:@"dd/MM/yyyy"];
    
    b.time = [NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]];
    
    [db saveContext];
    
    return YES;
}

+ (NSArray*)sortByDate
{
    int start = 0;
    
    NSMutableArray * returnArr = [NSMutableArray new];
    
    while (start > -30) {
        
       NSArray * item = [History getFormat:@"date=%@" argument:@[[[[NSDate date] nowByTime:start] stringWithFormat:@"dd/MM/yyyy"]]];
        
       if(item.count != 0)
       {
            [returnArr addObject:@{@"title":[[[NSDate date] nowByTime:start] stringWithFormat:@"dd/MM/yyyy"],@"array":item}];
       }
        start -= 1;
    }
    
    return returnArr;
}

+ (void)addValue:(id)value andKey:(NSString*)key
{
    NSDictionary * temp = [NSDictionary dictionaryWithObjectsAndKeys:key,@"hid",value,@"data", nil];
    
    [self addSystem:temp];
}

+ (id)getValue:(NSString*)key
{
    History * s = [[self getFormat:@"hid=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    id result = s.data;
    
    return  result;
}

+ (NSArray *)getFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"History" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    [fr setEntity:ed];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:format argumentArray:argument];
    
    [fr setPredicate:p1];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];

    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];

    return result;
}

+ (void)removeValue:(NSString*)key
{
    M_Core *db = [M_Core shareInstance];
    
    History * s = [[self getFormat:@"hid=%@" argument:[NSArray arrayWithObjects:key, nil]] lastObject];
    
    if(s)
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearAll
{
    M_Core *db = [M_Core shareInstance];
    
    for(History * s in [History getAll])
    {
        [[db managedObjectContext] deleteObject:s];
    }
    
    [db saveContext];
}

+ (void)clearFormat:(NSString *)format argument:(NSArray *)argument
{
    M_Core *db = [M_Core shareInstance];
    
    NSArray * s = [History getFormat:format argument:argument];
    
    for(History * k in s)
    {
        [[db managedObjectContext] deleteObject:k];
    }
    
    [db saveContext];
}

+ (NSArray *)getAll
{
    M_Core *db = [M_Core shareInstance];
    
    NSEntityDescription *ed = [NSEntityDescription entityForName:@"History" inManagedObjectContext:[db managedObjectContext]];
    
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    
    [fr setReturnsObjectsAsFaults:NO];
    
    [fr setEntity:ed];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:NO];
    
    [fr setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSArray *result = [[db managedObjectContext] executeFetchRequest:fr error:nil];

    return result;
}

@end
