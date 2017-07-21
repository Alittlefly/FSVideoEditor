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
    
    NSArray *keys = [param allKeys];
    NSData * imageData = [param objectForKey:@"imageData"];//[UIImage imageWithContentsOfFile:[param objectForKey:@"image"]];//[param objectForKey:[keys firstObject]];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    CGFloat length = [imageData length]/1000;

    __weak typeof(self) weakS = self;

    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //    NSDictionary *param = @{@"file":data};
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
    [dic setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"loginKey"] forKey:@"loginKey"];
    [dic setValue:[NSNumber numberWithInteger:4] forKey:@"requestType"];
    NSURLSessionTask *task = (NSURLSessionUploadTask *)[mgr  POST:[NSString stringWithFormat:@"%@files/shortvideo/upload/image",AddressUpload] parameters:dic constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:[NSString stringWithFormat:@"%@.jpeg",@"test1"] mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIFirstImageSuccess:)]) {
            [weakS.delegate FSUploadImageAPIFirstImageSuccess:[responseObject objectForKey:@"dataInfo"]];
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
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    //http://10.10.32.145:8088/video/index/publish/video  http://www.7nujoom.com/
    NSURLSessionTask *task = [manager POST:[NSString stringWithFormat:@"%@video/index/publish/gif",AddressAPI] parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([weakS.delegate respondsToSelector:@selector(FSUploadImageAPIWebPSuccess:)]) {
            [weakS.delegate FSUploadImageAPIWebPSuccess:[responseObject objectForKey:@"dataInfo"]];
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
