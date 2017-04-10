//
//  MLShowBigImage.m
//  Medicine
//
//  Created by Visoport on 6/1/17.
//  Copyright © 2017年 Visoport. All rights reserved.
//

#import "MLShowBigImage.h"

@implementation MLShowBigImage
{
    UIScrollView *_scrollerView;
    UIImageView *_showImageView;
    CGRect _imageOriginalRect;
    CGFloat _proportionFloat;
    CGFloat _leverlFloat;
    CGFloat _verticalFloat;
}


+ (MLShowBigImage *)shareInstance
{
    static MLShowBigImage *showBigImage = nil;
    
    if (showBigImage == nil) {
        showBigImage = [[MLShowBigImage alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }
    
    [showBigImage initView];
    return showBigImage;
}

#pragma mark - 初始化方法
//初始化视图
- (void)initView {
    
    //初始化滚动视图
    _scrollerView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [_scrollerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
    [_scrollerView setShowsHorizontalScrollIndicator:NO];
    [_scrollerView setShowsVerticalScrollIndicator:NO];
    [_scrollerView setDelegate:self];
    [self addSubview:_scrollerView];
    
    //添加按手势————单击还原关闭图片
    UITapGestureRecognizer *oneTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [_scrollerView addGestureRecognizer:oneTap];
    
    //添加按手势————双击放大缩小图片
    UITapGestureRecognizer *twoTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [twoTap setNumberOfTapsRequired:2];
    [_scrollerView addGestureRecognizer:twoTap];
    
    //设置单、双击优先级(先识别双击，再识别单击)
    [oneTap requireGestureRecognizerToFail:twoTap];
    
    _showImageView = [[UIImageView alloc] init];
    [_showImageView setUserInteractionEnabled:YES];
    [_scrollerView addSubview:_showImageView];
}

#pragma mark - 手势触发
//点击触发————单击还原关闭图片  双击放大缩小图片
- (void)Tap:(UITapGestureRecognizer *)sender {
    //单击----还原关闭大图
    if (sender.numberOfTapsRequired == 1) {
        
        [self ImageReductionClose];
    }
    
    //双击---放大或还原
    else if (sender.numberOfTapsRequired == 2)
    {
        if (_scrollerView.zoomScale > _proportionFloat)  {
            [_scrollerView setZoomScale:_proportionFloat animated:YES];
        }
        else {
            //双击坐标相对屏幕坐标
            CGPoint point = [sender locationInView:self];
            //放大图片
            [self enlargeImage:point];
        }
    }
}

//图片还原关闭(带动画效果)
- (void)ImageReductionClose {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        //背景图透明
        [_scrollerView setBackgroundColor:[UIColor clearColor]];
        
        //还原缩放比例
        _scrollerView.zoomScale = _proportionFloat;
        
        //还原图片初始框架
        CGRect ARect = _showImageView.frame;
        
        ARect.origin.x = _imageOriginalRect.origin.x - _leverlFloat;
        
        ARect.origin.y = _imageOriginalRect.origin.y - _verticalFloat;
        
        ARect.size.width = _imageOriginalRect.size.width;
        
        ARect.size.height = _imageOriginalRect.size.height;
        
        _showImageView.frame = ARect;
        
        [UIView commitAnimations];
        
    } completion:^(BOOL finished) {
        
        [_showImageView removeFromSuperview];
        
        _showImageView = nil;
        
        [_scrollerView removeFromSuperview];
        
        _scrollerView = nil;
        
        [self removeFromSuperview];
    }];
}

/*
 *作用：放大图片
 *参数：
 *      ponint  双击点相对屏幕坐标
 */
- (void)enlargeImage:(CGPoint)ponint {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_scrollerView setZoomScale:_scrollerView.maximumZoomScale];
    }];
    
    //相对边距坐标
    CGPoint APanNextPoint =  CGPointMake((ponint.x - _leverlFloat), (ponint.y - _verticalFloat));
    
    //滚动视图真实偏移坐标
    CGPoint AOffsetPoint = _scrollerView.contentOffset;
    
    if (_showImageView.image.size.height * _proportionFloat * _scrollerView.maximumZoomScale > self.frame.size.height)
    {
        CGFloat Y = APanNextPoint.y * _scrollerView.zoomScale / _proportionFloat - _showImageView.center.y;
        
        AOffsetPoint.y = AOffsetPoint.y + Y;
        
        CGFloat AMaxContentHeight= _scrollerView.contentSize.height - CGRectGetHeight(_scrollerView.frame);
        
        AOffsetPoint.y = AOffsetPoint.y < AMaxContentHeight ? AOffsetPoint.y : AMaxContentHeight;
        
        AOffsetPoint.y = AOffsetPoint.y > 0 ? AOffsetPoint.y : 0;
    }
    
    if (_showImageView.image.size.width * _proportionFloat * _scrollerView.maximumZoomScale > self.frame.size.width)
    {
        CGFloat X = (APanNextPoint.x * _scrollerView.zoomScale / _proportionFloat - _showImageView.center.x);
        
        AOffsetPoint.x = AOffsetPoint.x + X;
        
        CGFloat AMaxContentWidth= _scrollerView.contentSize.width - CGRectGetWidth(_scrollerView.frame);
        
        AOffsetPoint.x = AOffsetPoint.x < AMaxContentWidth ? AOffsetPoint.x : AMaxContentWidth;
        
        AOffsetPoint.x = AOffsetPoint.x > 0 ? AOffsetPoint.x : 0;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        [_scrollerView setContentOffset:AOffsetPoint];
    }];
}


#pragma mark - UICollectionViewDelegate
//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _showImageView;
}

//缩放时调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    if (scrollView.zoomScale < _proportionFloat) {
        
        [_showImageView setCenter:self.center];
        
        CGRect ARect = _showImageView.frame;
        
        ARect.origin.x = ARect.origin.x - _leverlFloat;
        
        ARect.origin.y = ARect.origin.y - _verticalFloat;
        
        _showImageView.frame = ARect;
    }
    else if (scrollView.zoomScale == _proportionFloat) {
        
        [_showImageView setCenter:self.center];
        
        CGRect ARect = _showImageView.frame;
        
        ARect.origin.x = 0;
        
        ARect.origin.y = 0;
        
        _showImageView.frame = ARect;
    }
    
    //初始化边距
    [self initMargin];
}

//初始化边距
- (void)initMargin {
    
    //水平边距
    _leverlFloat = (self.frame.size.width - _showImageView.image.size.width * _scrollerView.zoomScale)  / 2.0;
    if (_leverlFloat < 0) {
        
        _leverlFloat = 0;
    }
    
    //垂直边距
    _verticalFloat = (CGRectGetHeight(self.frame) - _showImageView.image.size.height * _scrollerView.zoomScale) / 2.0;
    if (_verticalFloat < 0) {
        
        _verticalFloat = 0;
    }
    
    //设置边距
    [_scrollerView setContentInset:UIEdgeInsetsMake(_verticalFloat, _leverlFloat, _verticalFloat, _leverlFloat)];
}

#pragma mark - 自定义共有方法
//显示图片
- (void)showBigImage:(UIImageView *)imageView {
    //添加显示视图
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    
    //初始化图片显示视图
    [self initImageView:imageView];
    
    //图片适应居中显示(带动画)
    [self ImageAdaptCenter];
}

#pragma mark - 自定义私有方法
//初始化显示图片
- (void)initImageView:(UIImageView *)imageView {
    
    //保存图片原始框架————相对屏幕位置
    {
        _imageOriginalRect = imageView.bounds;
        
        _imageOriginalRect.origin = [imageView convertPoint:CGPointMake(0, 0) toView:[[UIApplication sharedApplication] keyWindow]];
    }
    
    //计算默认缩放比例
    {
        CGSize AImageSize = imageView.image.size;
        
        _proportionFloat = CGRectGetHeight(self.frame) / AImageSize.height;
        
        if (AImageSize.width * _proportionFloat > CGRectGetWidth(self.frame)) {
            
            _proportionFloat = CGRectGetWidth(self.frame) / AImageSize.width;
        }
    }
    
    //初始化图片视图
    {
        [_showImageView setImage:imageView.image];
        
        [_showImageView setFrame:_imageOriginalRect];
    }
}

//图片适应居中(带动画效果)
- (void)ImageAdaptCenter {
    
    [UIView animateWithDuration:0.4 animations:^{
        
        [_scrollerView setBackgroundColor:[UIColor blackColor]];
        
        CGRect ARect = _showImageView.frame;
        
        ARect.size.width = _showImageView.image.size.width * _proportionFloat;
        
        ARect.size.height = _showImageView.image.size.height * _proportionFloat;
        
        _showImageView.frame = ARect;
        
        _showImageView.center = self.center;
        
        
    } completion:^(BOOL finished) {
        
        [_showImageView setFrame:CGRectMake(0, 0, _showImageView.image.size.width, _showImageView.image.size.height)];
        
        //初始化缩放比例
        [self initScaling];
        
        //初始化边距
        [self initMargin];
    }];
}

//初始化缩放比例
- (void)initScaling {
    
    //设置主要滚动视图滚动范围和缩放比例
    [_scrollerView setContentSize:_showImageView.image.size];
    
    //设置最小伸缩比例
    [_scrollerView setMinimumZoomScale:_proportionFloat];
    
    //设置最大伸缩比例
    [_scrollerView setMaximumZoomScale:_proportionFloat * 3];
    
    //默认缩放比例
    [_scrollerView setZoomScale:_proportionFloat];
    
     
}

@end
