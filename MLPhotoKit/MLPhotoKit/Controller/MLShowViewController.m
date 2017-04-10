//
//  MLShowViewController.m
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLShowViewController.h"
#import "MLAlbumListTableViewController.h"
#import "MLAlbumImageCollectionViewCell.h"
#import "MLCustomSheet.h"
#import "MLShowBigImage.h"

#define kScreenWidth             ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight            ([[UIScreen mainScreen] bounds].size.height)

@interface MLShowViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, MLCustomSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>


@end

@implementation MLShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil]; //请求相册访问权限 获取权限后的回调方法是什么
}

- (void)dismissController
{
    [self dismissViewControllerAnimated:YES completion:nil]; 
}

- (void)photoListDidClick
{
    if (self.selectArray.count >= self.maxCount) {
        [MLPhotoImageHelper showAlertWithTittle:[NSString stringWithFormat:@"最多只能选择%d张图片",9] message:nil showController:self isSingleAction:YES complete:nil];
        return;
    }
    
    NSArray *array = @[NSLocalizedString(@"照相机", nil), NSLocalizedString(@"本地相簿", nil)];
    MLCustomSheet *sheet = [[MLCustomSheet alloc] initWithButtons:array isTableView:NO];
    sheet.delegate = self;
    [self.view addSubview:sheet];
    
    
}

#pragma mark - MLCustomSheetDelegate
- (void)clickButton:(NSUInteger)buttonTag sheetCount:(NSUInteger)sheet
{
    switch (buttonTag) {
        case 0://照相机
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = NO;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
            
        }
            break;
        case 1://本地相簿
        {
            MLAlbumListTableViewController *vc = [[MLAlbumListTableViewController alloc] init];
            vc.selctImageArray = self.selectArray;
            vc.maxCount = self.maxCount;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            
            __weak MLShowViewController *weakSelf = self;
            
            vc.okClickComplete = ^(NSArray<ImageModel *> *images){
                
                [weakSelf.imageDataSource removeAllObjects];
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    [images enumerateObjectsUsingBlock:^(ImageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if (obj.asset) {
                            [MLPhotoImageHelper getImageDataWithAsset:obj.asset complete:^(UIImage *image,UIImage*HDImage) {
                                if (image) {
                                    
                                    [weakSelf.imageDataSource addObject:image];
  
                                }
                            }];
                            
                        }
                        else
                        {
                            [weakSelf.imageDataSource addObject:obj.thumbImage];
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [weakSelf.collectionView reloadData];
                            
                            [weakSelf scrollsToBottomAnimated:NO];
                        });
                        
                    }];
                });
            };
            [self presentViewController:nav animated:YES completion:nil];
            
        }
            break;
            
        default:
            break;
    }
}



#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.imageDataSource.count == 0) {
        return 1;
    }
    else
    {
        return self.imageDataSource.count+1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLAlbumImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];

    if (indexPath.row == self.imageDataSource.count) {
        cell.coverImageView.image = [UIImage imageNamed:@"plus"];
        
        
        cell.closeButton.hidden = YES;
    }
    else
    {
        cell.coverImageView.image = self.imageDataSource[indexPath.row];
        
        
        cell.closeButton.hidden = NO;
    }

    cell.coverImageView.userInteractionEnabled = YES;
    cell.coverImageView.tag = indexPath.row;
    [cell.coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImage:)]];
    
    cell.closeButton.tag = indexPath.row;
    [cell.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [cell.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"点击了ITEM");
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(2, 2, 2, 2);
}


#pragma mark - 图片cell点击事件
- (void) tapProfileImage:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView *clickImageView = (UIImageView*)gestureRecognizer.view;
    NSInteger index = clickImageView.tag;
    
    if (index == self.imageDataSource.count) {
        [self photoListDidClick];
    }
    else
    {
        [[MLShowBigImage shareInstance] showBigImage:clickImageView];
    }
}

- (void)closeButtonAction:(UIButton *)sender
{
    
    [self.selectArray removeObjectAtIndex:sender.tag];
    [self.imageDataSource removeObjectAtIndex:sender.tag];
    [self.collectionView reloadData];
}

#pragma mark -   imagepicker delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        [picker dismissViewControllerAnimated:YES completion:^{
        }];
        UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    // 保存相片到相机胶卷
    NSError *error1 = nil;
    __block PHObjectPlaceholder *createdAsset = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
    } error:&error1];
        if (error1) {
            
        }
        else
        {
            // 获取所有资源的集合，并按资源的创建时间排序
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
            
            PHAsset *PHasset = [assetsFetchResults firstObject];
            
            ImageModel *item = [ImageModel new];
            item.asset = PHasset;
            [self.selectArray addObject:item];
            
            [MLPhotoImageHelper getImageDataWithAsset:item.asset complete:^(UIImage *image,UIImage*HDImage) {
                if (image) {
                    
                    [self.imageDataSource addObject:image];
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [picker dismissViewControllerAnimated:NO completion:nil];
                    [self.collectionView reloadData];
                });
            }];
        }
    }
}



- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 0;
    CGFloat width = (kScreenWidth-16 - 2 * 3) / 4;
    layout.itemSize = CGSizeMake(width, width);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth-16, width+10) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.collectionSuperView) {
        [self.collectionSuperView addSubview:self.collectionView];
    }
    else
    {
        [self.view addSubview:self.collectionView];
    }

    [self.collectionView registerNib:[UINib nibWithNibName:@"MLAlbumImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
}

- (void)scrollsToBottomAnimated:(BOOL)animated
{
    [self.view layoutIfNeeded];
    CGFloat offset = self.collectionView.contentSize.width - self.collectionView.bounds.size.width;
    if (offset > 0)
    {
        [self.collectionView setContentOffset:CGPointMake(offset, 0) animated:animated];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self scrollsToBottomAnimated:NO];
}

- (NSMutableArray*)imageDataSource
{
    if (!_imageDataSource ) {
        _imageDataSource = [NSMutableArray array];
    }
    return _imageDataSource;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray ) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

@end





