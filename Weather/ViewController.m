//
//  ViewController.m
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//
#import "ViewController.h"
#import "ForecastManager.h"
#import "WebservicesManager.h"
@interface ViewController ()

@end

@implementation ViewController
@synthesize forecastImage,forecastLabel;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshForecast) name:@"EndParsingForecast" object:nil];
    
  
	// Do any additional setup after loading the view, typically from a nib.
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshForecast];
    [[WebservicesManager sharedInstance]parseType:kWebServiceTypeWeatherByCity withParameter:@"Dublin,ie"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


-(void)refreshForecast
{
    NSURL *urlImage=[NSURL URLWithString:[[WebservicesManager sharedInstance]getURLWebServiceOf:kWebServiceTypeWeatherIcon withParameter:[ForecastManager sharedInstance].currentForecast.idImageWeather]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlImage];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   self.forecastImage.image=image;
                               } else{
                                   NSLog(@"Error:%@",error.description);
                               }
                           }];
    
    self.forecastLabel.text=[[ForecastManager sharedInstance].currentForecast description];
}
@end
