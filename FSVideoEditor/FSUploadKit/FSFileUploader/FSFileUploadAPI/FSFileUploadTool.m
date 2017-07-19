//
//  FSFileUploadTool.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/15.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploadTool.h"
#import "AFNetworking.h"
#import "MJExtension.h"
#import "FSVideoEditorCommenData.h"

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
    completeBlock:(FSUploadCompleteBlock)complete{
    
    if (!_file) {
        _file = file;
    }
    
    NSLog(@"当前文件的大小是 %.2f Mb",file.totalSize/1024.0/1024.0);
    
    if (file.totalSize/1024.0/1024.0 > 5.0) {
        if (complete) {
            complete(file,NO,nil);
        }
        return;
    }
    
    if (!_data) {
        _data = data;
    }
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
//    NSDictionary *param = @{@"file":data};
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"loginKey"] forKey:@"loginKey"];
    [dic setValue:[NSNumber numberWithInteger:4] forKey:@"requestType"];

    _uploadTask = (NSURLSessionUploadTask *)[mgr  POST:[self requestUrl] parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:file.fileName mimeType:@"video/quicktime"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dict = nil;
        if ([responseObject isKindOfClass:[NSString class]]) {
            dict = [NSJSONSerialization JSONObjectWithData:[((NSString *)self) dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            dict = [NSJSONSerialization JSONObjectWithData:(NSData *)self options:kNilOptions error:nil];
        }else if([responseObject isKindOfClass:[NSDictionary class]]){
            dict = responseObject;
        }
        
        NSInteger code = [[responseObject valueForKey:@"code"] intValue];
        if (code == 0) {
            NSLog(@"上传成功");
            if (complete) {
                complete(file,YES,dict);
            }
        }else{
            if (complete) {
                complete(file,NO,dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (complete) {
            complete(file,NO,nil);
        }
    }];
    /*
    NSMutableURLRequest *customUrl = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self requestUrl]]];
    [customUrl setHTTPMethod:@"POST"];
    NSDictionary *requestHeader = [self requestHeaderFieldValueDictionaryFile:file];
    for (NSString *key in requestHeader) {
        [customUrl setValue:[requestHeader valueForKey:key] forHTTPHeaderField:key];
    }
//    [customUrl setValue:data forKey:@"file"];
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
            
            NSString *str = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)];
            
            NSLog(@"上传成功 %@",str);
        }
        
        if (complete) {
            complete(file,success);
        }
    }];
     */
//    [uploadTask resume];
//    _uploadTask = uploadTask;
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
//    NSString *name = _file.fileName;
//    NSLog(@"uploadName %@",name);
//    http://10.10.32.145:8086/files/shortvideo/upload/file
//    NSString *url = @"http://10.10.32.157:8086/files/shortvideo/upload/file";

    NSString *url = [NSString stringWithFormat:@"%@files/shortvideo/upload/file",AddressUpload];
    NSLog(@"url---: %@",url);
    //[@"http://221.176.30.232:8888/file/" stringByAppendingString:name];
    return url;
}

-(NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionaryFile:(FSFileSlice *)file{
    NSString *rangeString = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)file.fileRange.location,(file.fileRange.location + file.fileRange.length)];
    NSString *size = [NSString stringWithFormat:@"%ld",(long)file.totalSize];
//    NSLog(@"post range:%@ totalSize:%@",rangeString,size);
    
    return @{
             @"Content-Type":@"multipart/form-data",
             @"x-fission-range":rangeString,
             @"x-fission-length":size
             };
}

@end
