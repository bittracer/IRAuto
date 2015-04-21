
#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>

@interface IRDatabase : NSObject
{
    BOOL isDBOpen;                  //Flag indicating database is open or not. Yes = Open and No = Closed
}

+(NSArray *)executeSelectQuery:(NSString *)query;

/* This function retuns the array of object of type 'classType'
 * Each object will contains value for perticular row.
 * This function does not prevent fron SQL injection
 */
+(NSArray *)executeSelectQuery:(NSString *)query objectType:(Class)classType;

/* This function retuns the array of object of type 'classType'
 * Each object will contains value for perticular row.
 * Old method is replaced with new method to avoid SQL injection problem
 */
+(NSArray *)executeSelectQuery:(NSString *)query objectType:(Class)classType whereConditionValues:(NSArray *)whereConditionValues;

//This function Checks whether or not query has result.
+(BOOL)queryHasResult:(NSString *)query;

//This function saves the object(passed in array) values in database by executing insert or replace query.
+(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table objects:(NSArray *)modelObjects;

//This functions accept the array of dictionary instaed of custom model class and saved dictionary values in database.
+(BOOL)executeInsert_ReplaceQueryForTable:(NSString *)table jsonArray:(NSArray *)parsedArray;

//This function removes all rows from table.
+(BOOL)deleteTableDataFromTable:(NSString*) tableName;
+(BOOL)deleteTableDataFromTables:(NSArray*) tables;

//This function removes rows from table which matches the condition.
+(BOOL)deleteTableContentForQuery:(NSString *)query;

//Get all tables from database
+(NSArray*) getTables;

//Resetting database
+(void)resetDatabase;

+(void)setDatabaseDestinationPath:(NSString *)dbDestinationPath;
+(NSString *)getDatabaseDestinationPath;
+(void)setDatabaseSourcePath:(NSString *)dbSourcePath;
+(NSString *)getDatabaseSourcePath;


+(void)setDatabasePath;

@end
