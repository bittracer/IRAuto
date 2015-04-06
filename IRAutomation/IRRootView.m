//
//  IRRootView.m
//  IRAutomation
//
//  Created by bharat jain on 2/26/15.
//  Copyright (c) 2015 bharat jain. All rights reserved.
//

#import "IRRootView.h"
#import <UIViewController+MMDrawerController.h>
#import "constant.h"

#define AC 0
#define TV 1
#define MP 2

@interface IRRootView ()

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation IRRootView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialize];
   
   }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) initialize{

    // Array of Images
    imgList = @[@"aircondition_icn-Small", @"tv_icn-Small", @"musicplayer_icn-Small"];
    
    //Array of TextField
     nameList = @[@"Aircondition",@"Television",@"Music Player"];
    
}



#pragma mark - Collection View


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
    {
        return 1;

    }

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

        return [imgList count];
}


#pragma mark collection view cell paddings

- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        static NSString *cellIdentifier = @"cellIdentifier";
        NSString *cellData = [nameList objectAtIndex:indexPath.row];
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.layer.borderWidth=0.3f;
    cell.layer.borderColor=SELF_DEFINED1;
    
    // Titile
        UILabel *titleLabel = (UILabel *)[cell viewWithTag:101];
        [titleLabel setText:cellData];
    
    //Image View
        UIImageView *img=(UIImageView *)[cell viewWithTag:100];
        UIImage *image = [UIImage imageNamed:[imgList objectAtIndex:indexPath.row]];
        img.image = image;
    
    //Alignmnet of cell
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout*)self.collectionView.  collectionViewLayout;
        CGFloat availableWidthForCells = CGRectGetWidth(self.collectionView.frame) ;
        CGFloat cellWidth = availableWidthForCells / 3;
        flowLayout.itemSize = CGSizeMake(cellWidth, flowLayout.itemSize.height);
    
        return cell;
    
}

#pragma Collectionview didSelectItemAtIndexPath

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    switch (indexPath.item) {
            
        case AC:
            [self performSegueWithIdentifier:@"IRRoom" sender:self];
            break;
            
        case TV:
            //Replace identifier with viewcontroller of TV
            //[self performSegueWithIdentifier:@"IRAirCondition" sender:self];
            
            break;
            
        case MP:
            //Replace identifier with viewcontroller of Music Player
            //[self performSegueWithIdentifier:@"IRAirCondition" sender:self];
            break;
            
        default:
            break;
    }
    
    
}

- (IBAction)OpenClose:(id)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideRight animated:YES completion:nil];
}


@end
