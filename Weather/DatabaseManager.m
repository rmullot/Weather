//
//  DatabaseManager.m
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import "DatabaseManager.h"
#import "Forecast.h"
#import "ForecastManager.h"

@interface DatabaseManager ()
{
    sqlite3 *_database;
}

@end

@implementation DatabaseManager


+ (DatabaseManager*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static DatabaseManager* _sharedObject = nil;
    dispatch_once(&pred, ^{
        @autoreleasepool {
            _sharedObject = [[self alloc] init]; // or some other init method
        }
    });
    return _sharedObject;
}

-(id)init
{
    if(self=[super init])
    {
        databaseName =@"Weather.sqlite";
        
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDir = [documentPaths objectAtIndex:0];
        databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
        [self checkAndCreateDatabase];
    }
    return self;
}



-(void) checkAndCreateDatabase
{
	// We verify if the DB has been already saved in the user's iPhone
	BOOL success;
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:databasePath];
	if (success)
        return;
	
    //If the DB is not already deployed, we create a new file base on the sqlite file
	NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
	[fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:nil];
}

#pragma mark - Forecast SQL Requests
/*This method verify if we have at least one forecast saved in the cache*/
-(BOOL)checkForecast
{
    NSUInteger numRows=0;

	if(sqlite3_open([databasePath UTF8String], &_database) == SQLITE_OK)
    {
        //Request wich will be sent to the DB
        NSString *sqlStatementStr = [NSString stringWithFormat:@"SELECT count(*) from Forecast"];
		const char *sqlStatement = [sqlStatementStr cStringUsingEncoding:NSASCIIStringEncoding];
        
		//Variable to know the state of the DB
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(_database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            
            if (sqlite3_step(compiledStatement) == SQLITE_ERROR)
            {
                NSAssert1(0,@"Error when counting rows  %s",sqlite3_errmsg(_database));
            }
            else
            {
                numRows= sqlite3_column_int(compiledStatement, 0);
                NSLog(@"SQLite Rows: %lu", (unsigned long)numRows);
            }

		}
		sqlite3_finalize(compiledStatement);
	}
    sqlite3_close(_database);
    return numRows;
    

}

-(NSMutableArray*)selectForecast
{
    NSMutableArray *data=[NSMutableArray new];
    if(sqlite3_open([databasePath UTF8String], &_database) == SQLITE_OK)
    {
        //Request wich will be sent to the DB

        NSString *sqlStatementStr = [NSString stringWithFormat:@"SELECT Forecast.idImageWeather,Forecast.clouds,Forecast.humidity,Forecast.pressure,Forecast.temperature,Forecast.wind,City.name FROM Forecast JOIN City on  Forecast.idCity=City.id"];
		const char *sqlStatement = [sqlStatementStr cStringUsingEncoding:NSASCIIStringEncoding];
        
		//Variable to know the state of the DB
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(_database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            
            int statut=sqlite3_step(compiledStatement);
            if (statut == SQLITE_ERROR)
            {
                NSAssert1(0,@"Error when selecting row  %s",sqlite3_errmsg(_database));
            }
            else
            {
                if(statut == SQLITE_ROW)
                {
                    
                    [data addObject:[NSString  stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,0)]];
                    [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, 1)]];
                    [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, 2)]];
                    [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, 3)]];
                    [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, 4)]];
                    [data addObject:[NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, 5)]];
                    [data addObject:[NSString  stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement,6)]];

                }
                else
                {
                    NSAssert(0,@"Error when selecting row %s",sqlite3_errmsg(_database));
                }
            }
		}
		sqlite3_finalize(compiledStatement);
	}
    sqlite3_close(_database);
    return data;
}

-(void)updateForecast
{
    if(sqlite3_open([databasePath UTF8String], &_database) == SQLITE_OK)
    {
        //Request wich will be sent to the DB
        Forecast *forecast=[ForecastManager sharedInstance].currentForecast;
        
        NSString *sqlStatementStr = [NSString stringWithFormat:@"UPDATE Forecast SET idImageWeather='%@',clouds=%f,humidity=%f,pressure=%f,temperature=%f,wind=%f WHERE id=1",forecast.idImageWeather,forecast.clouds,forecast.humidity,forecast.pressure,forecast.temperature,forecast.wind];
        const char *sqlStatement = [sqlStatementStr cStringUsingEncoding : [NSString defaultCStringEncoding]];
		NSLog(@"sqlStat : %s", sqlStatement);
        
		//Variable to know the state of the DB
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(_database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            sqlite3_exec(_database, sqlStatement,NULL,NULL,NULL);
            if (sqlite3_step(compiledStatement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when updating rows  %s",sqlite3_errmsg(_database));
            }
		}
		sqlite3_finalize(compiledStatement);
	}
    sqlite3_close(_database);
}

-(void)insertForecast
{
    
	if(sqlite3_open([databasePath UTF8String], &_database) == SQLITE_OK)
    {
        Forecast *forecast=[ForecastManager sharedInstance].currentForecast;
        NSString *sqlStat = [[NSString alloc] initWithFormat:@"INSERT INTO City (id,longitude,latitude,name,country) VALUES (1,%f,%f,'%@','%@')",forecast.city.longitude,forecast.city.latitude,forecast.city.name,forecast.city.country];
		const char *sqlStatement = [sqlStat cStringUsingEncoding :[NSString defaultCStringEncoding]];
        NSLog(@"sqlStat : %s", sqlStatement);
		sqlite3_stmt *compiledStatement;
		
		if(sqlite3_prepare_v2(_database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            sqlite3_exec(_database, sqlStatement,NULL,NULL,NULL);
            if (sqlite3_step(compiledStatement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when updating rows  %s",sqlite3_errmsg(_database));
                
            }
		}
		sqlite3_finalize(compiledStatement);
        NSString *sqlStat2 = [[NSString alloc] initWithFormat:@"INSERT INTO Forecast (id,idCity,idImageWeather,clouds,humidity,pressure,temperature,wind) VALUES (1,1,'%@',%f,%f,%f,%f,%f)",forecast.idImageWeather,forecast.clouds,forecast.humidity,forecast.pressure,forecast.temperature,forecast.wind];
		const char *sqlStatement2 = [sqlStat2 cStringUsingEncoding :[NSString defaultCStringEncoding]];
        NSLog(@"sqlStat : %s", sqlStatement2);
        if(sqlite3_prepare_v2(_database, sqlStatement2, -1, &compiledStatement, NULL) == SQLITE_OK)
        {
            sqlite3_exec(_database, sqlStatement2,NULL,NULL,NULL);
            if (sqlite3_step(compiledStatement) == SQLITE_ERROR) {
                NSAssert1(0,@"Error when updating rows  %s",sqlite3_errmsg(_database));
                
            }
		}
        sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(_database);
}
@end
