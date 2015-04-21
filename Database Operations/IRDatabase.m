
#import "IRDatabase.h"
#import <sqlite3.h>
#import <sys/xattr.h>
#import "ACRemote.h"
#import <Foundation/NSRunLoop.h>

@interface IRDatabase(){
    sqlite3 *dbHandle;
    NSString *databasePath;
	BOOL opened;
}
-(id) initDatabase;
-(BOOL)openDatabase:(NSString *)databasePath;
-(BOOL)queryHasResult:(NSString *)query;
@end

@implementation IRDatabase

static IRDatabase *db;//, *delDB;
static NSString *_dbDestinationPath;
static NSString *_dbSourcePath;

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self closeDatabase];
}

-(id) initDatabase{
    
	if (self=[super init]) {
        databasePath = _dbDestinationPath;
        NSFileManager *fileManager=[NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:databasePath]){
            NSString *fileName = [databasePath lastPathComponent];
            NSString *dbFolderPath = [databasePath stringByReplacingOccurrencesOfString:fileName withString:@""];
            NSError *error;
            [fileManager createDirectoryAtPath:dbFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
            if(error)
                return nil;
            error = nil;
            if(![fileManager copyItemAtPath:_dbSourcePath toPath:databasePath error:&error])
                return nil;
        }
        
//        NSString *finalPathToAddSkipAttb=databasePath;
//        NSRange range=[finalPathToAddSkipAttb rangeOfString:@"tripBuilderv"];
//        if (range.length>0) {
//            finalPathToAddSkipAttb=[finalPathToAddSkipAttb substringToIndex:range.location];
//        }

        [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:databasePath]];
        
		if([self openDatabase:databasePath])
            return self;
	}
	return nil;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    BOOL success;
        assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
        
        NSError *error = nil;
        success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        }
    return success;
}

//- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
//{
//    const char* filePath = [[URL path] fileSystemRepresentation];
//    const char* attrName = "com.apple.MobileBackup";
//    
//    u_int8_t attrValue = 1;
//    
//    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
//    //    D_Log(@"addSkipBackupAttributeToItemAtURL SUCCESS?0:xyz : %d",result);
//    return result == 0;
//}

#pragma mark - Database Open-Close

-(BOOL) openDatabase:(NSString *)dbPath{
    if(opened) return YES;
    int err = sqlite3_open([dbPath fileSystemRepresentation], &dbHandle);
    if(err != SQLITE_OK) {
        NSLog(@"[TBDatabase] Error opening DB: %d", err);
        return NO;
    }
    opened = YES;
    return YES;
}

- (void)closeDatabase {
	if(!dbHandle) return;
	sqlite3_close(dbHandle);
	dbHandle = nil;
	opened = NO;
}

+(void)resetDatabase{
    if(db)
        db = nil;
//    _dbSourcePath = nil;
    _dbDestinationPath = nil;
}

+(void)setDatabaseDestinationPath:(NSString *)dbDestinationPath{
    _dbDestinationPath = dbDestinationPath;
}

+(NSString *)getDatabaseDestinationPath{
    return _dbDestinationPath;
}

+(void)setDatabaseSourcePath:(NSString *)dbSourcePath{
    _dbSourcePath = dbSourcePath;
}

+(NSString *)getDatabaseSourcePath{
    return _dbSourcePath;
}

+(void) checkDBVar{
    if (db==nil) {
		db=[[IRDatabase alloc] initDatabase];
	}
}

//Class method for executeSelectQuery for dictionary array.
+(NSArray *)executeSelectQuery:(NSString *)query
{
    [self checkDBVar];
    return [db executeSelectQuery:query];
}

-(NSArray *)executeSelectQuery:(NSString *)query
{
    NSMutableArray *resultArray = [NSMutableArray array];
    const char *sqlStatement = [query UTF8String];
    NSLog(@"executeSelectQuery SQL = %s",sqlStatement);
    sqlite3_stmt *compiledStatement;
    
    if(sqlite3_prepare_v2(dbHandle, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        //Get columns from the compiled statemt
        int columnCount = sqlite3_column_count(compiledStatement);
        NSMutableArray *columnNames = [NSMutableArray array];
        for(int i=0;i<columnCount;i++) {
            if(sqlite3_column_name(compiledStatement,i) != NULL) {
                [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(compiledStatement,i)]];
            } else {
                [columnNames addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }
        
        //Create dictionary for each row. Column as key and text as value.
        while(sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            NSMutableDictionary *object = [[NSMutableDictionary alloc] init];
            NSString *value=nil;
            NSString *key=nil;
            
            for(int i = 0; i<columnCount; i++){
                key=[columnNames objectAtIndex:i];
                switch (sqlite3_column_type(compiledStatement,i))
                {
                    case SQLITE_INTEGER:
                        value = [NSString stringWithFormat:@"%d",(int)sqlite3_column_int(compiledStatement, i)];
                        break;
                    case SQLITE_FLOAT:
                        value = [NSString stringWithFormat:@"%f",(float)sqlite3_column_double(compiledStatement, i)];
                        break;
                    case SQLITE_TEXT:
                        value = [NSString stringWithCString:(const char *)sqlite3_column_text(compiledStatement, i) encoding:NSUTF8StringEncoding];
                        if (value) {
//                            value = [value stringByDecodingHTMLEntities];
//                            value = [value stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];
//                            value = [value stringByReplacingOccurrencesOfString: @"<br />" withString: @"\n"];
//                            value = [value stringByReplacingOccurrencesOfString: @"<br/>" withString: @"\n"];
                        }
                        break;
                    case SQLITE_NULL:
                        value =@"";
                        break;
                    default:
                        value = [NSString stringWithCString:(const char *)sqlite3_column_text(compiledStatement, i) encoding:NSUTF8StringEncoding];
                        break;
                }
                [object setValue:value forKey:key];
            }
            [resultArray addObject:object];
        }
        sqlite3_finalize(compiledStatement);
    }
    NSLog(@"%d",SQLITE_ERROR);
    NSLog(@"prepare failed: %s", sqlite3_errmsg(dbHandle));
    __autoreleasing NSArray *finalArray = [resultArray copy];
    return finalArray;
}

//Class method for executeSelectQuery for model object
+(NSArray *)executeSelectQuery:(NSString *)query objectType:(Class)classType{
    [self checkDBVar];
    return [db executeSelectQuery:query objectType:classType whereConditionValues:nil];
}

//Class method for execute search select query. Added this method to avoid sql injection problem
+(NSArray *)executeSelectQuery:(NSString *)query objectType:(Class)classType whereConditionValues:(NSArray *)whereConditionValues{
    [self checkDBVar];
    return [db executeSelectQuery:query objectType:classType whereConditionValues:whereConditionValues];
}

-(NSArray *)executeSelectQuery:(NSString *)query objectType:(Class)classType whereConditionValues:(NSArray *)whereConditionValues{
    NSMutableArray *resultArray = [NSMutableArray array];
    const char *sqlStatement = [query UTF8String];
    
    NSLog(@"executeSelectQuery + classType SQL = %s",sqlStatement);
    sqlite3_stmt *compiledStatement;
    NSDictionary *propertyColumnPair = [classType columnPropertyPair];
    if(sqlite3_prepare_v2(dbHandle, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        
        //If we have search parameter values, then bind the values to statement.
        if(whereConditionValues.count){
            int index = 1;
            for(id value in whereConditionValues){
                if([self bindObject:value toColumn:index inStatement:compiledStatement] != SQLITE_OK){
                    NSLog(@"could not bind %@", value);
                }
                index++;
            }
        }
        //Get column names from compiled statement
        int columnCount = sqlite3_column_count(compiledStatement);
        NSMutableArray *columnNames = [NSMutableArray array];
        for(int i=0;i<columnCount;i++) {
            if(sqlite3_column_name(compiledStatement,i) != NULL) {
                [columnNames addObject:[NSString stringWithUTF8String:sqlite3_column_name(compiledStatement,i)]];
            } else {
                [columnNames addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }

        
        //Create objects for each row
        while(sqlite3_step(compiledStatement) == SQLITE_ROW)
        {
            
            ACRemote *object =(ACRemote *)[ACRemote columnPropertyPair]; //[[classType alloc] init];
           
            id value=nil;
    
            for(int i = 0; i<columnCount; i++){
                NSString *column = [columnNames objectAtIndex:i];
                switch (sqlite3_column_type(compiledStatement,i))
                {
                    case SQLITE_INTEGER:
                        value = [NSNumber numberWithInt:sqlite3_column_int(compiledStatement, i)];
                        break;
                    case SQLITE_FLOAT:
                        value = [NSNumber numberWithDouble:sqlite3_column_double(compiledStatement, i)];
                        break;
                    case SQLITE_TEXT:
                    default:{
                        const char *text = (const char *)sqlite3_column_text(compiledStatement, i);
                        if(text){
                            value = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
                            
                            if (value) {
//                                value = [value stringByDecodingHTMLEntities];
//                                value = [value stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];
//                                value = [value stringByReplacingOccurrencesOfString: @"<br />" withString: @"\n"];
//                                value = [value stringByReplacingOccurrencesOfString: @"<br/>" withString: @"\n"];
                            }

                        }else{
                            value =@"";
                        }
                    }
                        break;
                }
                NSString *propertyName = [propertyColumnPair valueForKey:column];
                if(propertyName){
                    [object setValue:value forKey:propertyName];
                //    setProperty(propertyName, value, object);
                }
            }
            [resultArray addObject:object];
        }
        sqlite3_finalize(compiledStatement);
    }
    __autoreleasing NSArray *finalArray = [resultArray copy];
    return finalArray;
}

//Class method for getting column names
+(NSMutableArray *)getColumnNamesForTable:(NSString *)table{
    [self checkDBVar];
    return [db getColumnNamesForTable:table];
}

//Returns array of columns for specified table.
-(NSMutableArray *)getColumnNamesForTable:(NSString *)table{
    NSMutableArray *columns = [NSMutableArray array];
    sqlite3_stmt *sqlStatement;
    const char *query = [[NSString stringWithFormat:@"PRAGMA table_info(%@)",table] UTF8String];
    if(sqlite3_prepare_v2(dbHandle, query, -1, &sqlStatement, NULL) != SQLITE_OK)
    {
        NSLog(@"Problem with prepare statement tableInfo %@",[NSString stringWithUTF8String:(const char *)sqlite3_errmsg(dbHandle)]);
        return nil;
    }
    
    while (sqlite3_step(sqlStatement)==SQLITE_ROW)
    {
        [columns addObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(sqlStatement, 1)]];
    }
    return columns;
}

//Returns SQLITE type for string type fetched from table info.
-(int) sqliteTypeFromString:(NSString *)typeString{
//#define SQLITE_FLOAT    2
//#define SQLITE_BLOB     4
    typeString  = [typeString lowercaseString];
    int type = SQLITE_NULL;
    if([typeString hasPrefix:@"varchar"] || [typeString hasPrefix:@"text"])
        type = SQLITE_TEXT;
    else if([typeString hasPrefix:@"int"] || [typeString hasPrefix:@"enum"])
        type = SQLITE_INTEGER;
    else if([typeString hasPrefix:@"binary"] || [typeString hasPrefix:@"blob"])
        type = SQLITE_BLOB;
    else if([typeString hasPrefix:@"real"] || [typeString hasPrefix:@"float"]
            || [typeString hasPrefix:@"double"] || [typeString hasPrefix:@"currency"])
        type = SQLITE_FLOAT;
    else if([typeString hasPrefix:@"date"] || [typeString hasPrefix:@"time"]){
        type = SQLITE_FLOAT;
    }
    return type;
}

//Fecthed column types for specified table and return in out variable coulmnTypes
-(void) getColumnTypesForTable:(NSString *)table columnTypes:(int *)columnTypes
{
    sqlite3_stmt *sqlStatement;
    const char *query = [[NSString stringWithFormat:@"PRAGMA table_info(%@)",table] UTF8String];
    
    if(sqlite3_prepare_v2(dbHandle, query, -1, &sqlStatement, NULL) != SQLITE_OK)
    {
        printf("Problem with prepare statement tableInfo %s",sqlite3_errmsg(dbHandle));
    };
    while (sqlite3_step(sqlStatement)==SQLITE_ROW)
    {
        int columnIndex = atoi((const char *)sqlite3_column_text(sqlStatement, 0));
        NSString * columnType = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStatement, 2)];
        columnTypes[columnIndex] = [self sqliteTypeFromString:columnType];
    }
}

//Class method for executeInsert_ReplaceQueryForTable for model objects
+(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table objects:(NSArray *)modelObjects{
    [self checkDBVar];
        return [db executeInsert_ReplaceQueryForTable:table objects:modelObjects];    
}

-(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table objects:(NSArray *)modelObjects{
    Class objectClass = [[modelObjects lastObject] class];
    NSDictionary *propertyColumnPair = [objectClass columnPropertyPair];
    NSMutableArray *tableColumns = [self getColumnNamesForTable:table];
    NSArray *columnsInObj = [propertyColumnPair allKeys];
    
    NSMutableSet *tableColumnsSet = [NSMutableSet setWithArray:tableColumns];
    NSMutableSet *columnsInObjSet = [NSMutableSet setWithArray:columnsInObj];
    
    //Get common columns by intersecting the two sets
    [tableColumnsSet intersectSet:columnsInObjSet];
    NSArray *availableColumns = [tableColumnsSet allObjects];
    
    //Prepare query statement
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (",table];
    for (NSString *column in availableColumns) {
        [query appendFormat:@"%@,",column];
    }
    [query replaceCharactersInRange:NSMakeRange(query.length - 1, 1) withString:@""];
    [query appendString:@") Values("];
    for(int i=0;i<availableColumns.count;i++){
        [query appendString:@"?,"];
    }
    [query replaceCharactersInRange:NSMakeRange(query.length - 1, 1) withString:@""];
    [query appendString:@")"];
    
    sqlite3_stmt* sqlstatement = NULL;
    //prepare statement and bind object properties to columns
	if(sqlite3_prepare_v2(dbHandle, [query UTF8String], -1, &sqlstatement, 0) == SQLITE_OK)
    {
//        char *errMsg = NULL;
        int retVal = sqlite3_exec(dbHandle, "BEGIN", 0, 0, 0);
        if(retVal != SQLITE_OK)
            NSLog(@"Failed to begin Tx");
        
        for(id object in modelObjects){
            for(NSString *column in availableColumns){
                NSString *key = [propertyColumnPair valueForKey:column];
                id value = [object valueForKey:key];
                int index = [availableColumns indexOfObject:column]+1;
                [self bindObject:value toColumn:index inStatement:sqlstatement];
            }
            //Step and reset for each row bound.
            NSUInteger err = sqlite3_step(sqlstatement);
            if (err != SQLITE_DONE)
                NSLog(@"replace error %lu %s",(unsigned long)err, sqlite3_errmsg(dbHandle));
//            sqlite3_clear_bindings(sqlstatement);
            sqlite3_reset(sqlstatement);
        }
        sqlite3_exec(dbHandle, "COMMIT", 0, 0, 0);
    }

//    sqlite3_step(sqlstatement);
    int result = sqlite3_finalize(sqlstatement)== SQLITE_OK;
    return result;
}

//Class method for executeInsert_ReplaceQueryForTable for dictionary array
+(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table jsonArray:(NSArray *)parsedArray{
    [self checkDBVar];
    return [db executeInsert_ReplaceQueryForTable:table jsonArray:parsedArray];
}

-(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table jsonArray:(NSArray *)parsedArray{
    NSMutableArray *columns = [self getColumnNamesForTable:table];
    NSArray *availableColumns = nil;
    if(parsedArray.count)
        availableColumns = [(NSDictionary *)[parsedArray objectAtIndex:0] allKeys];
    
    //Prepare query statement
    NSMutableString *query = [[NSMutableString alloc] initWithFormat:@"INSERT OR REPLACE INTO %@ (",table];
    for (NSString *column in columns) {
        [query appendFormat:@"%@,",column];
    }
    [query replaceCharactersInRange:NSMakeRange(query.length - 1, 1) withString:@""];
    [query appendString:@") values ("];
    for(int i=0;i<columns.count;i++){
        [query appendString:@"?,"];
    }
    [query replaceCharactersInRange:NSMakeRange(query.length - 1, 1) withString:@""];
    [query appendString:@")"];
    
    //get columnd types for table
    int *columnTypes = malloc(columns.count*sizeof(int));
    [self getColumnTypesForTable:table columnTypes:columnTypes];
    
    sqlite3_stmt* sqlstatement = NULL;
    //prepare statement and bind object properties to columns
    int result = sqlite3_prepare_v2(dbHandle, [query UTF8String], -1, &sqlstatement, 0);
	if(result == SQLITE_OK)
    {
        int retVal = sqlite3_exec(dbHandle, "BEGIN", 0, 0, 0);
        if(retVal != SQLITE_OK)
            NSLog(@"Failed to begin Tx");
        
        for(NSDictionary *dict in parsedArray){
            for(NSString *column in columns){
                id value = [dict valueForKey:column];
                int index = [columns indexOfObject:column];
                [self bindColumn:index+1 toType:columnTypes[index] forObject:value inStatement:sqlstatement];
            }
            //Step and reset for each row bound.
            NSUInteger err = sqlite3_step(sqlstatement);
            if (err != SQLITE_DONE)
                NSLog(@"replace error %lu %s",(unsigned long)err, sqlite3_errmsg(dbHandle));
            sqlite3_reset(sqlstatement);
        }
        sqlite3_exec(dbHandle, "COMMIT", 0, 0, 0);
    }
    free(columnTypes);

    result = sqlite3_finalize(sqlstatement);
    return (result== SQLITE_OK);
}

//Bind object to specified column index
- (int)bindObject:(id)obj toColumn:(int)idx inStatement:(sqlite3_stmt*)pStmt {
    int response = 0;
	if ((!obj) || ((NSNull *)obj == [NSNull null])) {
		response = sqlite3_bind_null(pStmt, idx);
	} else if ([obj isKindOfClass:[NSData class]]) {
		response = sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
	} else if ([obj isKindOfClass:[NSDate class]]) {
		response = sqlite3_bind_double(pStmt, idx, [obj timeIntervalSince1970]);
	} else if ([obj isKindOfClass:[NSNumber class]]) {
		if (strcmp([obj objCType], @encode(BOOL)) == 0) {
			response = sqlite3_bind_int(pStmt, idx, ([obj boolValue] ? 1 : 0));
		} else if (strcmp([obj objCType], @encode(int)) == 0) {
			response = sqlite3_bind_int64(pStmt, idx, [obj intValue]);
		} else if (strcmp([obj objCType], @encode(long)) == 0) {
			response = sqlite3_bind_int64(pStmt, idx, [obj longValue]);
		} else if (strcmp([obj objCType], @encode(float)) == 0) {
			response = sqlite3_bind_double(pStmt, idx, [obj floatValue]);
		} else if (strcmp([obj objCType], @encode(double)) == 0) {
			response = sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
		} else {
			response = sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
		}
	} else {
		response = sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
    if(response>0)
        NSLog(@"%d",response);
    return response;
}

- (void)bindColumn:(int)idx toType:(int)type forObject:(id)obj inStatement:(sqlite3_stmt*)pStmt {
    int response = 0;
    switch (type) {
//        case SQLITE_INTEGER:
//            response =sqlite3_bind_int64(pStmt, idx, (sqlite3_int64)[obj longLongValue]);
//            break;
                    case SQLITE_FLOAT:
           response =sqlite3_bind_double(pStmt, idx, [obj doubleValue]);
            break;
        case SQLITE_BLOB:
            response =sqlite3_bind_blob(pStmt, idx, [obj bytes], [obj length], SQLITE_STATIC);
            break;
//        case SQLITE_TEXT:
        default:
            response =sqlite3_bind_text(pStmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
            break;
    }
}

//Class method for queryHasResult
+(BOOL)queryHasResult:(NSString *)query{
    [self checkDBVar];
    return [db queryHasResult:query];
}

-(BOOL)queryHasResult:(NSString *)query{
    const char *sqlStatement = [query UTF8String];
    BOOL hasResult = NO;
    sqlite3_stmt *compiledStatement;
    if(sqlite3_prepare_v2(dbHandle, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
        while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
            hasResult = YES;
            break;
        }
        sqlite3_finalize(compiledStatement);
    }
    return hasResult;
}

//Class method for deleting data
+(BOOL)deleteTableDataFromTable:(NSString*) tableName{
    [self checkDBVar];
    NSLog(@"deleteTableDataFromTable: %@",tableName);
    return [db deleteTableDataFromTables:[NSArray arrayWithObject:tableName]];
}

//Class method for deleting data
+(BOOL)deleteTableDataFromTables:(NSArray*) tables{
    [self checkDBVar];
    return [db deleteTableDataFromTables:tables];
}

-(BOOL)deleteTableDataFromTables:(NSArray*) tables{
//	if(isDBOpen){
    
    int successCount = 0;
    int commitSucces = SQLITE_ERROR;
    
    sqlite3_exec(dbHandle, "BEGIN", 0, 0, 0);
    for(NSString *tableName in tables)
    {
        NSString*sql=[NSString stringWithFormat:@"DELETE FROM %@",tableName];
		NSLog(@"DELETE sql: %@",sql);
        
        const char*sqlStatement=[sql UTF8String];
        char*errMsg=nil;
        
        if(sqlite3_exec(dbHandle, sqlStatement, NULL, NULL, &errMsg)==SQLITE_OK){
            NSLog(@"Deleted table successfully: %@",tableName);
            successCount++;
        }
        else{
            printf("Error:%s",errMsg);
        }
    }
    commitSucces = sqlite3_exec(dbHandle, "COMMIT", 0, 0, 0);
//	}
	return (successCount == tables.count && commitSucces == SQLITE_OK);
}

+(BOOL)deleteTableContentForQuery:(NSString *)query{
    [self checkDBVar];
    return [db deleteTableContentForQuery:query];
}

-(BOOL)deleteTableContentForQuery:(NSString *)query{
    const char*sqlStatement=[query UTF8String];
    char*errMsg=nil;
    
    sqlite3_exec(dbHandle, "BEGIN", 0, 0, 0);
    if(sqlite3_exec(dbHandle, sqlStatement, NULL, NULL, &errMsg)==SQLITE_OK){
        NSLog(@"rows deleted successfully for query: %@",query);
        sqlite3_exec(dbHandle, "COMMIT", 0, 0, 0);        
        return YES;
    }
    else{
        printf("Error:%s",errMsg);
    }
    sqlite3_exec(dbHandle, "COMMIT", 0, 0, 0);
    
    return NO;
}

+(NSArray*) getTables{
    [self checkDBVar];
    return [db getTables];
}

-(NSArray*) getTables{
	NSMutableArray *tables=[[NSMutableArray alloc] init];
	if(isDBOpen) {
		const char *sqlStatement = [[NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"] UTF8String];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(dbHandle, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				NSString *value=nil;
				value=[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)];
				[tables addObject:value];
			}
			sqlite3_finalize(compiledStatement);
		}
	}
    __autoreleasing NSArray *allTables = [NSArray arrayWithArray:tables];
	return allTables;
}



#pragma mark - Database operation on event change
+(NSString *)dataBaseSourcePath{
    return [[NSBundle mainBundle] pathForResource:@"IRAutomation" ofType:@"sqlite"];
    
}

+(NSString *)databaseName{
    NSString *fileName = @"IRAutomation.sqlite";
    return fileName;
}

+(NSString *)databaseDestinationPath{
//    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSString *fileName = [self databaseName];
    
    NSString *docsDir;

    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
     return  [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent:[self databaseName]]];

    
//    return [documentDir stringByAppendingFormat:@"/Database/%@",fileName];
}

+(void)setDatabasePath{
    [IRDatabase resetDatabase];
    NSString *dbSourcePath = [self dataBaseSourcePath];
    NSString *dbDestintaionPath = [self databaseDestinationPath];
    [IRDatabase setDatabaseDestinationPath:dbDestintaionPath];
    [IRDatabase setDatabaseSourcePath:dbSourcePath];
}

@end
