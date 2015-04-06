//
//  NSString+IRUserDetail.m
//  IRAutomation
//
//  Created by bharat jain on 2/20/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "NSString+FormValidation.h"

@implementation NSString (FormValidation)


- (BOOL)isValidEmail {
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [emailPredicate evaluateWithObject:self];
}

- (BOOL)isValidPassword {
    return (self.length >= 5);
}

- (BOOL)isValidString {
    NSString *stringRegex = @"[A-Za-z]+";
    NSPredicate *stringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stringRegex];
    return [stringPredicate evaluateWithObject:self];
}

- (BOOL)isValidContact {
    NSString *phoneRegex = @"[0-9]{10}";
    NSPredicate *phonePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phonePredicate evaluateWithObject:self];
}



@end
