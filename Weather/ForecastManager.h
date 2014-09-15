//
//  ForecastManager.h
//  Weather
//
//  Created by test on 13/07/14.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Forecast.h"

@interface ForecastManager : NSObject
{
    
}
@property(nonatomic,strong)Forecast *currentForecast;

+(ForecastManager*)sharedInstance;
-(void)updateForecastWithDictionary:(NSDictionary*)dict;
@end
