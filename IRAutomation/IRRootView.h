//
//  IRRootView.h
//  IRAutomation
//
//  Created by bharat jain on 2/26/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRRootView : UIViewController <UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSArray *imgList;
    NSArray *nameList;
    
    
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic) NSMutableArray *name;

- (IBAction)OpenClose:(id)sender;
- (void)initialize;

@end


