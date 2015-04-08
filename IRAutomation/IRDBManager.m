//
//  IRDBManager.m
//  IRAutomation
//
//  Created by bharat jain on 3/9/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRDBManager.h"

static IRDBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;


@implementation IRDBManager

+(IRDBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

-(BOOL)createDB{
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"acremote.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists RegistrationDetails (mode text , lbltemp text, timer int, night text , turbo text, acon text,acoff text priamry key,slider text,swingh text,singv text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

-(BOOL) saveData:(NSString*)fname lname:(NSString*)lname
          mobile:(NSString*)mobile email:(NSString*)email pass:(NSString *)pass confpass:(NSString *)confpass
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into RegistrationDetails (firstname ,lastname, mobile, email, pass,confpass)values (\"%@\",\"%@\",\"%ld\",\"%@\",\"%@\",\"%@\")",
                              fname, lname, (long)[mobile integerValue],email,pass,confpass];
                                const char *insert_stmt = [insertSQL UTF8String];
                                sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
                                if (sqlite3_step(statement) == SQLITE_DONE)
                                {
                                    return YES;
                                }
                                else {
                                    return NO;
                                }
     }
    return NO;
}
//
//-(BOOL) save:(NSString *)sender
//{
//    const char *dbpath = [databasePath UTF8String];
//    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
//    {
//        NSString *insertSQL = [NSString stringWithFormat:@"insert into acremote (firstname ,lastname, mobile, email, pass,confpass)values (\"%@\",\"%@\",\"%ld\",\"%@\",\"%@\",\"%@\")",
//                               fname, lname, (long)[mobile integerValue],email,pass,confpass];
//        const char *insert_stmt = [insertSQL UTF8String];
//        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
//        if (sqlite3_step(statement) == SQLITE_DONE)
//        {
//            return YES;
//        }
//        else {
//            return NO;
//        }
//    }
//    return NO;
//;
//}

-(BOOL) findByEmail:(NSString*)email pass:(NSString *)pass
            {
            const char *dbpath = [databasePath UTF8String];
            if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            {
        NSString *querySQL = [NSString stringWithFormat: @"select * from RegistrationDetails where email=\"%@\" AND pass=\"%@\"",email,pass];
                const char *query_stmt = [querySQL UTF8String];
              // NSMutableArray *resultArray = [[NSMutableArray alloc]init];
                if (sqlite3_prepare_v2(database,
                                       query_stmt, -1, &statement, NULL) == SQLITE_OK)
                {
                    if (sqlite3_step(statement) == SQLITE_ROW)
//                   {
//                        NSString *firstname = [[NSString alloc] initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 0)];
//                        [resultArray addObject:firstname];
//                        NSString *lastname = [[NSString alloc] initWithUTF8String:
//                                                (const char *) sqlite3_column_text(statement, 1)];
//                        [resultArray addObject:lastname];
//                        NSString *mobile = [[NSString alloc]initWithUTF8String:
//                                          (const char *) sqlite3_column_text(statement, 2)];
//                        [resultArray addObject:mobile];
//                       NSString *email = [[NSString alloc]initWithUTF8String:
//                                           (const char *) sqlite3_column_text(statement, 3)];
//                       [resultArray addObject:email];
//                       NSString *pass = [[NSString alloc]initWithUTF8String:
//                                           (const char *) sqlite3_column_text(statement, 4)];
//                       [resultArray addObject:pass];
//                       NSString *confpass = [[NSString alloc]initWithUTF8String:
//                                           (const char *) sqlite3_column_text(statement, 5)];
//                       [resultArray addObject:confpass];
//                        return resultArray;
                        return YES;
                    }
                    else{
                        NSLog(@"Not found");
                        return NO;
                    }
                 //   sqlite3_reset(statement);
                }
            return NO;
        }
@end
