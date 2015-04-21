//
//  IRDBManager.h
//  IRAutomation
//
//  Created by bharat jain on 3/9/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface IRDBManager : NSObject
{
    NSString *databasePath;
    
}

+(IRDBManager *)getSharedInstance;
-(BOOL)createDB;


- (BOOL)saveDefaults:(NSString *)column1 column2:(id)column2 column3:(id)column3 column4:(id)column4;;

- (BOOL)update:(NSString *)column value:(id)value;

- (NSArray *) fetchdataFromDB;


- (NSString *)fetchparti:state columnid:(NSInteger)columnid;

@end
