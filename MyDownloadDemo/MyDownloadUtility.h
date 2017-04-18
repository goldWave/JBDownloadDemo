//
//  MyDownloadUtility.h
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/29.
//  Copyright © 2017年 naver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyDownloadUtility : NSObject

+ (NSString *)calculateFileSizeAndUnit:(int64_t)contentLength;

+ (NSString *)renameDownLoadFileWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileManager:(NSFileManager *)fileManager;

@end
