//
//  JsonManager.h
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#ifndef JSON_MANAGER_H_
# define JSON_MANAGER_H_

#import <Foundation/Foundation.h>

typedef enum {
    kWebServiceTypeWeatherByCity = 0,
    kWebServiceTypeWeatherIcon = 1
}WebServiceType;


@interface WebservicesManager : NSObject<NSURLConnectionDelegate>
{
    @private
    NSOperationQueue *_operationQueue;
}

+(id)sharedInstance;
-(BOOL)isDownloading;
-(void)parseType:(NSUInteger)type withParameter:(NSString *)parameter;
-(NSMutableString *)getURLWebServiceOf:(NSUInteger)type withParameter:(NSString*)parameter;
@end

#endif