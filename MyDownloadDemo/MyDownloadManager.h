//
//  MyDownloadManager.h
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/28.
//  Copyright © 2017年 naver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyDownTableCellView.h"

@protocol MyDownloadManagerDelegate <NSObject>

- (void)reloadRowWithIndex:(NSInteger )index;

@end


@interface MyDownloadManager : NSObject

@property (nonatomic) NSMutableArray <MyDownData *> *downDatas;

@property (nonatomic, weak) id<MyDownloadManagerDelegate>delegate;

+ (MyDownloadManager *)manager;

- (void)addNewDownloadWithUrlStr:(NSString *)urlStr;
- (void)continueDownData:(MyDownData *)downData;
- (void)deleteDownData:(MyDownData *)downData;

- (void)wirteToSandboxPlist;
@end
