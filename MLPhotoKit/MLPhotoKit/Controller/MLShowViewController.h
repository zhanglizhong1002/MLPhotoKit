//
//  MLShowViewController.h
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLShowViewController : UIViewController


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *imageDataSource;
@property (nonatomic, strong) NSMutableArray *selectArray;

@property (nonatomic, strong) UIView *collectionSuperView;
@property (nonatomic, assign) NSInteger maxCount;

- (void)initCollectionView;


@end
