//
//  MyDownTableCellView.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/27.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "MyDownTableCellView.h"

@interface MyDownTableCellView ()
@property (weak) IBOutlet NSView *view;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSButton *stopBtn;
@property (weak) IBOutlet NSTextField *statusTextFiled;
@property (weak) IBOutlet NSTextField *nameTextField;
@property (weak) IBOutlet NSTextField *totalDataTextField;
@property (weak) IBOutlet NSTextField *progressTextField;
@property (weak) IBOutlet NSProgressIndicator *progressIndictor;

@end


@implementation MyDownTableCellView

- (instancetype)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    
    [self _setUp];
    
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    [self _setUp];
    return self;
}

- (void)_setUp{
    if ([[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                      owner:self
                            topLevelObjects:nil]) {
        [self.view setFrame:self.bounds];
        
        self.view.autoresizingMask = kCALayerHeightSizable|kCALayerWidthSizable;
        [self addSubview:self.view];
        
        self.wantsLayer = YES;
    
        self.layer.backgroundColor = [[NSColor lightGrayColor] colorWithAlphaComponent:0.3].CGColor;
        
        self.layer.cornerRadius = 5;
        
        //self.startBtn.hidden = YES;
        //self.stopBtn.hidden = YES;
        
        
    }
}

- (void)setData:(MyDownData *)data {
    _data = data;
    
    self.nameTextField.stringValue = data.name ?: @"未命名";
    
    MyDownStatus status = data.status;
    NSString *statusName = @"";
    self.startBtn.hidden = YES;
    self.stopBtn.hidden = YES;
    switch (status) {
        case MyDownStatusRepare:
        {
            statusName = @"正在初始化";
            self.stopBtn.hidden = NO;
        }
            break;
        case MyDownStatusDoing:
        {
            statusName = @"下载中";
            self.stopBtn.hidden = NO;
        }
            break;
        case MyDownStatusPause:
        {
            statusName = @"已暂停";
           self.startBtn.hidden = NO;
        }
            break;
        case MyDownStatusSuccess:
        {
            statusName = @"下载完成";
        }
            break;
        case MyDownStatusFail:
        {
            statusName = @"下载失败";
            self.startBtn.hidden = NO;
        }
            break;
        default:
            break;
    }
    self.statusTextFiled.stringValue = statusName;
    
    NSString *totalUnit = data.totalSize ? [MyDownloadUtility calculateFileSizeAndUnit:data.totalSize] : @"- -";
    
    self.totalDataTextField.stringValue = totalUnit;
    
    self.progressTextField.stringValue = [NSString stringWithFormat:@"已下载:%.2f%%",data.progress * 100];
    
    [self.progressIndictor setDoubleValue:(data.progress * 100)];
    
}


- (IBAction)resumeBtnClick:(id)sender {
    if (self.delegate) {
        [self.delegate resumeBtnDidClickedWithData:_data];
    }
}
- (IBAction)stopBtnClick:(id)sender {
    if (self.delegate) {
        [self.delegate pauseBtnDidClickedWithData:_data];
    }
}
- (IBAction)deleteBtnClick:(id)sender {
    if (self.delegate) {
        [self.delegate deleteBtnDidClickedWithData:_data];
    }
}


@end
