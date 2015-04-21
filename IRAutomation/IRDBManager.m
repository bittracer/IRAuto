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
                    [docsDir stringByAppendingPathComponent: @"ac.sqlite"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt = "create table if not exists acremote (acstate text NOT NULL ,mode text,timer text NOT NULL ,turbo text NOT NULL ,night text NOT NULL, slider float)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
    
            }
            sqlite3_close(database);
            sqlite3_finalize(statement);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}



-(BOOL)recordExistOrNot:(NSString *)query{
    BOOL recordExist=NO;
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil)==SQLITE_OK)
        {
            if (sqlite3_step(statement)==SQLITE_ROW)
            {
                recordExist=YES;
            }
            else
            {
                NSLog(@"%s,",sqlite3_errmsg(database));
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
        }
    }
    return recordExist;
}


- (BOOL)saveDefaults:(NSString *)column1 column2:(NSString *)column2 column3:(NSString *)column3 column4:(NSString *)column4
{
    
    NSString *query  = [NSString stringWithFormat:@"select acstate from acremote where rowid=1"];
    
    NSLog(@"query : %@",query);
    BOOL recordExist = [self recordExistOrNot:query];
    
    if (!recordExist) {
        // Insert your data
        BOOL success=NO;
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
            
        {
            
            NSString *insertSQL = [NSString stringWithFormat:@"insert into acremote (acstate,turbo,timer,night) values (\"%@\",\"%@\",\"%@\",\"%@\")",
                                   column1,column2,column3,column4];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                success=YES;
                
            }
            else {
                NSLog(@"prepare failed: %s", sqlite3_errmsg(database));
                NSLog(@"Error filling table: %d",SQLITE_ERROR);
                return NO;
            }
            
            ;}
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return success;
    }
    return NO;
}


- (BOOL)update:(NSString *)column value:(id)value
{
           const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        {
            NSString *sqlStr = [NSString stringWithFormat:@"UPDATE acremote  SET \"%@\" = (\"%@\") WHERE rowid=1",column,value];
            const char *insert_stmt = [sqlStr UTF8String];
            sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
            if (sqlite3_step(statement) == SQLITE_DONE)
            {
                return YES;
            }
            else {
                NSLog(@"prepare failed: %s", sqlite3_errmsg(database));
                NSLog(@"Error filling table: %d",SQLITE_ERROR);
                return NO;
            }
            
        }
        sqlite3_close(database);
        sqlite3_reset(statement);
        sqlite3_finalize(statement);

    return NO;
}



- (NSMutableArray *) fetchdataFromDB
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select *from acremote"];
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
                        
                        value=[NSNull null];
                        
                    }
                    else {
                        
                        NSLog(@"[SQLITE] UNKNOWN DATATYPE");
                        
                    }
                    
                    [resultArray addObject:value];
                    
                }
                
                
            }
            else{
                NSLog(@"Not found");
                }
    }
        sqlite3_reset(statement);
        sqlite3_finalize(statement);
        sqlite3_close(database);
        return resultArray;
      
    }
   
    return nil;
}

- (NSString *)fetchparti:state columnid:(NSInteger)columnid
{
    NSString *name=[[NSString alloc]init];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select \"%@\" from acremote where rowid=1",state];
        const char *query_stmt = [querySQL UTF8String];
   
        if (sqlite3_prepare_v2(database,
                               query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                name = [NSString stringWithFormat:@"%s",
                                   sqlite3_column_text(statement, (int)columnid)];
                //str=[NSString stringWithFormat:@"%s",sqlite3_column_text(statement, (int)columnid)];

            }
        }
        sqlite3_reset(statement);
        sqlite3_close(database);
        sqlite3_finalize(statement);
        return name;

    }
    return nil;
}
@end
