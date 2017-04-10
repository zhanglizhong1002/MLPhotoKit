//
//  MLPhotoImageHelper.h
//  Medicine
//
//  Created by Visoport on 5/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


typedef NS_ENUM(NSInteger, AlbumType) {
    AlbumTypeDefault   = 0, // 默认
    AlbumTypeCumstom   = 1  // 自定义
};


@interface ImageModel : NSObject

@property (nonatomic, strong) UIImage *thumbImage; // 图片
@property (nonatomic, strong) PHAsset *asset;
//@property (nonatomic, assign) NSInteger index;
//@property (nonatomic, strong) NSString *title;

@end

@interface MLPhotoImageHelper : NSObject


// 获取相册里的所有图片的PHAsset对象
+ (NSArray *)getAllPhotosAssetInAblumCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

// 获取相册列表
+ (void)getAlbumListWithAscend:(BOOL)isAscend complete:(void(^)(NSArray<PHFetchResult *> *albumList))complete;

// 获取置顶大小的图片
+ (void)getImageWithAsset:(PHAsset *)asset tagetSize:(CGSize)size complete:(void(^)(UIImage *))complete;

//  获取指定大小的图片
+ (void)getImageDataWithAsset:(PHAsset *)asset complete:(void (^)(UIImage *,UIImage*))complete;

// 是否开启相机权限
+ (BOOL)isOpenAuthority;

// 跳转到设置界面
+ (void)jumpToSetting;

+ (void)showAlertWithTittle:(NSString *)title message:(NSString *)message showController:(UIViewController *)controller isSingleAction:(BOOL)isSingle complete:(void (^)(NSInteger))complete;
@end
