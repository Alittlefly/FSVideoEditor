//
//  FSFileUploadTool.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/15.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploadTool.h"

@interface FSFileUploadTool ()
{
    NSURLSessionUploadTask *_uploadTask;
    NSOperationQueue *_operationQueue;
}
@end

@implementation FSFileUploadTool
-(instancetype)initWithData:(NSData *)data file:(FSFileSlice *)file filePath:(NSString *)filePath{
    if (self = [super init]) {
        _data = data;
        _file = file;
        _filePath = filePath;
        
        _operationQueue = [[NSOperationQueue alloc] init];
    }
    return self;
}
-(void)uploadFile:(NSData *)data file:(FSFileSlice *)file{
    [self uploadFile:data file:file completeBlock:nil];
}
-(void)uploadFile:(NSData *)data
             file:(FSFileSlice *)file
    completeBlock:(void (^)(FSFileSlice *file,BOOL success))complete{
    
    if (!_file) {
        _file = file;
    }
    
    if (!_data) {
        _data = data;
    }
    
    NSMutableURLRequest *customUrl = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self requestUrl]]];
    [customUrl setHTTPMethod:@"POST"];
    NSDictionary *requestHeader = [self requestHeaderFieldValueDictionaryFile:file];
    for (NSString *key in requestHeader) {
        [customUrl setValue:[requestHeader valueForKey:key] forHTTPHeaderField:key];
    }
    [customUrl setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    [customUrl setHTTPBody:data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 设置超时
    configuration.timeoutIntervalForRequest = 5.0f;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionUploadTask *uploadTask = [session uploadTaskWithRequest:customUrl fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

        BOOL success = NO;
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger code = httpResponse.statusCode;
        if (code == 200) {
            success = YES;
        }
        
        if (complete) {
            complete(file,success);
        }
    }];
    [uploadTask resume];
    _uploadTask = uploadTask;
}
-(void)uploadFileStopUploadFile:(NSString *)filePath{
    if (_uploadTask) {
        
        NSURLSessionTaskState state = _uploadTask.state;
        if (state == NSURLSessionTaskStateCompleted || state == NSURLSessionTaskStateSuspended) {
            return;
        }
        
        if (state == NSURLSessionTaskStateRunning || state == NSURLSessionTaskStateCanceling) {
            [_uploadTask suspend];
            return;
        }
    }
}
-(void)uploadFileCancleUploadFile:(NSString *)filePath{
    if (_uploadTask) {
        
        NSURLSessionTaskState state = _uploadTask.state;
        if (state == NSURLSessionTaskStateCompleted || state == NSURLSessionTaskStateCanceling) {
            return;
        }
        
        if (state == NSURLSessionTaskStateRunning || state == NSURLSessionTaskStateSuspended) {
            [_uploadTask cancel];
            return;
        }
    }
}
-(void)uploadFileResumeUploadFile:(NSString *)filePath{
    if (_uploadTask) {
        
        NSURLSessionTaskState state = _uploadTask.state;
        if (state == NSURLSessionTaskStateRunning || state == NSURLSessionTaskStateCompleted ) {
            return;
        }
        if (state ==  NSURLSessionTaskStateCanceling || state == NSURLSessionTaskStateSuspended) {
            [_uploadTask resume];
            return;
        }
    }
}

- (NSString *)requestUrl {
    NSString *name = _file.fileName;
//    NSLog(@"uploadName %@",name);
//    http://10.10.32.145:8086/files/shortvideo/upload/file
    NSString *url = @"http://10.10.32.145:8086/files/shortvideo/upload/file";// [@"http://221.176.30.232:8888/file/" stringByAppendingString:name];
    return url;
}

-(NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionaryFile:(FSFileSlice *)file{
    NSString *rangeString = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)file.fileRange.location,(file.fileRange.location + file.fileRange.length)];
    NSString *size = [NSString stringWithFormat:@"%ld",(long)file.totalSize];
//    NSLog(@"post range:%@ totalSize:%@",rangeString,size);
    
    return @{
             @"Content-Type":@"application/octet-stream",
             @"x-fission-range":rangeString,
             @"x-fission-length":size
             };
}

@end
