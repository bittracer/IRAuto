
#import <Foundation/Foundation.h>

@interface ACRemote : NSObject

@property(nonatomic,strong) NSString *acstate;
@property(nonatomic,strong) NSString *mode;
@property(nonatomic) NSString *timer;
@property(nonatomic) NSString *turbo;
@property(nonatomic) NSString *night;
@property(nonatomic) NSString *slider;


+(NSDictionary *)columnPropertyPair;



@end
