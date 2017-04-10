//
//  MLCustomSheet.h
//  Medicine
//
//  Created by Visoport on 20/12/16.
//  Copyright © 2016年 Visoport. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MLCustomSheetDelegate <NSObject>

-(void)clickButton:(NSUInteger)buttonTag sheetCount:(NSUInteger)sheet;

@end

@interface MLCustomSheet : UIView


@property (nonatomic,weak) id<MLCustomSheetDelegate>delegate;

@property (nonatomic, assign) NSInteger sheetMark;


-(MLCustomSheet*)initWithButtons:(NSArray*)allButtons isTableView:(BOOL)tableView;

@end
