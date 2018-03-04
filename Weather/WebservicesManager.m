//
//  WebservicesManager.m
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import "WebservicesManager.h"
#import "ForecastManager.h"
#import "AppDelegate.h"
#import "SPNetworkActivityManager.h"


//URIs of the different webservices
#define URI_IMAGE @"http://openweathermap.org/img/w/"
#define URI_WEATHER_FOR_CITY @"https://api.openweathermap.org/data/2.5/weather?q="
#define API_KEY @"470f269746d885cea200e3a68974ce34"


@interface WebservicesManager()
@property(nonatomic,retain)NSMutableDictionary *dictionaryWebserviceType;

-(void)checkNetworkActivityIndicatorVisible:(NSString*)key;
+(NSString*)stringForUrl:(NSString*)stringToEncode;
@end

@implementation WebservicesManager
@synthesize dictionaryWebserviceType=_dictionaryWebserviceType;

//----------------------------------------------------------------------------------------
+ (id)sharedInstance
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
-(id)init
{
    self = [super init];
    if (self != nil)
    {
        self.dictionaryWebserviceType=[NSMutableDictionary dictionary];
        _operationQueue=[NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount=1;
    }
    
    return self;
}

//----------------------------------------------------------------------------------------
-(void)parseJsonInUrl: (NSString *)url
{
    NSAssert(![NSThread isMainThread],@"WebserviceManager called: in the MainThread.");
    NSLog(@"Call webservice : %@", url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:20.0f];

    [[SPNetworkActivityManager shared] addDownloadInProgress];
    
    
    NSURLResponse* response = nil;
    NSError* error = nil;
    #define MAX_DOWNLOAD_ATTEMPT 1
    for (int i=0; i<MAX_DOWNLOAD_ATTEMPT; i++)
    {
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        if  ((error != nil) || [self processData:data forURL:url]==false)
        {
            if (i<MAX_DOWNLOAD_ATTEMPT-1)
                  NSLog(@"Error:try to have an answer of the server without success.Request sent again! (%@)", error);
            else
            {
                NSLog(@"try %d times to have an answer of the server without success (%@)",MAX_DOWNLOAD_ATTEMPT, error);
                [self postNotification:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
               
            }
        }
        else
            break;           
    }
    
    [self checkNetworkActivityIndicatorVisible:url];
}

//----------------------------------------------------------------------------------------
-(void)parseType:(NSUInteger)type withParameter:(NSString *)parameter
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *_urlTmp=[self getURLWebServiceOf:type withParameter:parameter];
        [self.dictionaryWebserviceType setObject:[NSNumber numberWithInteger:type] forKey:_urlTmp];
        [self parseJsonInUrl:_urlTmp];
    });
}


//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
- (BOOL)processData:(NSData*)data forURL:(NSString*) URLstring
{
    NSLog(@"end Call webservice : %@", URLstring);
    NSLog(@"Succeeded! Received %d bytes of data",(int)[data length]);
    
    NSDictionary *dict;
    NSError * error = nil;
    dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error) {
        // handle error
        NSLog(@"Error during parsing JSON data:%@",error.description);
    }

    NSLog(@"end parsing json file from url:%@",URLstring);


    if ([dict count]!=0)
    {
        id _idTmp=[self.dictionaryWebserviceType objectForKey:URLstring];
        if (_idTmp==nil)
        {
            NSLog(@"JsonManager:ERROR=>the dictionary has not an object for this key");
            return NO;
        }

        WebServiceType type=[_idTmp intValue];
        switch (type) {
            case kWebServiceTypeWeatherByCity:
                [[ForecastManager sharedInstance] updateForecastWithDictionary:dict];
                break;
            case kWebServiceTypeWeatherIcon:
                break;
            default:
                break;
        }
        [self postNotification:URLstring];
    }
    else
    {
        NSLog(@"data sent by the server is empty for:%@",URLstring);
        return NO;
    }
    return YES;
}

-(void)postNotification:(NSString*)_URLstring
{
    
    id _idTmp=[self.dictionaryWebserviceType objectForKey:_URLstring];
    if (_idTmp==nil) {
        NSLog(@"JsonManager:ERROR=>the dictionary has not an object for this key");
        return;
    }
    WebServiceType type=[_idTmp intValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
        case kWebServiceTypeWeatherByCity:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"EndParsingForecast" object:nil];
            break;
        default:
            NSLog(@"The URL string parameter in question, needn't to send a notification!");
            break;
        }
    });
}

-(void)checkNetworkActivityIndicatorVisible:(NSString*)key
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SPNetworkActivityManager shared] downloadFinished];
        
        [self.dictionaryWebserviceType removeObjectForKey:key];
        if (self.dictionaryWebserviceType.count==0)
        {
            if (![self isDownloading])
            {
                NSDictionary *dict=[[NSDictionary alloc]initWithObjectsAndKeys:key,@"key", nil];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"EndParsing" object:dict];
            }
        }

    });
}

-(BOOL)isDownloading
{
    return ([self.dictionaryWebserviceType count]!=0);
}

-(NSMutableString *)getURLWebServiceOf:(NSUInteger)type withParameter:(NSString*)parameter
{
    NSMutableString *lastCallOfAWebService;
    switch (type) {
        case kWebServiceTypeWeatherByCity:
            lastCallOfAWebService=[NSMutableString stringWithFormat:@"%@%@&APPID=%@",URI_WEATHER_FOR_CITY,parameter,API_KEY];
            break;
        case kWebServiceTypeWeatherIcon:
            lastCallOfAWebService=[NSMutableString stringWithFormat:@"%@%@.png",URI_IMAGE,parameter];
            break;
        default:
            break;
    }
    return lastCallOfAWebService;
}

//----------------------------------------------------------------------------------------
+(NSString*)stringForUrl:(NSString*)stringToEncode
{
    NSString * _encodedString = ( NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                       NULL,
                                                                                                       (CFStringRef)stringToEncode,
                                                                                                       NULL,
                                                                                                       (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                                       kCFStringEncodingUTF8 ));
    return _encodedString;
}
@end
