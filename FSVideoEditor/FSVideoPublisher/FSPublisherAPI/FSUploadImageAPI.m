//
//  FSUploadImageAPI.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSUploadImageAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"
#import "FSPublishSingleton.h"

@interface FSUploadImageAPI()
{
    NSURLSessionTask *_currentTask;
    
    NSURLSessionUploadTask *_uploadTask;

}

@end

@implementation FSUploadImageAPI

- (void)uploadFirstImage:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    NSData * imageData = [param objectForKey:@"imageData"];//[UIImage imageWithContentsOfFile:[param objectForKey:@"image"]];//[param objectForKey:[keys firstObject]];
    NSString *imageName = [param objectForKey:@"imageName"];
    
    __weak typeof(self) weakS = self;

    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //    NSDictionary *param = @{@"file":data};
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:[FSPublishSingleton sharedInstance].loginKey forKey:@"loginKey"];
    [dic setValue:[NSNumber numberWithInteger:4] forKey:@"requestType"];
    NSURLSessionTask *task = (NSURLSessionUploadTask *)[mgr  POST:[NSString stringWithFormat:@"%@files/shortvideo/upload/image",AddressUpload] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg",imageName] mimeType:@"image/*"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        if ( code== 0) {
            if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIFirstImageSuccess:)]) {
                [weakS.delegate FSUploadImageAPIFirstImageSuccess:[responseObject objectForKey:@"dataInfo"]];
            }
        }
        else {
            if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIFirstImageFaild:)]) {
                [weakS.delegate FSUploadImageAPIFirstImageFaild:nil];
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIFirstImageFaild:)]) {
            [weakS.delegate FSUploadImageAPIFirstImageFaild:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}

- (void)uploadWebP:(id)param {
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    NSArray *keys = [param allKeys];
    NSData * imageData = [param objectForKey:@"webpData"];//[UIImage imageWithContentsOfFile:[param objectForKey:@"image"]];//[param objectForKey:[keys firstObject]];
    NSString *imageName = [param objectForKey:@"webpName"];

    __weak typeof(self) weakS = self;
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //    NSDictionary *param = @{@"file":data};
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:[FSPublishSingleton sharedInstance].loginKey forKey:@"loginKey"];
    [dic setValue:[NSNumber numberWithInteger:4] forKey:@"requestType"];
    NSURLSessionTask *task = (NSURLSessionUploadTask *)[mgr  POST:[NSString stringWithFormat:@"%@files/shortvideo/upload/gif",AddressUpload] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:[NSString stringWithFormat:@"%@.webp",imageName] mimeType:@"image/webp"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        int code = [[responseObject objectForKey:@"code"] intValue];
        if ( code== 0) {
            if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIWebPSuccess:)]) {
                [weakS.delegate FSUploadImageAPIWebPSuccess:[responseObject objectForKey:@"dataInfo"]];
            }
        }
        else {
            if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIWebPFaild:)]) {
                [weakS.delegate FSUploadImageAPIWebPFaild:nil];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIWebPFaild:)]) {
            [weakS.delegate FSUploadImageAPIWebPFaild:error];
        }
    }];
    
    [task resume];
    _currentTask = task;
}

@end
