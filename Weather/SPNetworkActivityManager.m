//
//  SPNetworkActivityManager.m
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import "SPNetworkActivityManager.h"

@interface SPNetworkActivityManager()
@property (atomic) NSInteger currentDownloadCount;
@end

@implementation SPNetworkActivityManager

//----------------------------------------------------------------------------------------
+ (id)shared
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        @autoreleasepool {
            _sharedObject = [self new]; // or some other init method
        }
    });
    return _sharedObject;
}

//----------------------------------------------------------------------------------------
- (void)addDownloadInProgress
{
    @synchronized([SPNetworkActivityManager class])
    {
        NSAssert(self.currentDownloadCount>=0, @"SPNetworkActivityManager invalid download count");
        if (self.currentDownloadCount == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:TRUE];
            });
        }

        self.currentDownloadCount++;
    }
}

//----------------------------------------------------------------------------------------
- (void)downloadFinished
{
    @synchronized([SPNetworkActivityManager class])
    {
        self.currentDownloadCount--;
        NSAssert(self.currentDownloadCount>=0, @"SPNetworkActivityManager invalid download count");
        
        if (self.currentDownloadCount == 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
             [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            });
        }
    }
}

-(void)reboot
{
    @synchronized([SPNetworkActivityManager class])
    {
        self.currentDownloadCount=0;
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    }
}

@end
