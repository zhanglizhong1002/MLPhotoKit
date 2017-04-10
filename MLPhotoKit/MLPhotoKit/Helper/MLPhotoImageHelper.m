//
//  MLPhotoImageHelper.m
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLPhotoImageHelper.h"


@implementation MLPhotoImageHelper


// 获取相册列表
+ (void)getAlbumListWithAscend:(BOOL)isAscend complete:(void (^)(NSArray<PHFetchResult *> *))complete
{
    PHFetchOptions *imageOptions = [[PHFetchOptions alloc] init];
    imageOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscend]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:imageOptions];
    
    
    PHFetchOptions *customOptions = [[PHFetchOptions alloc] init];
    customOptions.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    customOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:isAscend]];
    PHFetchResult *customPhotos = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:customOptions];
    
    
    NSArray *list = @[allPhotos, customPhotos];
    complete?complete(list):nil;
}

// 获取置顶大小的图片
+ (void)getImageWithAsset:(PHAsset *)asset tagetSize:(CGSize)size complete:(void(^)(UIImage *))complete
{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    [imageManager requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                complete?complete(result):nil;
            });
        });
    }];
}

+ (void)getImageDataWithAsset:(PHAsset *)asset complete:(void (^)(UIImage *,UIImage*))complete
{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        UIImage *HDImage = [UIImage imageWithData:imageData];
//        UIImage *image = [UIImage clipImage:HDImage];
//        complete?complete(image,HDImage):nil;
        UIImage *HDImage = [UIImage imageWithData:imageData];
        UIImage *image = HDImage;
        complete?complete(image,HDImage):nil;
    }];
    
    
}


#pragma mark - <  获取相册里的所有图片的PHAsset对象  >
+ (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    // 存放所有图片对象
    NSMutableArray *assets = [NSMutableArray array];
    
    // 是否按创建时间排序
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    
    // 获取所有图片对象
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    // 遍历
    [result enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [assets addObject:asset];
    }];
    return assets;
}


+ (BOOL)isOpenAuthority
{
    return [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied;
}

+ (void)jumpToSetting
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

+ (void)showAlertWithTittle:(NSString *)title message:(NSString *)message showController:(UIViewController *)controller isSingleAction:(BOOL)isSingle complete:(void (^)(NSInteger))complete{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        complete?complete(0):nil;
    }];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        complete?complete(1):nil;
    }];
    if (!isSingle) {
        [alertController addAction:cancleAction];
    }
    [alertController addAction:confirmAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

@end



@implementation ImageModel



@end
