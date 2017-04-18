//
//  MyDownloadUtility.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/29.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "MyDownloadUtility.h"

@implementation MyDownloadUtility

+ (NSString *)calculateFileSizeAndUnit:(int64_t)contentLength
{
    float totalSize = 0.0;
    NSString *sizeUnit = @"";
    if(contentLength >= pow(1024, 3))
    {
        totalSize = (float) (contentLength / (float)pow(1024, 3));
        sizeUnit = @"GB";
    }
    else if(contentLength >= pow(1024, 2))
    {
        totalSize = (float) (contentLength / (float)pow(1024, 2));
        sizeUnit = @"MB";
    }
    else if(contentLength >= 1024)
    {
        totalSize = (float) (contentLength / (float)1024);
        sizeUnit = @"KB";
    }
    else
    {
        totalSize = (float) (contentLength);
        sizeUnit = @"Bytes";
    }

    return  [NSString stringWithFormat:@"%.2f%@",totalSize, sizeUnit];
}


+ (NSString *)renameDownLoadFileWithFileName:(NSString *)fileName filePath:(NSString *)filePath fileManager:(NSFileManager *)fileManager {
    
    NSInteger i = 1;
    NSString *newName = fileName;
    while ([fileManager fileExistsAtPath:[filePath stringByAppendingPathComponent:newName]]) {
        NSString *lastName = [fileName pathExtension];
        NSString *firstName = [fileName stringByDeletingPathExtension];
        firstName = [NSString stringWithFormat:@"%@(%zi)",firstName,i];
        newName = [firstName stringByAppendingPathExtension:lastName];
        i++;
    }
    return newName;
}

@end
