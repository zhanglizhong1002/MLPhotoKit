//
//  MLAlbumImageCollectionViewCell.m
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLAlbumImageCollectionViewCell.h"

@implementation MLAlbumImageCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setAsset:(PHAsset *)asset
{
    _asset = asset;
}

@end
