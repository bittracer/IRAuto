//
//  NSString+IRUserDetail.h
//  IRAutomation
//
//  Created by bharat jain on 2/20/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FormValidation)

- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (BOOL)isValidString;
- (BOOL)isValidContact;

@end
