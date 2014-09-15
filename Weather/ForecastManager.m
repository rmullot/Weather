//
//  ForecastManager.m
//  Weather
//
//  Created by test on 13/07/14.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import "ForecastManager.h"
#import "DatabaseManager.h"

@implementation ForecastManager
@synthesize currentForecast;

+(ForecastManager*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static ForecastManager* _sharedObject = nil;
    dispatch_once(&pred, ^{
        @autoreleasepool {
            _sharedObject = [[self alloc] init]; // or some other init method
        }
    });
    return _sharedObject;
}

-(id)init
{
    if (self=[super init])
    {
        self.currentForecast=[Forecast new];
        if ([[DatabaseManager sharedInstance] checkForecast])
        {
            NSMutableArray *data=[[DatabaseManager sharedInstance]selectForecast];
            if (data.count>0) {
                self.currentForecast.idImageWeather=[data objectAtIndex:0];
                self.currentForecast.clouds=[[data objectAtIndex:1] floatValue];
                self.currentForecast.humidity=[[data objectAtIndex:2] floatValue];
                self.currentForecast.pressure=[[data objectAtIndex:3] floatValue];
                self.currentForecast.temperature=[[data objectAtIndex:4] floatValue];
                self.currentForecast.wind=[[data objectAtIndex:5] floatValue];
                self.currentForecast.city.name=[data objectAtIndex:6];
            }
            
        }
    }
    return self;
}

-(void)updateForecastWithDictionary:(NSDictionary*)dict
{
    self.currentForecast.city.longitude=[[[dict objectForKey:@"coord"] objectForKey:@"lon"] floatValue];
    self.currentForecast.city.latitude=[[[dict objectForKey:@"coord"] objectForKey:@"lat"] floatValue];
    self.currentForecast.city.name=[dict objectForKey:@"name"];
    self.currentForecast.city.country=[[dict objectForKey:@"sys"] objectForKey:@"country"];
    
    self.currentForecast.idImageWeather=[[[dict objectForKey:@"weather"] objectAtIndex:0] objectForKey:@"icon"];
    
    self.currentForecast.clouds=[[[dict objectForKey:@"clouds"] objectForKey:@"all"] floatValue];
    self.currentForecast.humidity=[[[dict objectForKey:@"main"] objectForKey:@"humidity"] floatValue];
    self.currentForecast.pressure=[[[dict objectForKey:@"main"] objectForKey:@"pressure"] floatValue];
    self.currentForecast.temperature=[[[dict objectForKey:@"main"] objectForKey:@"temp"] floatValue];
    self.currentForecast.wind=[[[dict objectForKey:@"wind"] objectForKey:@"speed"] floatValue];
    
    if ([[DatabaseManager sharedInstance] checkForecast])
    {
        [[DatabaseManager sharedInstance]updateForecast];
    }
    else
    {
        [[DatabaseManager sharedInstance]insertForecast];
    }

}
@end
