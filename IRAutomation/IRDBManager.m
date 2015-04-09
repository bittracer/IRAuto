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
            const char *sql_stmt = "create table if not exists acremote (acstate text DEFAULT 'Acoff' priamry key,mode text,timer text DEFAULT 'timeroff',turbo text DEFAULT 'turbooff',night text DEFAULT 'nightoff, slider float)";
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

- (BOOL)save:(NSString *)column value:(id)value
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into acremote (\"%@\") values (\"%@\")",
                               column,value];
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


- (NSArray *) fetchdataFromDB
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select * from acremote"];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                
                
                for (int i=0; i<sqlite3_column_count(statement); i++)
                    
                {
                    
                    //Check the column type of retured data.
                    
                    int colType = sqlite3_column_type(statement, i);
                    
                    id  value;
                    
                    if (colType == SQLITE_TEXT) {
                        
                        const unsigned char *col = sqlite3_column_text(statement, i);
                        
                        value = [NSString stringWithFormat:@"%s", col];
                        
                    } else if (colType == SQLITE_INTEGER) {
                        
                        int col = sqlite3_column_int(statement, i);
                        
                        value = [NSNumber numberWithInt:col];
                        
                    } else if (colType == SQLITE_FLOAT) {
                        
                        double col = sqlite3_column_double(statement, i);
                        
                        value = [NSNumber numberWithDouble:col];
                        
                    }
                    else if (colType == SQLITE_NULL) {
                        
                        value = [NSNull null];
                        
                    }
                    else {
                        
                        NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                        
                    }
                    
                    [resultArray addObject:value];
                    
                }
                
                [resultArray addObject:resultArray];
            }
            else{
                NSLog(@"Not found");
                }
        
    }
      
    }
    return nil;
}

- (NSString *)fetchparti:acstate columnid:(NSInteger)columnid
{
    NSString *str;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select \'%@' from acremote",acstate];
        const char *query_stmt = [querySQL UTF8String];
   
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                str=[NSString stringWithFormat:@"%s",sqlite3_column_text(statement, (int)columnid)];
                return  str;
            }
        }
        return  str;
        
    }
    return str;
}
@end
