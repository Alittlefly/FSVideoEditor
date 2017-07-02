//
//  FSMusicManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicManager.h"
#import "AFNetworking.h"

@implementation FSMusicManager
+(void)downLoadMusic:(NSString *)filePath complete:(FSMusicDownLoadComplete)complete{

    NSString *realPath = [FSMusicManager musicPathWithFileName:filePath];
    BOOL exist = [FSMusicManager existWithFileName:realPath];
    if (!exist) {
        AFHTTPSessionManager *manger = [AFHTTPSessionManager manager];
        NSURL *url  = [NSURL URLWithString:filePath];
        NSURLSessionDownloadTask *down = [manger downloadTaskWithRequest:[NSURLRequest requestWithURL:url] progress:^(NSProgress * _Nonnull downloadProgress) {
            NSLog(@"downloadProgress %@",downloadProgress);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSString *cachePath  = [FSMusicManager musicPathWithFileName:response.suggestedFilename];
            return [NSURL fileURLWithPath:cachePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            NSLog(@"filePath %@",filePath);
            if (complete) {
                complete(filePath.relativePath,error);
            }
        }];
        
        [down resume];
    }else{
        if (complete) {
            complete(realPath,nil);
        }
    }
}
+(BOOL)existWithFileName:(NSString *)fileName{
    NSString *cachePath  = [FSMusicManager musicPathWithFileName:fileName];
    BOOL isDir = NO;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir];
    return exist;
}
+(NSString *)musicPathWithFileName:(NSString *)fileName{
    NSString *directoryPath = [FSMusicManager musicDirectoryPath];
    NSString *realName = [fileName lastPathComponent];
    return [directoryPath stringByAppendingPathComponent:realName];
}

+(NSString *)musicDirectoryPath{
    
    NSString *CachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *directoryPath = [CachePath stringByAppendingPathComponent:@"Musics"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    BOOL exist = [fileManager fileExistsAtPath:directoryPath isDirectory:&isDir];
    if (!exist) {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directoryPath;
}
@end
