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

- (void)continueDownData:(MyDownData *)downData {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downData.identifier]];
    
    // 设置请求头 断点续传
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self caculateFileSizeWithPath:downData.downLoadPath]];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    //create request
    downData.downTask = [self.session dataTaskWithRequest:request];
    
    downData.status = MyDownStatusRepare;
    
    downData.isFromDisk = YES;
    
    [downData.downTask  resume];
    
}

- (void)addNewDownloadWithUrlStr:(NSString *)urlStr {
    //new task
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    
    MyDownData *data = [[MyDownData alloc] init];
    @synchronized (self) {
        [self.downDatas addObject:data];
    }
    //create request
    data.downTask = [self.session dataTaskWithRequest:request];
    
    data.identifier = urlStr;
    data.progress = 0;
    data.status = MyDownStatusRepare;
    data.isFromDisk = NO;
    
    
    data.downLoadPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download"];
    
    [data.downTask resume];
    
}
- (void)deleteDownData:(MyDownData *)downData {
#warning [downData.downTask cancel];
    @synchronized (self) {
        [_downDatas removeObject:downData];
        [downData.downTask cancel];
        [downData.outStream close];
        downData.outStream = nil;
        downData.downTask = nil;
        [self wirteToSandboxPlist];
    }
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
        
        //新添加的下载项目
        if (!downData.isFromDisk) {
            downData.name =  [MyDownloadUtility renameDownLoadFileWithFileName:response.suggestedFilename filePath:downData.downLoadPath fileManager:_fileManager];
            downData.downLoadPath = [downData.downLoadPath stringByAppendingPathComponent:downData.name];
        }
        
        
        downData.outStream = [[NSOutputStream alloc] initToFileAtPath:downData.downLoadPath append:YES]; //append ?
        
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
    
        
        if (error) {
            NSLog(@"error: %@", error);
            if (error.code == -999 || error.code == -1011) { //cancel  || timed out
                downData.status = MyDownStatusPause;
            } else {
                downData.status = MyDownStatusFail;
            }
        } else {
            downData.progress = 1;
            downData.status = MyDownStatusSuccess;
        }
        
        if (self.delegate) {
            [self.delegate reloadRowWithIndex:i];
        }
        
        [downData.outStream close];
        downData.outStream = nil;
        downData.downTask = nil;
        
        [self wirteToSandboxPlist];
    }
}

- (void)wirteToSandboxPlist {
    //@synchronized 结构所做的事情跟锁（lock）类似：它防止不同的线程同时执行同一段代码
    @synchronized (self) {
        [NSKeyedArchiver archiveRootObject:self.downDatas toFile:self.plistPath];
    }
}

- (int64_t)caculateFileSizeWithPath:(NSString *)filePath {
    if (![_fileManager fileExistsAtPath:filePath]) return 0;
    return [[_fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

#pragma mark - lazy load

- (NSURLSession *)session {
    if (!_session) {
#warning _queue VS [NSOperationQueue mainQueue] 
        //接收到通知的回调在哪个线程中调用，如果传mainQueue则通知在主线程回调，否则在子线程回调
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
        _session = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                    delegate:self
                    delegateQueue:_queue];
    }
    return  _session;
}


- (NSMutableArray *)downDatas {
    if (!_downDatas) {
        NSString *downPath = [[NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"download"];
        if (![_fileManager fileExistsAtPath:downPath]) {
            [_fileManager createDirectoryAtPath:downPath withIntermediateDirectories:YES attributes:nil
                                          error:nil];
        }
        self.plistPath = [downPath stringByAppendingPathComponent:@"downDatas.plist"];
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
