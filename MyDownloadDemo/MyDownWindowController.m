//
//  MyDownWindowController.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/27.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "MyDownWindowController.h"
#import "MyDownTableCellView.h"
#import "MyDownloadManager.h"

// https://yq.aliyun.com/articles/27455#
// https://dldir1.qq.com/music/clntupate/mac/QQMusic4.2.3Build02.dmg

// http://baobab.wdjcdn.com/1456117847747a_x264.mp4
// http://baobab.wdjcdn.com/14525705791193.mp4
// http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4



@interface MyDownWindowController () <NSTabViewDelegate, NSTableViewDataSource, MyDownTableCellViewDelegate, MyDownloadManagerDelegate>
{
    MyDownloadManager *_downVM;
}
@property (weak) IBOutlet NSTableView *downTableView;
@property (weak) IBOutlet NSTextField *downUrlTextField;
@property (weak) IBOutlet NSTextField *textField1;
@property (weak) IBOutlet NSTextField *textField2;
@property (weak) IBOutlet NSTextField *textField3;
@property (weak) IBOutlet NSTextField *textField4;

@end

@implementation MyDownWindowController

- (instancetype)init {
    self = [self initWithWindowNibName:NSStringFromClass([self class])];
    _downVM = [MyDownloadManager manager];
    _downVM.delegate = self;
    return self;
}



- (IBAction)addDownTask:(id)sender {
    [self addDownWithUrl:_downUrlTextField.stringValue];
    
}
- (IBAction)addDownClick1:(id)sender {
    [self addDownWithUrl:_textField1.stringValue];
}
- (IBAction)addDownClick2:(id)sender {
    [self addDownWithUrl:_textField2.stringValue];
}
- (IBAction)addDownClick3:(id)sender {
    [self addDownWithUrl:_textField3.stringValue];
}
- (IBAction)addDownClick4:(id)sender {
    [self addDownWithUrl:_textField4.stringValue];
}

- (void)addDownWithUrl:(NSString *)url {
    if ([url isEqualToString:@""]) {
        NSLog(@"   url 不能为空");
        return ;
    }
    for (MyDownData *data in _downVM.downDatas) {
        if ([data.identifier isEqualToString:url]) {
            NSLog(@"_downVM.downDatas  已经有值");
            return ;
        }
    }
    [_downVM addNewDownloadWithUrlStr:url];
    [self.downTableView  reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.downTableView.wantsLayer = YES;
    self.downTableView.backgroundColor = [NSColor clearColor];
}


#pragma mark - TableView

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if (!_downVM.downDatas || [_downVM.downDatas count] == 0) {
        return 0;
    }
    return _downVM.downDatas.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    static NSString *const downIdentifier = @"MyDownTableCellView";
    MyDownTableCellView *rowView = [tableView makeViewWithIdentifier:downIdentifier owner:self];
    rowView.delegate = self;
    rowView.data = _downVM.downDatas[row];
    return rowView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 100;
}

- (BOOL)selectionShouldChangeInTableView:(NSTableView *)tableView {
    return NO;
}


#pragma mark - MyDownTableCellView Delegate
- (void)pauseBtnDidClickedWithData:(MyDownData *)downData {
    [downData.downTask cancel];
    downData.status = MyDownStatusPause;
    [self.downTableView  reloadData];
    
}

- (void)resumeBtnDidClickedWithData:(MyDownData *)downData {
    if (downData.status == MyDownStatusPause || downData.status == MyDownStatusFail) {
        [_downVM continueDownData:downData];
        //downData.isFromDisk = NO;
        return ;
    }
    //[downData.downTask resume];
    //downData.status = MyDownStatusDoing;
    //[self.downTableView  reloadData];
}

- (void)deleteBtnDidClickedWithData:(MyDownData *)downData {
    for (int i = 0; i < _downVM.downDatas.count; i ++) {
        if (![_downVM.downDatas[i] isEqual:downData]) {
            continue;
        }
        [_downVM deleteDownData:downData];
        [self.downTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:i] withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideRight];
        
        break ;
    }
}

#pragma mark - MyDownloadManager Delegate

- (void)reloadRowWithIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.downTableView reloadData];
    });
}


@end
