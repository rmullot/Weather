//
//  RecipesSQLManager.h
//  Weather
//
//  Created by Romain MULLOT on 13/07/2014.
//  Copyright (c) 2014 Romain MULLOT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseManager : NSObject {
	// Variables de la Base de Données
	NSString *databaseName;
	NSString *databasePath;
}
+(DatabaseManager*)sharedInstance;
-(BOOL)checkForecast;
-(void)updateForecast;
-(void)insertForecast;
-(NSMutableArray*)selectForecast;
@end
