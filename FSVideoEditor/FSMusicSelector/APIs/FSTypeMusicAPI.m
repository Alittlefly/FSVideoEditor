//
//  FSTypeMusicAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSTypeMusicAPI.h"
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"
#import "FSPublishSingleton.h"

@interface FSTypeMusicAPI ()
{
    NSURLSessionTask *_currentTask;
}
@end

@implementation FSTypeMusicAPI
-(void)getTypeMusics:(NSInteger)type page:(NSInteger)page{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self) weakS = self;
    NSURLSessionTask *task = [manager GET:[NSString stringWithFormat:@"%@video/song/use/%ld?no=%ld&size=20",AddressAPI,(long)type,page] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        
        NSLog(@"response object %@",responseObject);
        
        if ([weakS.delegate respondsToSelector:@selector(typeMusicApiGetMusics:)]) {
            [weakS.delegate typeMusicApiGetMusics:(NSDictionary *)responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(typeMusicApiGetFaild)]){
            [weakS.delegate typeMusicApiGetFaild];
        }
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}
@end
