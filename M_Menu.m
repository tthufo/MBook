//
//  M_Menu.m
//  MusicTube
//
//  Created by thanhhaitran on 8/10/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "M_Menu.h"

//#import "ListCell.h"

@interface M_Menu()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray * dataList;
    
    NSMutableDictionary * infoDict;
}

@end

@implementation M_Menu

@synthesize completion;

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    }
    return self;
}

- (void)resetInfo:(NSDictionary*)dict
{
    if([dict responseForKey:@"data"])
    {
        [dataList removeAllObjects];

        [dataList addObjectsFromArray:dict[@"data"]];
    }
    
    if([dict responseForKey:@"off"])
    {
        infoDict[@"off"] = dict[@"off"];
    }
    else
    {
        if([infoDict objectForKey:@"off"])
        {
            [infoDict removeObjectForKey:@"off"];
        }
    }
    
    [((UITableView*)[self withView:self tag:11]) reloadData];

    if([dict responseForKey:@"active"])
    {
        infoDict[@"active"] = dict[@"active"];
        
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            
            [((UITableView*)[self withView:self tag:11]) scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[infoDict[@"active"] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}

- (id)initWithInfo:(NSMutableDictionary*)dict
{
    self = [self init];
    
    infoDict = dict;
    
    self.backgroundColor = [UIColor clearColor];
    
    UIButton * bg = [UIButton buttonWithType:UIButtonTypeCustom];
    
    bg.frame = CGRectMake(0, 0, screenWidth1, screenHeight1);
    
    bg.backgroundColor = [UIColor blackColor];
    
    bg.alpha = 0.3;
    
    [bg addTapTarget:self action:@selector(didClose)];
    
    [self addSubview:bg];
    
    
    int height = [dict[@"ident"] isEqualToString:@"itemcell"] ? screenHeight1 : [dict[@"ident"] isEqualToString:@"region"] || [dict[@"ident"] isEqualToString:@"filter"] || [dict[@"ident"] isEqualToString:@"download"] || [infoDict[@"ident"] isEqualToString:@"genre"] || [infoDict[@"ident"] isEqualToString:@"search"] ? screenHeight1 - 64 : screenHeight1 - 64;
    
    UIView * contentView = [[NSBundle mainBundle] loadNibNamed:@"M_Menu" owner:nil options:nil][!dict[@"viewNo"] ? 0 : [dict[@"viewNo"] intValue]];
    
    contentView.frame = CGRectMake(0, screenHeight1, screenWidth1, height);
    
    
    [((UIButton*)[self withView:contentView tag:999]) addTapTarget:self action:@selector(didClose)];
    
    if(dict)
    {
        if([dict responseForKey:@"tag"])
        {
            self.tag = [dict[@"tag"] intValue];
        }
        
        [dict[@"window"] addSubview:self];
        
        if([dict[@"ident"] isEqualToString:@"region"])
        {
            
        }
        else if([dict[@"ident"] isEqualToString:@"filter"])
        {
            if(![self getValue:@"filterOpt"])
            {
                [self addValue:[@[@"video",@"relevance",@"all",@"any"] mutableCopy] andKey:@"filterOpt"];
            }
        }
        else if([dict[@"ident"] isEqualToString:@"download"])
        {
            
        }
        else if([dict[@"ident"] isEqualToString:@"genre"])
        {
            if(![self getValue:@"genreOpt"])
            {
                [self addValue:[@[@"trending",@"soundcloud:genres:all-music",@"soundcloud:genres:all-music"] mutableCopy] andKey:@"genreOpt"];
            }
        }
        else if([dict[@"ident"] isEqualToString:@"search"])
        {
            if(![self getValue:@"searchOpt"])
            {
                [self addValue:[@[@"",@"",@"",@(0),@(0)] mutableCopy] andKey:@"searchOpt"];
            }
        }
        else if([dict[@"ident"] isEqualToString:@"itemcell"])
        {
            dataList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
        }
        else
        {
            dataList = [[NSMutableArray alloc] initWithArray:dict[@"data"]];
        }
    }
    
    ((UITableView*)[self withView:contentView tag:11]).delegate = self;
    
    ((UITableView*)[self withView:contentView tag:11]).dataSource = self;

    [((UIButton*)[self withView:contentView tag:12]) addTapTarget:self action:@selector(didPressButton:)];

    [((UIButton*)[self withView:contentView tag:14]) addTapTarget:self action:@selector(didPressButton:)];
    
    [((UIButton*)[self withView:contentView tag:15]) addTapTarget:self action:@selector(didPressShare:)];

    [self addSubview:contentView];
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{

        CGRect rect = contentView.frame;
        
        rect.origin.y -= height;
        
        contentView.frame = rect;
        
    } completion:^(BOOL finished) {
        
        [((UITableView*)[self withView:contentView tag:11]) reloadData];
        
        if([dict[@"ident"] isEqualToString:@"region"])
        {
            NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
            
            for(NSString * value in [regions.allKeys order])
            {
                if([regions[value] isEqualToString:infoDict[@"active"]])
                {
                    [((UITableView*)[self withView:contentView tag:11]) scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[regions.allKeys order] indexOfObject:value] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        }
        
        if([dict[@"ident"] isEqualToString:@"search"])
        {
            [((UITableView*)[self withView:contentView tag:11]) scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[self search][3] intValue] inSection:[[self search][4] intValue]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
        
        if([dict[@"ident"] isEqualToString:@"itemcell"] && [dict responseForKey:@"active"])
        {
            if([infoDict[@"active"] intValue] >= 0)
            {
                [((UITableView*)[self withView:contentView tag:11]) scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[infoDict[@"active"] intValue] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }
        }
    }];
    
    return self;
}

- (NSMutableArray*)search
{
    return [self getValue:@"searchOpt"];
}

- (NSMutableArray*)genre
{
    return [self getValue:@"genreOpt"];
}

- (NSMutableArray*)filter
{
    return [self getValue:@"filterOpt"];
}

- (void)didPressShare:(UIButton*)sender
{
    self.completion(2, self, @{});
    
    [self didClose];
}

- (void)didPressButton:(UIButton*)sender
{
    if(sender.tag == 12)
    {
        self.completion(1, self, nil);
        
        if([infoDict[@"ident"] isEqualToString:@"filter"])
        {
            self.completion(0, self, @{@"data":[self filter]});
        }
        
        if([infoDict[@"ident"] isEqualToString:@"genre"])
        {
            self.completion(0, self, @{@"data":[self genre]});
        }
        
        if([infoDict[@"ident"] isEqualToString:@"search"])
        {
            self.completion(0, self, @{@"data":[self search]});
        }
    }
    else
    {
        [self didClose];
    }
}

- (void)didClose
{
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        
        CGRect rect = ((UIView*)[self withView:self tag:10]).frame;
        
        rect.origin.y = screenHeight1;
        
        ((UIView*)[self withView:self tag:10]).frame = rect;
        
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
        
        if([infoDict[@"ident"] isEqualToString:@"filter"])
        {
            self.completion(-1, self, @{@"data":[self filter]});
        }
        
        if([infoDict[@"ident"] isEqualToString:@"genre"])
        {
            self.completion(-1, self, @{@"data":[self genre]});
        }
        
        if([infoDict[@"ident"] isEqualToString:@"search"])
        {
            self.completion(-1, self, @{@"data":[self search]});
        }
    }];
}

- (void)didCloseWithAction
{
    [self didClose];
    
    if([infoDict[@"ident"] isEqualToString:@"filter"])
    {
        self.completion(-1, self, @{@"data":[self filter]});
    }
    
    if([infoDict[@"ident"] isEqualToString:@"genre"])
    {
        self.completion(-1, self, @{@"data":[self genre]});
    }
    
    if([infoDict[@"ident"] isEqualToString:@"search"])
    {
        self.completion(-1, self, @{@"data":[self search]});
    }
}

- (void)didShow:(Completion)_completion
{
    self.completion = _completion;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [infoDict[@"ident"] isEqualToString:@"download"] ? ((NSDictionary*)infoDict[@"data"]).allKeys.count : [infoDict[@"ident"] isEqualToString:@"filter"] || [infoDict[@"ident"] isEqualToString:@"genre"] || [infoDict[@"ident"] isEqualToString:@"search"] ? [[[self filter] firstObject] isEqualToString:@"video"] ? ((NSDictionary*)infoDict[@"data"]).allKeys.count : 1 : 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ([infoDict[@"ident"] isEqualToString:@"filter"] || [infoDict[@"ident"] isEqualToString:@"download"] || [infoDict[@"ident"] isEqualToString:@"genre"] || [infoDict[@"ident"] isEqualToString:@"search"]) ? [((NSDictionary*)infoDict[@"data"]).allKeys order][section] : @"";
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section
{
    if([infoDict[@"ident"] isEqualToString:@"filter"] || [infoDict[@"ident"] isEqualToString:@"download"] || [infoDict[@"ident"] isEqualToString:@"genre"] || [infoDict[@"ident"] isEqualToString:@"search"])
    {
        NSString * key = [((NSDictionary*)infoDict[@"data"]).allKeys order][section];
        
        return [infoDict[@"ident"] isEqualToString:@"download"] && section == 1 ? [List getAll].count == 0 ? 1 : [List getAll].count : [((NSDictionary*)((NSDictionary*)infoDict[@"data"])[key]).allValues order].count;
    }
    return [infoDict[@"ident"] isEqualToString:@"region"] ? [((NSDictionary*)infoDict[@"data"]).allKeys order].count : dataList.count;
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ![infoDict responseForKey:@"ident"] ? 65 : ![infoDict[@"ident"] isEqualToString:@"itemcell"] ? 47 : 107;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [_tableView dequeueReusableCellWithIdentifier:infoDict[@"ident"] ? infoDict[@"ident"] : @"listCell"];
    
    if(!cell)
    {
        cell = [[NSBundle mainBundle] loadNibNamed:@"CellView" owner:self options:nil][infoDict[@"cellNo"] ? [infoDict[@"cellNo"] intValue] : 0];
    }
    
    if([infoDict[@"ident"] isEqualToString:@"region"])
    {
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        ((UILabel*)[self withView:cell tag:12]).text = [regions.allKeys order][indexPath.row];
        
        ((UIImageView*)[self withView:cell tag:11]).image = [UIImage imageNamed:regions[[regions.allKeys order][indexPath.row]]];
        
        cell.accessoryType = [regions[[regions.allKeys order][indexPath.row]] isEqualToString:infoDict[@"active"]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone ;
    }
    else if([infoDict[@"ident"] isEqualToString:@"filter"])
    {
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];

        NSString * key = [regions.allKeys order][indexPath.section];
        
        NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).text = subKey;
        
        cell.accessoryType = [regions[key][subKey] isEqualToString:[self filter][indexPath.section]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone ;
    }
    else if([infoDict[@"ident"] isEqualToString:@"download"])
    {
        if(indexPath.section == 0)
        {
            NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
            
            NSString * key = [regions.allKeys order][indexPath.section];
            
            NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
            
            ((UILabel*)[self withView:cell tag:11]).text = subKey;
            
            ((UILabel*)[self withView:cell tag:15]).hidden = YES;
        }
        else
        {
            if([List getAll].count != 0)
            {
                List * list = [List getAll][indexPath.row];
                
                ((UILabel*)[self withView:cell tag:11]).text = [NSString stringWithFormat:@"%i.%@",indexPath.row + 1, list.name];
                
                ((UILabel*)[self withView:cell tag:15]).hidden = NO;
                
                ((UILabel*)[self withView:cell tag:15]).text = [NSString stringWithFormat:@"%i",[Item getFormat:@"name=%@" argument:@[list.name]].count];
            }
            else
            {
                ((UILabel*)[self withView:cell tag:11]).text = @"Playlist Emtpy";
                
                ((UILabel*)[self withView:cell tag:15]).hidden = YES;
            }
        }
    }
    else if([infoDict[@"ident"] isEqualToString:@"genre"] || [infoDict[@"ident"] isEqualToString:@"search"])
    {
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        NSString * key = [regions.allKeys order][indexPath.section];
        
        NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).text = subKey;
        
        cell.accessoryType = [regions[key][subKey] isEqualToString:[infoDict[@"ident"] isEqualToString:@"search"] ? [self search][indexPath.section] : [self genre][indexPath.section]] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone ;
    }
    else if([infoDict[@"ident"] isEqualToString:@"itemcell"])
    {
        id dict = dataList[indexPath.row];
        
        NSDictionary * list = [dict isKindOfClass:[MPMediaItem class]] ? [self ipodItem:(MPMediaItem*)dict] : [dict isKindOfClass:[Item class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:((Item*)dict).data] : [dict isKindOfClass:[DownLoad class]] ?  ((DownLoad*)dict).downloadData[@"infor"] : [dict isKindOfClass:[History class]] ?
                                    [NSKeyedUnarchiver unarchiveObjectWithData:((History*)dict).data] :
        [dict responseForKey:@"track"] ? dict[@"track"] : dict;
        
        if([dict isKindOfClass:[MPMediaItem class]])
        {
            ((UIImageView*)[self withView:cell tag:10]).image = [UIImage imageNamed:@"ipod"];
        }
        else
        {
            [((UIImageView*)[self withView:cell tag:10]) sd_setImageWithURL:[NSURL URLWithString:[[list getValueFromKey:@"artwork_url"] stringByReplacingOccurrencesOfString:@"large" withString:@"t300x300"]] placeholderImage:kAvatar completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (error) return;
                if (image && cacheType == SDImageCacheTypeNone)
                {
                    [UIView transitionWithView:((UIImageView*)[self withView:cell tag:10])
                                      duration:0.5
                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                    animations:^{
                                        [((UIImageView*)[self withView:cell tag:10]) setImage:image];
                                    } completion:NULL];
                }
            }];
        }
        
        ((UILabel*)[self withView:cell tag:11]).text = ![list responseForKey:@"title"] ? @"No Title" : list[@"title"];
        
        ((UILabel*)[self withView:cell tag:12]).text = [[list[@"created_at"] ? list[@"created_at"] : @"" dateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"] dateTimeAgo].length == 0 ? [[list[@"created_at"] ? list[@"created_at"] : @"" dateWithFormat:@"yyyy/MM/dd HH:mm:ss Z"] dateTimeAgo] : [[list[@"created_at"] ? list[@"created_at"] : @"" dateWithFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"] dateTimeAgo];
        
        if([dict isKindOfClass:[MPMediaItem class]] || [dict isKindOfClass:[DownLoad class]])
        {
            ((UILabel*)[self withView:cell tag:12]).text = ![list responseForKey:@"ipod"] ? [self sizeOfFile:[NSString stringWithFormat:@"%@.mp3",[self filePath:((DownLoad*)dict).downloadData[@"name"]]]] : [self sizeOfAsset:list[@"assetUrl"]];
        }
        
        ((UILabel*)[self withView:cell tag:14]).text = ![list responseForKey:@"description"] ? @"No Description" : [list getValueFromKey:@"description"];
        
        ((UILabel*)[self withView:cell tag:15]).text = [list responseForKey:@"ipod"] ? @"💾" : [NSString stringWithFormat:@"❤️ %@",list[@"likes_count"] ? [[list getValueFromKey:@"likes_count"] numbeRize] : @"0"];
        
        ((UILabel*)[self withView:cell tag:16]).text = [list responseForKey:@"ipod"] ? @"" : [NSString stringWithFormat:@"💿 %@",list[@"playback_count"] ? [[list getValueFromKey:@"playback_count"] numbeRize] : @"0"];
        
        ((UILabel*)[self withView:cell tag:17]).text = ![list responseForKey:@"ipod"] ? [self duration: [list[@"duration"] ? list[@"duration"] : @"0" intValue] / 1000] : [self duration:[list[@"duration"] intValue]]; ;
        
        ((UIImageView*)[self withView:cell tag:998811]).hidden = indexPath.row != [infoDict[@"active"] intValue] || ([infoDict[@"active"] intValue] < 0);
        
//        ((ListCell*)cell).isActive = ([infoDict responseForKey:@"off"] && [infoDict[@"off"] intValue] == 1);
//        
//        [((ListCell*)cell) reActive];
        
//        ((UIImageView*)[self withView:cell tag:998811]).image = ([infoDict responseForKey:@"off"] && [infoDict[@"off"] intValue] == 1) ? [UIImage imageNamed:@"genres"] : /* [[UIImage imageNamed:@"genres"] tintedImage:kColor]; */[self animate:@[@"w1", @"w2", @"w3"] andDuration:1];

    }
    else
    {
        List * list = (List*)dataList[indexPath.row];
        
        ((UILabel*)[self withView:cell tag:11]).text = list.name;
        
        ((UILabel*)[self withView:cell tag:12]).text = list.date;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        ((UILabel*)[self withView:cell tag:15]).text = [NSString stringWithFormat:@"%i",[Item getFormat:@"name=%@" argument:@[list.name]].count];
    }
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    UIImage *musicOne = [UIImage imageNamed:@"w1.png"];
////    UIImage *musicTwo = [UIImage imageNamed:@"w2.png"];
////    UIImage *musicThree = [UIImage imageNamed:@"w3.png"];
////    NSArray *imagesArray = @[musicOne, musicTwo, musicThree];
//////
////    [cell.imageView setAnimationImages:imagesArray];
////    cell.imageView.animationDuration = 1.0f;
////    [cell.imageView startAnimating];
//    
//    ((UIImageView*)[self withView:cell tag:998811]).image = ([infoDict responseForKey:@"off"] && [infoDict[@"off"] intValue] == 1) ? [UIImage imageNamed:@"genres"] : /* [[UIImage imageNamed:@"genres"] tintedImage:kColor]; */[self animate:@[@"w1", @"w2", @"w3"] andDuration:1];
//}
//
//-(void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
////    [cell.imageView stopAnimating];
////    [cell.layer removeAllAnimations];
//}

- (NSString*)filePath:(NSString*)name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (![fileManager fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"]])
    {
        [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:name];
    
    if (![fileManager fileExistsAtPath:subPath])
    {
        [fileManager createDirectoryAtPath:subPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * finalPath = [subPath stringByAppendingPathComponent:name];
    
    return finalPath;
}

- (NSString*)sizeOfAsset:(NSString*)filePath
{
    NSURL *urlAsset = [NSURL URLWithString:filePath];
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:urlAsset options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset: songAsset presetName: AVAssetExportPresetAppleM4A];
    CMTime half = CMTimeMultiplyByFloat64(exportSession.asset.duration, 1); exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, half);
    long long size = exportSession.estimatedOutputFileLength;
    return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}

- (NSString *)sizeOfFile:(NSString *)filePath
{
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    NSInteger fileSize = [[fileAttributes objectForKey:NSFileSize] integerValue];
    
    NSString *fileSizeStr = [NSByteCountFormatter stringFromByteCount:fileSize countStyle:NSByteCountFormatterCountStyleFile];
    
    return fileSizeStr;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([infoDict[@"ident"] isEqualToString:@"region"])
    {
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        self.completion(0, self, @{@"data":regions[[regions.allKeys order][indexPath.row]]});
    }
    else if([infoDict[@"ident"] isEqualToString:@"filter"])
    {
        int section = indexPath.section;
        
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        NSString * key = [regions.allKeys order][indexPath.section];
        
        NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
        
        NSMutableArray * temp = [self filter];
        
        temp[section] = regions[key][subKey];
        
        [self addValue:temp andKey:@"filterOpt"];
        
        [_tableView reloadDataWithAnimation:YES];
    }
    else if([infoDict[@"ident"] isEqualToString:@"download"])
    {
        if(indexPath.section == 0)
        {
            self.completion(69, self, @{@"data":@(indexPath.row)});
        }
        else
        {
            if([List getAll].count == 0)
            {
                return;
            }
            
            self.completion(96, self, @{@"data":((List*)[List getAll][indexPath.row]).name});
        }
    }
    else if([infoDict[@"ident"] isEqualToString:@"genre"])
    {
        int section = indexPath.section;
        
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        NSString * key = [regions.allKeys order][indexPath.section];
        
        NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
        
        NSMutableArray * temp = [self genre];

        if(section == 1 || section == 2)
        {
            temp[1] = regions[key][subKey];

            temp[2] = regions[key][subKey];
        }
        else
        {
            temp[section] = regions[key][subKey];
        }

        [self addValue:temp andKey:@"genreOpt"];
    }
    else if([infoDict[@"ident"] isEqualToString:@"search"])
    {
        NSDictionary * regions = (NSDictionary*)infoDict[@"data"];
        
        NSString * key = [regions.allKeys order][indexPath.section];
        
        NSString * subKey = [((NSDictionary*)regions[key]).allKeys order][indexPath.row];
        
        NSMutableArray * temp = [self search];

        temp[0] = regions[key][subKey];
        
        temp[1] = regions[key][subKey];
        
        temp[2] = regions[key][subKey];
        
        temp[3] = @(indexPath.row);
        
        temp[4] = @(indexPath.section);
        
        [self addValue:temp andKey:@"searchOpt"];
    }
    else if([infoDict[@"ident"] isEqualToString:@"itemcell"])
    {
        id dict = dataList[indexPath.row];
        
        NSDictionary * list = [dict isKindOfClass:[MPMediaItem class]] ? [self ipodItem:(MPMediaItem*)dict] : [dict isKindOfClass:[Item class]] ? [NSKeyedUnarchiver unarchiveObjectWithData:((Item*)dict).data] : [dict isKindOfClass:[DownLoad class]] ?  ((DownLoad*)dict).downloadData[@"infor"] : [dict isKindOfClass:[History class]] ?
        [NSKeyedUnarchiver unarchiveObjectWithData:((History*)dict).data] :
        [dict responseForKey:@"track"] ? dict[@"track"] : dict;
        
        self.completion(0, self, @{@"data":list,@"name":[dict isKindOfClass:[DownLoad class]] ? ((DownLoad*)dict).downloadData[@"name"] : @""});
    }
    else
    {
        self.completion(0, self, @{@"data":((List*)dataList[indexPath.row]).name});
    }
    
    [_tableView reloadDataWithAnimation:YES];
}



@end
