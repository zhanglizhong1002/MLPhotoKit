//
//  MLShowBigImage.h
//  Medicine
//
//  Created by Visoport on 6/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MLShowBigImage : UIView <UIScrollViewDelegate>

+ (MLShowBigImage *)shareInstance;

- (void)showBigImage:(UIImageView *)imageView;

@end
