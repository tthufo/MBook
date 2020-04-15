//
//  DownLoad.m
//  Trending
//
//  Created by thanhhaitran on 8/22/16.
//  Copyright © 2016 thanhhaitran. All rights reserved.
//

#import "DownLoad.h"

static DownLoad * instance = nil;

@implementation DownLoad

@synthesize percentComplete, operationIsOK, appendIfExist, possibleFilename, completion, operationFinished, operationBreaked, dataInfo;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        
    }
    return self;
}

- (NSDictionary*)downloadData
{
    return [@{@"url":downloadUrl,
             @"byte":@(bytesReceived),
             @"local":localFilename,
             @"expect":@(expectedBytes),
             @"percent":@(percentComplete),
             @"finish":@(operationFinished),
             @"break":@(operationBreaked),
             @"name":dataInfo[@"name"],
             @"cover":dataInfo[@"cover"],
             @"infor":dataInfo[@"infor"],
             @"active":@"0"
              } mutableCopy];
}

- (void)forceStop
{
    operationBreaked = YES;

//    [Records addValue:[self downloadData] andvId:[dataInfo[@"infor"] getValueFromKey:@"id"] andKey:dataInfo[@"name"]];
}

- (void)forceContinue
{
    operationBreaked = NO;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: downloadUrl];
    
//    NSData * data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithFormat:@"%@.mp3", [self filePath]]];
    
//    [request addValue: [NSString stringWithFormat: @"bytes=%.0lu-", (unsigned long)data.length] forHTTPHeaderField: @"Range"];

    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:[NSString stringWithFormat:@"%@.mp3", [self filePath]]];
    
    if((unsigned long)[fileHandle seekToEndOfFile] != 0)
    {
        [request addValue: [NSString stringWithFormat: @"bytes=%.0lu-", (unsigned long)[fileHandle seekToEndOfFile]] forHTTPHeaderField: @"Range"];
    }
    
    
    NSURLConnection * requestConnection = [NSURLConnection connectionWithRequest:request
                                                       delegate: self];
    [requestConnection start];
}

- (DownLoad*)forceResume:(NSDictionary*)dataLeft andCompletion:(DownloadCompletion)_completion
{
    self.completion = _completion;
    
    operationBreaked = YES;
    
    dataInfo = dataLeft;
    
    downloadUrl = dataLeft[@"url"];
    
    bytesReceived = [dataLeft[@"byte"] floatValue];

    percentComplete = [dataLeft[@"percent"] floatValue];
    
    localFilename = dataLeft[@"local"];
    
    expectedBytes = [dataLeft[@"expect"] longLongValue];
    
    operationFinished = [dataLeft[@"finish"] boolValue];

    self.progress = ((bytesReceived/(float)expectedBytes)*100)/100;

    self.backgroundColor = [UIColor clearColor];
    
    return self;
}

- (DownLoad*)didProgress:(NSDictionary*)info andCompletion:(DownloadCompletion)_completion
{
    dataInfo = info;
    
    self.completion = _completion;
    
    downloadUrl = [info[@"url"] isKindOfClass:[NSURL class]] ? info[@"url"] : [NSURL URLWithString:info[@"url"]];
    
    bytesReceived = percentComplete = 0;
    
    localFilename = [[[downloadUrl absoluteString] lastPathComponent] copy];
    
    operationFinished = NO;
    
    self.progress = 0.0;
    
    self.backgroundColor = [UIColor clearColor];
    
    NSURLRequest * requestDownload = [[NSURLRequest alloc] initWithURL:downloadUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:15];
    
    NSURLConnection * requestConnection = [[NSURLConnection alloc] initWithRequest:requestDownload delegate:self startImmediately:YES];
    
    if(requestConnection == nil)
    {
        self.completion(-1, self, @{@"error":[NSError errorWithDomain:@"UIDownloadBar Error" code:1 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"NSURLConnection Failed", NSLocalizedDescriptionKey, nil]]});
    }
    
    [requestConnection start];
    
//    [Records addValue:[self downloadData] andvId:[dataInfo[@"infor"] getValueFromKey:@"id"] andKey:dataInfo[@"name"]];
    
    [[NSFileManager defaultManager] createFileAtPath:[NSString stringWithFormat:@"%@.pdf", [self filePath]] contents:nil attributes:nil];
    
    return self;
}

- (void)completion:(DownloadCompletion)_completion
{
    self.completion = _completion;
}

- (void)writing:(NSData*)data
{
    NSFileHandle *hFile = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@.pdf", [self filePath]]];
    
    @try
    {
        [hFile seekToEndOfFile];
        
        [hFile writeData:data];
    }
    @catch (NSException * e)
    {
        NSLog(@"exception when writing to file %@", [NSString stringWithFormat:@"%@.pdf", [self filePath]]);
    }
    
    [hFile closeFile];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (!operationBreaked)
    {
        [self writing:data];
        
        float receivedLen = [data length];
        
        bytesReceived = (bytesReceived + receivedLen);
        
        if(expectedBytes != NSURLResponseUnknownLength)
        {
            self.progress = ((bytesReceived/(float)expectedBytes)*100)/100;
                        
            percentComplete = self.progress*100;
        }
        
        self.completion(99, self, @{@"percentage":@(((bytesReceived/(float)expectedBytes)*100))});
    }
    else
    {
        [connection cancel];
        
        self.completion(1, self, @{});
        
//        NSLog(@" Pause ");
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self forceStop];
    
    self.completion(-1, self, @{@"error":error});
        
    operationFailed = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
//    NSLog(@"[DO::didReceiveData] %d operation", (int)self);
//    NSLog(@"[DO::didReceiveData] ddb: %.2f, wdb: %.2f, ratio: %.2f",
//          (float)bytesReceived,
//          (float)expectedBytes,
//          (float)bytesReceived / (float)expectedBytes);
    
    NSHTTPURLResponse *r = (NSHTTPURLResponse*) response;
    NSDictionary *headers = [r allHeaderFields];
//    NSLog(@"[DO::didReceiveResponse] response headers: %@", headers);
    if (headers){
        if ([headers objectForKey: @"Content-Range"]) {
            NSString *contentRange = [headers objectForKey: @"Content-Range"];
            if(contentRange.length != 0)
            {
                NSRange range = [contentRange rangeOfString: @"/"];
                NSString *totalBytesCount = [contentRange substringFromIndex: range.location + 1];
                expectedBytes = [totalBytesCount floatValue];
            }
            else
            {
                expectedBytes = 0;
            }
        } else if ([headers objectForKey: @"Content-Length"]) {
            NSLog(@"Content-Length: %@", [headers objectForKey: @"Content-Length"]);
            expectedBytes = [[headers objectForKey: @"Content-Length"] floatValue];
        } else expectedBytes = -1;
        
        if ([@"Identity" isEqualToString: [headers objectForKey: @"Transfer-Encoding"]]) {
            expectedBytes = bytesReceived;
            operationFinished = YES;
        }
    }		
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if((int)ceil(self.percentComplete) != 100)
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@.pdf", [self filePath]] error:NULL];
        
        self.completion(0, self, @{@"reload":@(1)});
    }
    else
    {
        operationFinished = YES;
        
        [self didFinishWithData:dataInfo[@"name"]];
        
        self.completion(0, self, @{@"done":@(1)});
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
       {
//           [Records addValue:[self downloadData] andvId:[dataInfo[@"infor"] getValueFromKey:@"id"] andKey:dataInfo[@"name"]];
           
           dispatch_async(dispatch_get_main_queue(), ^(void)
          {
              
          });
           
       });
        
        if (![UIApplication sharedApplication].isStatusBarHidden)
        {
//            [CRToastManager dismissAllNotifications:YES];
//
//            NSDictionary *options = @{
//                                      kCRToastTextKey : [NSString stringWithFormat:@"Completed: %@", dataInfo[@"infor"][@"title"]],
//                                      kCRToastTextAlignmentKey : @(NSTextAlignmentCenter),
//                                      kCRToastBackgroundColorKey : [AVHexColor colorWithHexString:@"#00A3E2"],
//                                      kCRToastAnimationInTypeKey : @(CRToastAnimationTypeGravity),
//                                      kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeGravity),
//                                      kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
//                                      kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
//                                      };
//            [CRToastManager showNotificationWithOptions:options
//                                        completionBlock:^{
//
//    //                                        [[APPDELEGATE.window.rootViewController PLAYER] didReloadSyncedData];
//
//                                        }];
        }
        else
        {
//            [self showToast:[NSString stringWithFormat:@"Completed: %@", dataInfo[@"infor"][@"title"]] andPos:0];
        }
    }
}

- (NSString*)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    if (![fileManager fileExistsAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"]])
    {
        [fileManager createDirectoryAtPath:[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * subPath = [[[paths objectAtIndex:0] stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:dataInfo[@"name"]];
    
    if (![fileManager fileExistsAtPath:subPath])
    {
        [fileManager createDirectoryAtPath:subPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString * finalPath = [subPath stringByAppendingPathComponent:dataInfo[@"name"]];
    
    return finalPath;
}

- (void)didFinishWithData:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //[fileManager createFileAtPath:[NSString stringWithFormat:@"%@.mp3", [self filePath]] contents:fileData attributes:nil];
    
    
    if([dataInfo responseForKey:@"infor"])
    {        
        NSMutableDictionary * plist = [[NSMutableDictionary alloc] initWithDictionary:dataInfo[@"infor"]];
        
        [plist removeObjectForKey:@"img"];
        
        [plist writeToFile:[NSString stringWithFormat:@"%@.plist", [self filePath]] atomically:YES];
    }

    
//    NSString *imagePath = [NSString stringWithFormat:@"%@.png", [self filePath]];
//
//    AVAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@.mp3", [self filePath]]] options:nil];
//
//    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//
//    Float64 durationSeconds = CMTimeGetSeconds(asset.duration);
//
//    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds / 2.0, 600);
//
//    CMTime actualTime;
//
//    CGImageRef preImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:NULL];
//
//    if (preImage != NULL)
//    {
//        CGRect rect =  CGRectMake(0.0, 0.0,[dataInfo responseForKey:@"cover"] ? ((UIImage*)dataInfo[@"cover"]).size.width : CGImageGetWidth(preImage) * 0.5, [dataInfo responseForKey:@"cover"] ? ((UIImage*)dataInfo[@"cover"]).size.height : CGImageGetHeight(preImage) * 0.5);
//
//        UIImage *image = [dataInfo responseForKey:@"cover"] ? dataInfo[@"cover"] : [UIImage imageWithCGImage:preImage];
//
//        UIGraphicsBeginImageContext(rect.size);
//
//        [image drawInRect:rect];
//
//        NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
//
//        [fileManager createFileAtPath:imagePath contents:data attributes:nil];
//
//        UIGraphicsEndImageContext();
//    }
//    else
//    {
//        if(dataInfo[@"cover"])
//        {
//            CGRect rect =  CGRectMake(0.0, 0.0,((UIImage*)dataInfo[@"cover"]).size.width ,((UIImage*)dataInfo[@"cover"]).size.height);
//
//            UIImage *image = dataInfo[@"cover"];
//
//            UIGraphicsBeginImageContext(rect.size);
//
//            [image drawInRect:rect];
//
//            NSData *data = UIImagePNGRepresentation(UIGraphicsGetImageFromCurrentImageContext());
//
//            [fileManager createFileAtPath:imagePath contents:data attributes:nil];
//
//            UIGraphicsEndImageContext();
//        }
//    }
    
//    NSLog(@"%@",imagePath);
    
    NSLog(@"--->%@",[self filePath]);
    
//    CGImageRelease(preImage);
}

+ (DownLoad*)shareInstance
{
    {
        instance = [DownLoad new];
    }
    return instance;
}


@end
