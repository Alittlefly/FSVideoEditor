//
//  FSFileUploadChecker.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploadChecker.h"
#import "FSFileSlice.h"
#import "FSUploadCache.h"


@implementation FSFileUploadChecker
+(FSFileUpLoadState)fileUploadCheckerCheckState:(NSString *)filePath{
    float progress = [FSFileUploadChecker fileUploadCheckerCheckProgress:filePath];
    if (progress == 0) {
        return FSFileUpLoadStateWait;
    }else if (progress == 1.0){
        return FSFileUpLoadStateFinish;
    }
    return FSFileUpLoadStateProcessing;
}
+(float )fileUploadCheckerCheckProgress:(NSString *)filePath{
    return [FSUploadCache fileUploadProgress:filePath];
}
+(NSArray <FSFileSlice *>*)fileUploadCheckerGetUnUploadRanges:(NSString *)filePath{
    NSArray *files = [FSUploadCache fileUploadCache:filePath];
    return files;
}
+(float )fileUploadCheckUploadSuccess:(FSFileSlice *)file filePath:(NSString *)filePath{
    
    [FSUploadCache fileUploadSuccess:file cacheKey:filePath];
    float progress = [FSUploadCache fileUploadProgress:filePath];
    if (progress == 1.0) {
        // 上传完成
        [FSUploadCache fileUploadCacheComplete:filePath];
    }
    
    
    
    return progress;
}

+(void)fileUploadCheckerSaveFiles:(NSArray <FSFileSlice *>*)files filePath:(NSString *)filePath{
    [FSUploadCache fileUploadCache:filePath cacheDatas:files];
}

// TODO:

/*
+(void)fileUploadCheckerAddWaitingUploadFile:(FSFile *)file{
    NSDictionary *waitfiles = [FSUploadCache fileUploadCacheGetWaitingFiles];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:waitfiles];
    NSAssert(file.filePath, @"key 不能为空");
    [dict setObject:file forKey:file.filePath];
    [FSFileUploadCache fileUploadCacheUpdateWaitingFile:dict];
}

+(NSArray *)fileUploadCheckerCheckFilesWithState:(FSFileUpLoadState)state{
    switch (state) {
        case FSFileUpLoadStateWait:
            return [[FSFileUploadCache fileUploadCacheGetWaitingFiles] allValues];
            break;
        case FSFileUpLoadStateProcessing:
            return [[FSFileUploadCache fileUploadCacheGetProcessingFiles] allValues];
        case FSFileUpLoadStateFinish:
            return [[FSFileUploadCache fileUploadCacheGetFinishedFiles] allValues];
        default:
            break;
    }
}
+(FSFile *)fileUploadCheckerCheckInfoWithFilePath:(NSString *)filePath{
    NSDictionary *allFile = [FSFileUploadCache fileUploadCacheGetAllFiles];
    FSFile *file = [allFile objectForKey:filePath];
    return file;
}
 */

@end
