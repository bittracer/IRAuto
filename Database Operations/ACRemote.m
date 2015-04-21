#import "ACRemote.h"

@implementation ACRemote
+(NSDictionary *)columnPropertyPair{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setValue:@"acstate"forKey:@"acstate"];
    [dict setValue:@"mode" forKey:@"mode"];
    [dict setValue:@"timer" forKey:@"timer"];
    [dict setValue:@"turbo" forKey:@"turbo"];
    [dict setValue:@"night" forKey:@"night"];
    [dict setValue:@"slider" forKey:@"slider"];

    return dict;
}


@end
