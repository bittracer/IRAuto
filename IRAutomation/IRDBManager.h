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

-(BOOL) save:(NSString *)column value:(id)value;


- (NSArray *) fetchdataFromDB;


- (NSString *)fetchparti:acstate columnid:(NSInteger)columnid;

@end
