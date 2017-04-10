//
//  MLImageCollectionViewController.m
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLImageCollectionViewController.h"
#import "MLAlbumImageCollectionViewCell.h"
#import "MLShowBigImage.h"
#import <objc/runtime.h>


#define kScreenWidth             ([[UIScreen mainScreen] bounds].size.width)
#define kScreenHeight            ([[UIScreen mainScreen] bounds].size.height)


#define kItemWidth      2 * (kScreenWidth - 4)/3.0

@interface MLImageCollectionViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, assign) NSInteger dataCount;
@end

@implementation MLImageCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    self.dataCount = self.selectArray.count;
    
    [self creatCollectionView];
    [self changeRightBarButtonItemTitle];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNacigationItemAction)];
}

- (void)cancelNacigationItemAction
{
    int count = (int)self.selectArray.count;
    for (int index = (int)self.dataCount; index<count; ++index) {
        [self.selectArray removeLastObject];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)changeRightBarButtonItemTitle
{
    if (self.selectArray.count > 0) {
        [self setRightBarButtonItemWithTitle:[NSString stringWithFormat:@"确定(%ld)", self.selectArray.count]];
    }
    else
    {
        [self setRightBarButtonItemWithTitle:@"取消"];
    }
}

- (void)setRightBarButtonItemWithTitle:(NSString *)title
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:@selector(didClickNavigationBarViewRightButton)];
}

- (void)didClickNavigationBarViewRightButton
{
    
    
    if (self.selectArray.count > 0) {
        self.okClickComplete ? self.okClickComplete(self.selectArray) : nil;
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.fetchResult.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MLAlbumImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.coverImageView.clipsToBounds = YES;
    cell.coverImageView.contentMode = UIViewContentModeScaleToFill;
    
    
    if (indexPath.row == self.fetchResult.count) {
        
        cell.coverImageView.image = [UIImage imageNamed:@"plus"];
        cell.closeButton.hidden = YES;
    }
    else
    {
        cell.closeButton.hidden = NO;
        
        PHAsset *asset = self.fetchResult[indexPath.row];
        
        
        if (!objc_getAssociatedObject(self, @"PHAssetThumbImageKey")) {
            
            [MLPhotoImageHelper getImageWithAsset:asset tagetSize:CGSizeMake(kItemWidth,kItemWidth) complete:^(UIImage *image) {
                cell.coverImageView.image = image;
            }];
        }
        else{
            
            cell.coverImageView.image = objc_getAssociatedObject(self, @"PHAssetThumbImageKey");
        }
        
        cell.asset = asset;
        
        cell.closeButton.tag = indexPath.row;
        [cell.closeButton setImage:[UIImage imageNamed:@"ico_check_nomal"] forState:UIControlStateNormal];
        [cell.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];

        for (ImageModel *item in self.selectArray) {
            if ([item.asset.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.closeButton.selected = YES;
                [cell.closeButton setImage:[UIImage imageNamed:@"ico_check_select"] forState:UIControlStateNormal];
            }
        }
        
    }
    
    cell.coverImageView.userInteractionEnabled = YES;
    cell.coverImageView.tag = indexPath.row;
    [cell.coverImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImage:)]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (kScreenWidth - 2 * 2) / 3;
    return CGSizeMake(width, width);
}


#pragma mark - 图片cell点击事件
- (void) tapProfileImage:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView *clickImageView = (UIImageView*)gestureRecognizer.view;
    NSInteger index = clickImageView.tag;
    
    if (index == self.fetchResult.count) {
        [self coverImageViewWithCamera];
    }
    else
    {
        [[MLShowBigImage shareInstance] showBigImage:clickImageView];
    }
}


- (void)closeButtonAction:(UIButton *)sender
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    MLAlbumImageCollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];
    
    
    sender.selected = !sender.selected;
    
    if (sender.selected) {

        

        if (self.selectArray.count >= self.maxCount) {
            [MLPhotoImageHelper showAlertWithTittle:[NSString stringWithFormat:@"最多只能选择%d张图片",9] message:nil showController:self isSingleAction:YES complete:nil];
            return;
        }
        
        [sender setImage:[UIImage imageNamed:@"ico_check_select"] forState:UIControlStateNormal];
        
        ImageModel *item = [ImageModel new];
        item.asset = cell.asset;
//        item.thumbImage = cell.coverImageView.image;
        [self.selectArray addObject:item];
    
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"ico_check_nomal"] forState:UIControlStateNormal];
        
        int count = -1;
        for (ImageModel *subItem in self.selectArray.mutableCopy) {
            count ++;
            if ([subItem.asset.localIdentifier isEqualToString:cell.asset.localIdentifier]) {
                [self.selectArray removeObjectAtIndex:count];
                break;
            }
        }
    }
    
    
    [self changeRightBarButtonItemTitle];
    
    
}

- (void)coverImageViewWithCamera
{
    if (self.selectArray.count >= self.maxCount) {
        [MLPhotoImageHelper showAlertWithTittle:[NSString stringWithFormat:@"最多只能选择%d张图片",9] message:nil showController:self isSingleAction:YES complete:nil];
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = NO;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePicker animated:YES completion:nil];
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
            NSMutableArray *allPhots = [NSMutableArray array];
            // 相机胶卷
            PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            
            for (NSInteger i = 0; i < smartAlbums.count; i++) {
                // 是否按创建时间排序
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
                option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
                PHCollection *collection = smartAlbums[i];
                
                //遍历获取相册
                if ([collection isKindOfClass:[PHAssetCollection class]]) {
                    if ([collection.localizedTitle isEqualToString:@"相机胶卷"] || [collection.localizedTitle isEqualToString:@"Camera Roll"]) {
                        PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
                        NSArray *assets;
                        if (fetchResult.count > 0) {
                            // 某个相册里面的所有PHAsset对象
                            assets = [MLPhotoImageHelper getAllPhotosAssetInAblumCollection:assetCollection ascending:YES ];
                            
                            [allPhots addObjectsFromArray:assets];
                            
                        }
                    }
                }
            }
            /** 最后一张照片为刚刚拍照传上去的 */
            PHAsset *PHasset = [allPhots lastObject];
            
            ImageModel *item = [ImageModel new];
            item.asset = PHasset;
            [self.selectArray addObject:item];

            [picker dismissViewControllerAnimated:NO completion:nil];
            [self didClickNavigationBarViewRightButton];
            
        }
    }
}


- (void)scrollsToBottomAnimated:(BOOL)animated
{
    [self.view layoutIfNeeded];
    CGFloat offset = self.collectionView.contentSize.height - self.collectionView.bounds.size.height;
    if (offset > 0)
    {
        CGFloat width = (kScreenWidth - 2 * 2) / 3;
        [self.collectionView setContentOffset:CGPointMake(0, offset+ width/2.0) animated:animated];
    }
}

- (void)creatCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 2.0;
    layout.minimumInteritemSpacing = 2.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    
    
    self.collectionView = collectionView;
    [self.view addSubview:self.collectionView];
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MLAlbumImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cell"];
    
    [self scrollsToBottomAnimated:NO];
}


@end






