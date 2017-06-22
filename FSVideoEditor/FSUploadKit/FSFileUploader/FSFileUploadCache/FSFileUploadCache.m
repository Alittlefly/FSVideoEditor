//
//  FSFileUploadCache.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploadCache.h"
#import "FSMD5Utils.h"
@implementation FSFileUploadCache
// 读取已完成的文档中是否包含该文件
+(BOOL)fileUploadIsCompleted:(NSString *)cacheKey{
    NSString *md5Key = [cacheKey lastPathComponent];
    NSString *fileName = [FSMD5Utils getmd5WithString:md5Key];
    NSString *completeFilePath = [FSFileUploadCache uploadCompletedFilesPath];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:completeFilePath];
    BOOL complete = [[dict valueForKey:fileName] boolValue];
    return complete;
}
// 完成上传 添加到已完成列表
+(void)fileUploadCacheComplete:(NSString *)cacheKey{
    // 删除列表
    [FSFileUploadCache fileRemovedCache:cacheKey];
    
    NSString *md5Key = [cacheKey lastPathComponent];
    NSString *fileName = [FSMD5Utils getmd5WithString:md5Key];
    NSString *completeFilePath = [FSFileUploadCache uploadCompletedFilesPath];
    NSMutableDictionary *dict = [NSKeyedUnarchiver unarchiveObjectWithFile:completeFilePath];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    [dict setValue:[NSNumber numberWithBool:YES] forKey:fileName];
    [NSKeyedArchiver archiveRootObject:dict toFile:completeFilePath];
}
// 存储数据
+(void)fileUploadCache:(NSString *)cacheKey cacheDatas:(NSArray *)cachedatas{
    NSAssert(cacheKey, @"cacheKey 不能为空");
    NSString *md5Key = [cacheKey lastPathComponent];
    NSString *fileName = [FSMD5Utils getmd5WithString:md5Key];
    NSString *filePath = [FSFileUploadCache fileSavedPath:fileName];
    BOOL success = [NSKeyedArchiver archiveRootObject:cachedatas toFile:filePath];
    if(success){
        NSLog(@"存储成功");
    }else{
        NSLog(@"存储不成功");
    }
    
}
// 删除当前cacheKey的文件
+(void)fileRemovedCache:(NSString *)cacheKey{
    NSString *md5Key = [cacheKey lastPathComponent];
    NSString *fileName = [FSMD5Utils getmd5WithString:md5Key];
    NSString *savedPath = [FSFileUploadCache fileSavedPath:fileName];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:savedPath]) {
        NSError *error;
        [manager removeItemAtPath:savedPath error:&error];
        if (error) {
            NSLog(@"移除失败了");
        }else{
            NSLog(@"移除成功");
        }
    }
}
+(void)fileUploadSuccess:(FSFileSlice *)fileSlice cacheKey:(NSString *)cacheKey{
    NSArray *files = [FSFileUploadCache fileUploadCache:cacheKey];
    NSMutableArray *shouldBe = [NSMutableArray array];
    for (FSFileSlice *sfile in files) {
        if (sfile.fileId != fileSlice.fileId) {
            [shouldBe addObject:sfile];
        }
    }
    [FSFileUploadCache fileUploadCache:cacheKey cacheDatas:shouldBe];
}
+(float)fileUploadProgress:(NSString *)cacheKey{
    NSArray *files = [FSFileUploadCache fileUploadCache:cacheKey];
    if(!files){
        BOOL complete = [FSFileUploadCache fileUploadIsCompleted:cacheKey];
        if (complete) {
            return 1.0;
        }else{
            return 0.0;
        }
    }else{
        float progress = 0;
        double total = 0;
        double lastTotal = 0;
        for (FSFileSlice *file in files) {
            total = file.totalSize;
            lastTotal += file.fileSize;
        }
        if (total != 0) {
            progress = 1 - lastTotal/total ;
            return progress;
        }else{
            NSAssert(total,@"文件大小出错了");
            return -1;
        }
    }
}
// 根据key 读取持久化的数据
// 要上传的文件片段
+(NSArray *)fileUploadCache:(NSString *)cacheKey{
    NSString *md5Key = [cacheKey lastPathComponent];
    NSString *fileName = [FSMD5Utils getmd5WithString:md5Key];
    NSString *filePath = [FSFileUploadCache fileSavedPath:fileName];
    NSArray *files = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    return files;
}
+(NSString *)fileNameWithFilePath:(NSString *)cacheKey{
    return [cacheKey stringByDeletingPathExtension];
}

+(NSString *)uploadCompletedFilesPath{
    NSString *path = [FSFileUploadCache fileSavedPath:@"completeFiles"];
    return path;
}
+(NSString *)fileSavedPath:(NSString *)fileName{
    return [FSFileUploadCache fileSavedPath:fileName directoryName:@"uploadCache"];
}


+(NSString *)fileSavedPath:(NSString *)fileName directoryName:(NSString *)dirName{
    NSString *home = NSHomeDirectory();
    NSString *docPath = [home stringByAppendingPathComponent:@"Documents"];
    NSString *UploadCachePath = dirName;
    NSString *dataPath = [docPath stringByAppendingPathComponent:UploadCachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectiory;
    if (![fileManager fileExistsAtPath:dataPath isDirectory:&isDirectiory]) {
        [fileManager createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:@{NSFileCreationDate:[NSDate date]} error:nil];
    }
    NSString *lastEntension = [NSString stringWithFormat:@"/%@.data",fileName];
    NSString *finalPath = [dataPath stringByAppendingString:lastEntension];
    return finalPath;
}
#pragma mark - 文件
+(NSString *)fileUploadHistoryPath:(NSString *)filePath{
    return [FSFileUploadCache fileSavedPath:filePath directoryName:@"UploadCacheFile"];
}
// 添加等待上传的文件
+(void)fileUploadCacheUpdateWaitingFile:(NSDictionary *)waitData{
    NSDictionary *dict = [FSFileUploadCache fileUploadCacheGetWaitingFiles];
}
// 获取等待上传的文件
+(NSDictionary *)fileUploadCacheGetWaitingFiles{
    return [NSDictionary dictionary];
}
// 获取已经上传完成的文件
+(NSDictionary *)fileUploadCacheGetFinishedFiles{
    return [NSDictionary dictionary];
}
// 获取正在处理中的文件
+(NSDictionary *)fileUploadCacheGetProcessingFiles{
    return [NSDictionary dictionary];
}
// 获取所有的文件的信息
+(NSDictionary *)fileUploadCacheGetAllFiles{
    return [NSDictionary dictionary];
}
@end
