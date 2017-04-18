//
//  MyDownData.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/28.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "MyDownData.h"

@implementation MyDownData

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeInt64:self.currentSize forKey:@"currentSize"];
    [aCoder encodeInt64:self.totalSize forKey:@"totalSize"];
    [aCoder encodeInteger:self.status forKey:@"status"];
    [aCoder encodeDouble:self.progress forKey:@"progress"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeBool:self.isFromDisk forKey:@"isFromDisk"];
    [aCoder encodeObject:self.downLoadPath forKey:@"downLoadPath"];
    
    //[aCoder encodeObject:self.downTask forKey:@"downTask"];
    //[aCoder encodeObject:self.outStream forKey:@"outStream"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.identifier = [aDecoder decodeObjectForKey:@"identifier"];
    self.currentSize = [aDecoder decodeInt64ForKey:@"currentSize"];
    self.totalSize = [aDecoder decodeInt64ForKey:@"totalSize"];
    self.status = (MyDownStatus )[aDecoder decodeIntegerForKey:@"status"];
    self.progress = [aDecoder decodeDoubleForKey:@"progress"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.isFromDisk = [aDecoder decodeBoolForKey:@"isFromDisk"];
    self.downLoadPath = [aDecoder decodeObjectForKey:@"downLoadPath"];
    
    //self.downTask = [aDecoder decodeObjectForKey:@"downTask"];
     //self.downTask = [aDecoder decodeObjectForKey:@"outStream"];
    return self;
}

@end
