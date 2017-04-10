//
//  MLAlbumImageCollectionViewCell.h
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@interface MLAlbumImageCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (nonatomic, strong) PHAsset *asset;

@end
