//
//  FSLikedMusicAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLikedMusicAPI.h"
#import "FSVideoEditorAPIParams.h"
#import "FSPublishSingleton.h"

@implementation FSLikedMusicAPI
-(void)getCollectedMusics:(NSInteger)no{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = [NSDictionary dictionaryWithDictionary:[FSVideoEditorAPIParams videoEdiorParams].params];
    __weak typeof(self) weakS = self;
    NSLog(@"getCollectedMusics %d",no);
    NSURLSessionTask *task = [manager GET:[NSString stringWithFormat:@"%@video/song/fav?no=%ld&size=20",AddressAPI,no] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"getCollectedMusics %@",responseObject);
        NSLog(@"getCollectedMusics %@",params);
        if ([weakS.delegate respondsToSelector:@selector(likedMusicApigetMusics:)]) {
            [weakS.delegate likedMusicApigetMusics:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(likedMusicApiGetFaild)]) {
            [weakS.delegate likedMusicApiGetFaild];
        }
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}

@end
