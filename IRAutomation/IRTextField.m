//
//  IRTextField.m
//  IRAutomation
//
//  Created by bharat jain on 2/25/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRTextField.h"

@implementation IRTextField



#pragma mark - UITextField Positioning 

-(CGRect)textRectForBounds:(CGRect)bounds{
    CGRect inset = CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
 
    return inset;
}

-(CGRect)editingRectForBounds:(CGRect)bounds{
    CGRect inset = CGRectMake(bounds.origin.x + 40, bounds.origin.y, bounds.size.width - 40, bounds.size.height);
    return inset;
}



@end
