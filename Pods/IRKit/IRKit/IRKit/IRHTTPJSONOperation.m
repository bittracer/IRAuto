//
//  IRHTTPJSONOperation.m
//  IRKit
//
//  Created by Masakazu Ohtsuka on 2013/12/02.
//
//

#import "IRHTTPJSONOperation.h"
#import "Log.h"
#import <IRKeys.h>

@implementation IRHTTPJSONOperation

- (id)processData:(NSData *)data {
    NSError *error = nil;
    id object = nil;

    // don't try to parse empty string
    if (data.length) {
        object = [NSJSONSerialization JSONObjectWithData: data
                                                 options: NSJSONReadingAllowFragments
                                                   error: &error];
        if (error) {
            LOG(@"JSON error: %@", error);
        }
    }
    // Prints Device ID & Device Key
    NSLog(@"%@",object);
    
    return object;
}

@end
