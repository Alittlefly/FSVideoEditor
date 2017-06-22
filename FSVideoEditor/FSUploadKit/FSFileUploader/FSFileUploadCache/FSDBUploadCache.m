//
//  FSDBUploadCache.m
//  FSUploadDemo
//
//  Created by Charles on 2017/5/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDBUploadCache.h"
#import "FSFileUploadDBManager.h"

@implementation FSDBUploadCache
// 将要上传的文件片段
+(void)fileUploadCache:(NSString *)cacheKey cacheDatas:(NSArray *)cachedatas{
    [FSFileUploadDBManager insertWillUploadFiles:cacheKey files:cachedatas];
}
// 移除上传的文件片段
+(void)fileUploadSuccess:(FSFileSlice *)fileSlice cacheKey:(NSString *)cacheKey{
    [FSFileUploadDBManager fileUploadSuccessUpdate:fileSlice cacheKey:cacheKey];
}
// 要上传的文件片段
+(NSArray *)fileUploadCache:(NSString *)cacheKey{
    return [FSFileUploadDBManager unUploadFilesWithKey:cacheKey];
}
// 将文件标记为已经完成上传
+(void)fileUploadCacheComplete:(NSString *)cacheKey{
    [FSFileUploadDBManager insertCompleteInfo:cacheKey];
}
// 检查文件是否已经完成上传
+(BOOL)fileUploadIsCompleted:(NSString *)cacheKey{
    return [FSFileUploadDBManager fileUploadStateWithCacheKey:cacheKey];
}
+(float)fileUploadProgress:(NSString *)cacheKey{
    // 已完成的文件
    NSArray *files = [FSDBUploadCache fileUploadCache:cacheKey];
    if(!files){
        BOOL complete = [FSDBUploadCache fileUploadIsCompleted:cacheKey];
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
            progress = lastTotal/total ;
            return progress;
        }else{
            NSAssert(total,@"文件大小出错了");
            return -1;
        }
    }
}
@end
