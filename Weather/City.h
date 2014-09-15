//
//  City.h
//  Weather
//
//  Created by test on 13/07/14.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface City : NSObject
{
    
}
@property(nonatomic)CGFloat longitude;
@property(nonatomic)CGFloat latitude;
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *country;
@end
