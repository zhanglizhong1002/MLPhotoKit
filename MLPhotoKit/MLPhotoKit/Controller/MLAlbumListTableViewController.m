//
//  MLAlbumListTableViewController.m
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLAlbumListTableViewController.h"


@interface MLAlbumListTableViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation MLAlbumListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"相册";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    
    
    self.tableView.rowHeight = 80;

    [self.tableView registerNib:[UINib nibWithNibName:@"MLAlbumListTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

- (void)dismissController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //加载数据
    [self loadAlbums];
}

- (void)loadAlbums
{
    if (![MLPhotoImageHelper isOpenAuthority]) {
        [MLPhotoImageHelper showAlertWithTittle:@"您未打开照片权限" message:nil showController:self isSingleAction:NO complete:^(NSInteger index) {
            if (index == 1) {
                [MLPhotoImageHelper jumpToSetting];
            }
            else
            {
                [self dismissController];
            }
        }];
    }
    
    [MLPhotoImageHelper getAlbumListWithAscend:YES complete:^(NSArray<PHFetchResult *> *albumList) {
        self.dataSource = albumList;
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    else
    {
        PHFetchResult *fetchResult = self.dataSource[section];
        if (fetchResult) {
            return fetchResult.count;
        }
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLAlbumListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    PHFetchResult *fetchResult = self.dataSource[indexPath.section];
    if (indexPath.section == 0) {
        cell.albumTitleLabel.text = @"相机胶卷";
        cell.albumDetailLabel.text = [NSString stringWithFormat:@"%ld", fetchResult.count];
    }
    else
    {
        PHCollection *collection = fetchResult[indexPath.row];
        cell.albumTitleLabel.text = collection.localizedTitle;
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            
            PHFetchResult *assetFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            cell.albumDetailLabel.text = [NSString stringWithFormat:@"%ld", assetFetchResult.count];
            fetchResult = assetFetchResult;
        }
    }
    
    if (fetchResult.count > 0) {
        PHAsset *asset = fetchResult[0];
        
        [MLPhotoImageHelper getImageWithAsset:asset tagetSize:CGSizeMake(120, 120) complete:^(UIImage *image) {
            cell.coverImageView.image = image;
        }];
    }
    
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PHFetchResult *fetchResult = nil;
    if (indexPath.section == 0) {
        fetchResult = (PHFetchResult *)self.dataSource[0];
    }
    else
    {
        PHFetchResult *result = (PHFetchResult *)self.dataSource[indexPath.section];
        PHCollection *collection = result[indexPath.row];
        
        if ([collection isKindOfClass:[PHAssetCollection class]]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        }
    }
    
    MLAlbumListTableViewCell *cell = [tableView  cellForRowAtIndexPath:indexPath];
    
    MLImageCollectionViewController *vc = [[MLImageCollectionViewController alloc] init];
    vc.title = cell.albumTitleLabel.text;
    vc.fetchResult = fetchResult;
    vc.selectArray = self.selctImageArray;
    vc.okClickComplete = self.okClickComplete;
    vc.maxCount = self.maxCount;
    
    [self.navigationController pushViewController:vc animated:YES];
}


@end
