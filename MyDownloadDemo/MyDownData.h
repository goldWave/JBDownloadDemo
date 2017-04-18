//
//  MyDownData.h
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/28.
//  Copyright © 2017年 naver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYBaseDesriptionModel.h"

typedef NS_ENUM(NSInteger, MyDownStatus) {
    MyDownStatusRepare,
    MyDownStatusDoing,
    MyDownStatusPause,
    MyDownStatusSuccess,
    MyDownStatusFail
};

@interface MyDownData : LYBaseDesriptionModel <NSCoding>

@property (nonatomic) NSString * identifier;
@property (nonatomic) int64_t currentSize;
@property (nonatomic) int64_t  totalSize;
@property (nonatomic) MyDownStatus status;
@property (nonatomic) double progress;
@property (nonatomic) NSString * name;
@property (nonatomic) BOOL isFromDisk;
@property (nonatomic) NSString *downLoadPath;

@property (nonatomic) NSURLSessionDataTask *downTask;
@property (nonatomic)   NSOutputStream *outStream;


@end
