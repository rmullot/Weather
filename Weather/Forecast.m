//
//  Forecast.m
//  Weather
//
//  Created by test on 13/07/14.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import "Forecast.h"

@implementation Forecast
@synthesize city,idImageWeather,clouds,humidity,pressure,temperature,wind;

-(id)init
{
    if (self=[super init])
    {
        self.city=[City new];
    }
    return self;
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"City:%@\nPressure:%f\nHumidity:%f\nTemperature:%f\nWind:%f\n                               Clouds:%f",self.city.name,self.pressure,self.humidity,self.temperature,self.wind,self.clouds];
}
@end
