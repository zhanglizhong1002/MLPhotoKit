//
//  MLCustomSheet.m
//  Medicine
//
//  Created by Visoport on 20/12/16.
//  Copyright © 2016年 Visoport. All rights reserved.
//

#import "MLCustomSheet.h"


@interface MLCustomSheet()

@property (nonatomic,strong) UIView * contentView;

@end

@implementation MLCustomSheet

static NSArray * allbus = nil;


-(MLCustomSheet*)initWithButtons:(NSArray*)allButtons isTableView:(BOOL)tableView
{
    allbus = allButtons;
    
    CGFloat startHeight = 0;
    if (tableView) {
        startHeight = -64;
    }
    MLCustomSheet * sheet = [[MLCustomSheet alloc]initWithFrame:CGRectMake(0, startHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [sheet set];
    return sheet;
    
}

-(void)set
{
    [UIView animateWithDuration:0.5 animations:^{
        _contentView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44*allbus.count-50, [UIScreen mainScreen].bounds.size.width, 44*allbus.count+50);
    }];
    
}



-(instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame])
    {
        UIView *back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        back.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
        [self addSubview:back];
        
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height,  [UIScreen mainScreen].bounds.size.width,44*allbus.count+50)];
        [self addSubview:_contentView];
        for (int i = 0; i<allbus.count; i++)
        {
            UIButton * bu = [UIButton buttonWithType:UIButtonTypeCustom];
            bu.tag = i;
            bu.backgroundColor = [UIColor whiteColor];
            bu.frame = CGRectMake(0, 44*i, [UIScreen mainScreen].bounds.size.width, 44);
            [_contentView addSubview:bu];
            [bu setTitle:allbus[i] forState:UIControlStateNormal];
            [bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [bu addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
            UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 43, [UIScreen mainScreen].bounds.size.width, 1)];
            line.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
            [bu addSubview:line];
        }
        UIButton * bu = [UIButton buttonWithType:UIButtonTypeCustom];
        bu.backgroundColor = [UIColor whiteColor];
        [bu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        bu.frame = CGRectMake(0, 44*allbus.count+6, [UIScreen mainScreen].bounds.size.width, 44);
        [bu setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [bu addTarget:self action:@selector(touchesBegan:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:bu];
        
    }
    return self;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self cancelButtonAction];
}
-(void)clickButton:(UIButton*)button
{
    [self.delegate  clickButton:button.tag sheetCount:self.sheetMark];
    
    [self removeFromSuperview];
}
-(void)cancelButtonAction
{
    
    [UIView animateWithDuration:0.3 animations:^{
        _contentView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 44*allbus.count+50);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
        [self.delegate  clickButton:999 sheetCount:self.sheetMark];
    }];
}

@end
