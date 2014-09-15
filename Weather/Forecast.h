//
//  Forecast.h
//  Weather
//
//  Created by test on 13/07/14.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "City.h"

@interface Forecast : NSObject
{
    
}
@property(nonatomic,strong)City *city;
@property(nonatomic)NSString *idImageWeather;
@property(nonatomic)CGFloat clouds;
@property(nonatomic)CGFloat humidity;
@property(nonatomic)CGFloat pressure;
@property(nonatomic)CGFloat temperature;
@property(nonatomic)CGFloat wind;
@end
