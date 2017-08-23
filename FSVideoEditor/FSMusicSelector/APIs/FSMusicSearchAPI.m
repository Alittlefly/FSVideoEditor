//
//  FSMusicSearchAPI.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/28.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicSearchAPI.h"
#import "FSVideoEditorCommenData.h"
#import "AFNetworking.h"
#import "FSVideoEditorAPIParams.h"
#import "FSPublishSingleton.h"

@implementation FSMusicSearchAPI
-(void)searchMusicWithText:(NSString *)text no:(NSInteger)no{
    if (_currentTask) {
        [_currentTask suspend];
        [_currentTask cancel];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *params = [NSDictionary dictionaryWithDictionary:[FSVideoEditorAPIParams videoEdiorParams].params];
    __weak typeof(self) weakS = self;
    NSString *url = [NSString stringWithFormat:@"%@video/song/search?no=%ld&size=20&w=%@",AddressAPI,(long)no,text];
    NSURLSessionTask *task = [manager GET:[url stringByAddingPercentEscapesUsingEncoding:(NSUTF8StringEncoding)] parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"search %@",responseObject);
        if ([weakS.delegate respondsToSelector:@selector(musicSearchAPISearchSuccess:)]) {
            [weakS.delegate musicSearchAPISearchSuccess:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([weakS.delegate respondsToSelector:@selector(musicSearchAPISearchFaild)]) {
            [weakS.delegate musicSearchAPISearchFaild];
        }
    }];
    
    [task resume];
    _currentTask = task;
}
-(void)cancleTask{
    [_currentTask cancel];
}

@end
