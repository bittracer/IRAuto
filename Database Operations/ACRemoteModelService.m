#import "ACRemoteModelService.h"

@implementation ACRemoteModelService

+(NSArray *)getACRemoteForQuery:(NSString *)query
{
    return [IRDatabase executeSelectQuery:query objectType:[ACRemote class]];
}

+(NSArray *)getACRemotes
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM acremote"];
    NSArray *remotes = [self getACRemoteForQuery:query];
    return remotes;
}

+(void)updateRemote:(ACRemote *)remote
{
    NSString *query = [NSString stringWithFormat:@"UPDATE acremote SET acstate =\"%@\" ,mode = \"%@\",timer = \"%@\",turbo = \"%@\", night = \"%@\" , slider = \"%@\" WHERE rowid = 1",[remote valueForKey:@"acstate"],[remote valueForKey:@"mode"],[remote valueForKey:@"timer"],[remote valueForKey:@"turbo"],[remote valueForKey:@"night"],[remote valueForKey:@"slider"]];
    [IRDatabase executeSelectQuery:query];
        
}

+(BOOL)recordExist
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM acremote"];
    NSArray *remotes = [self getACRemoteForQuery:query];
    if (!remotes || ![remotes count]) {
        return NO;
    }
    else
    {
        return  YES;
    }

}

@end
