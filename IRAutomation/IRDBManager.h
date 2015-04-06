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
-(BOOL) saveData:(NSString*)fname lname:(NSString*)lname
          mobile:(NSString*)mobile email:(NSString*)email pass:(NSString *)pass confpass:(NSString *)confpass;
-(BOOL) findByEmail:(NSString*)email pass:(NSString *)pass;

@end
