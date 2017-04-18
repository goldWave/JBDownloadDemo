//
//  MyDownloadManager.m
//  MyDownloadDemo
//
//  Created by jimbo on 2017/3/28.
//  Copyright © 2017年 naver. All rights reserved.
//

#import "MyDownloadManager.h"

@interface MyDownloadManager () <NSURLSessionDataDelegate>
{
    // 输出流
    NSOperationQueue *_queue;
    
    NSFileManager *_fileManager;
}

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *plistPath;

@end

@implementation MyDownloadManager

+ (MyDownloadManager *)manager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _fileManager = [[NSFileManager alloc] init];
    //    [self codeingTest];
    return self;
}


#pragma mark - urlsession

- (void)downBySandboxWithData:(MyDownData *)downData {
    
    //new task
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downData.identifier]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", downData.currentSize];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    //create request
    downData.downTask = [self.session dataTaskWithRequest:request];
    
    downData.status = MyDownStatusRepare;
    
    [downData.downTask  resume];
    
}

- (void)addDownloadWithUrlStr:(NSString *)urlStr {
    //new task
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MyDownData *data = [[MyDownData alloc] init];
    @synchronized (self) {
        [self.downDatas addObject:data];
    }
    //create request
    data.downTask = [self.session dataTaskWithRequest:request];
    
    //[_myData removeAllObjects];
    data.identifier = urlStr;
    data.progress = 0;
    data.status = MyDownStatusRepare;
    
    data.downLoadPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"111"];
    
    [data.downTask resume];
    
}

#pragma mark - NSURLSession Data Task delegate

//收到服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    for (int i = 0; i < _downDatas.count; i ++) {
        MyDownData *downData = _downDatas[i];
        //TODO or identifier
        if (![dataTask isEqual:downData.downTask]) {
            continue ;
        }
        if (downData.totalSize <= 0) downData.totalSize = response.expectedContentLength;
        downData.name = response.suggestedFilename;
        
        [self renameDownLoadFileWithData:downData];
        
        NSString *fullPath = [downData.downLoadPath stringByAppendingPathComponent:downData.name];
        
        NSLog(@"%@", fullPath);
        
        downData.outStream = [[NSOutputStream alloc] initToFileAtPath:fullPath append:YES]; //append ?
        
        //打开输出流
        [downData.outStream open];
        
        
        downData.status = MyDownStatusDoing;
        
        
        if (self.delegate) {
            [self.delegate reloadRowWithIndex:i];
        }
        [self wirteToSandboxPlist];
        //是否要接收响应
        completionHandler(NSURLSessionResponseAllow);
        break ;
    }
}

//收到数据，可能返回多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    //    NSLog(@"didReceiveData");
    for (int i = 0; i < _downDatas.count; i ++) {
        MyDownData *downData = _downDatas[i];
        //TODO or identifier
        if (![dataTask isEqual:downData.downTask]) {
            continue ;
        }
        [downData.outStream write:data.bytes maxLength:data.length];
        
        //累加下载文件
        downData.currentSize = data.length + downData.currentSize;
        downData.progress = 1.0 * downData.currentSize / downData.totalSize;
        if (self.delegate) {
            [self.delegate reloadRowWithIndex:i];
        }
        break ;
    }
    
}

//请求结束，如果错误，error != nil
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    
#warning NSURLSessionTask VS NSURLSessionDataTask
    for (int i = 0; i < _downDatas.count; i ++) {
        MyDownData *downData = _downDatas[i];
        if (![task isEqual:downData.downTask]) {
            continue ;
        }
        [downData.outStream close];
        downData.outStream = nil;
        NSLog(@"didCompleteWithError");
        
        if (error) {
            downData.status = MyDownStatusFail;
        } else {
            downData.progress = 1;
            downData.status = MyDownStatusSuccess;
        }
        
        if (self.delegate) {
            [self.delegate reloadRowWithIndex:i];
        }
        [self wirteToSandboxPlist];
    }
}

- (void)wirteToSandboxPlist {
    //[_downDatas writeToFile:self.plistPath atomically:YES];
    
    @synchronized (self) {
        [NSKeyedArchiver archiveRootObject:self.downDatas toFile:self.plistPath];
    }
}

- (int64_t)caculateFileSizeWithPath:(NSString *)filePath {
    if (![_fileManager fileExistsAtPath:filePath]) return 0;
    return [[_fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

- (void)renameDownLoadFileWithData:(MyDownData *)downData  {
    
    NSInteger i = 1;
    NSString *goodName = downData.name;
    while ([_fileManager fileExistsAtPath:[downData.downLoadPath stringByAppendingPathComponent:goodName]]) {
        NSString *lastName = [goodName pathExtension];
        NSString *firstName = [goodName stringByDeletingPathExtension];
        firstName = [NSString stringWithFormat:@"%@(%zi)",firstName,i];
        goodName = [firstName stringByAppendingPathExtension:lastName];
        i++;
    }
    downData.name = goodName;
}




#pragma mark - lazy load

- (NSURLSession *)session {
    if (!_session) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 3;
        _session = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                    delegate:self
                    delegateQueue:_queue];
    }
    return  _session;
}


- (NSMutableArray *)downDatas {
    if (!_downDatas) {
        self.plistPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"111/downDatas.plist"];
        //_downDatas = [[NSMutableArray alloc] initWithContentsOfFile:self.plistPath];
        _downDatas = [NSKeyedUnarchiver unarchiveObjectWithFile:self.plistPath];
        
        for (MyDownData *data in _downDatas) {
            if (data.status != MyDownStatusSuccess) {
                data.status = MyDownStatusPause;
                data.currentSize = [self caculateFileSizeWithPath:[data.downLoadPath stringByAppendingPathComponent:data.name]];
                data.progress = 1.0 * data.currentSize / data.totalSize;
                
            }
            
            data.isFromDisk = YES;
        }
        if (!_downDatas) {
            _downDatas = [NSMutableArray array];
        }
        NSLog(@"_downDatas : %@", _downDatas);
    }
    return _downDatas;
}

@end
