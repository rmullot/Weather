//
//  SPNetworkActivityManager.h
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import <Foundation/Foundation.h>

// Allow to gather information on Network Activity
// Each client will increment and decrement a counter.
// iphone NetworkActivty will be update only when counter reach 0
// This will avoid blinking
@interface SPNetworkActivityManager : NSObject

+ (id)shared;

- (void)addDownloadInProgress;
- (void)downloadFinished;
-(void)reboot;

@end