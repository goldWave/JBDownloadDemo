//
//  MyDownTableCellView.h
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/27.
//  Copyright © 2017年 naver. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@protocol MyDownTableCellViewDelegate <NSObject>

- (void)pauseBtnDidClickedWithData:(MyDownData *)downData;
- (void)resumeBtnDidClickedWithData:(MyDownData *)downData;
- (void)deleteBtnDidClickedWithData:(MyDownData *)downData;

@end

@interface MyDownTableCellView : NSTableCellView

@property (nonatomic) MyDownData *data;

@property (nonatomic, weak) id<MyDownTableCellViewDelegate>delegate;

@end
