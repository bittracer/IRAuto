
#import <Foundation/Foundation.h>
#import "ACRemote.h"
#import "IRDatabase.h"


@interface ACRemoteModelService : NSObject
+(NSArray *)getACRemoteForQuery:(NSString *)query;
+(NSArray *)getACRemotes;
+(void)updateRemote:(ACRemote *)remote;
+(BOOL)recordExist;


@end
