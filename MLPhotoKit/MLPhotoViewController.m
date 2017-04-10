//
//  MLPhotoViewController.m
//  MLPhotoKit
//
//  Created by Visoport on 11/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLPhotoViewController.h"

@interface MLPhotoViewController ()
@property (weak, nonatomic) IBOutlet UIView *imageCollectionView;

@end

@implementation MLPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // 1. 新建一个类继承 MLShowViewController
    
    // 2. 设置collectionSuperView进行赋值
    self.collectionSuperView = self.imageCollectionView;
    // 3. 设置可添加图片的最大数
    self.maxCount = 9;
    // 4. 初始化CollectionView
    [self initCollectionView];
}

- (IBAction)commitItemAction:(id)sender {
    
    // self.imageDataSource存储的是UIImage类型，上传直接遍历转换data类型即可
    NSLog(@"%@", self.imageDataSource);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
