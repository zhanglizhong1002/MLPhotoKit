//
//  MLAlbumListTableViewController.h
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLPhotoImageHelper.h"
#import "MLAlbumListTableViewCell.h"
#import "MLImageCollectionViewController.h"


@interface MLAlbumListTableViewController : UITableViewController

@property (nonatomic, copy) void(^okClickComplete)(NSArray<ImageModel *> *images);

@property (nonatomic, strong) NSMutableArray *selctImageArray;

@property (nonatomic, assign) NSInteger maxCount;

@end
