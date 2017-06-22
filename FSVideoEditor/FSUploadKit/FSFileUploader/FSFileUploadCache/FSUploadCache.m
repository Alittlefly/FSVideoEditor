//
//  FSUploadCache.m
//  FSUploadDemo
//
//  Created by Charles on 2017/5/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSUploadCache.h"
#import "FSDBUploadCache.h"
#import "FSFileUploadCache.h"

@implementation FSUploadCache
+(float )fileUploadProgress:(NSString *)cacheKey{
    return [FSDBUploadCache fileUploadProgress:cacheKey];
}
// 将要上传的文件片段
+(void)fileUploadCache:(NSString *)cacheKey cacheDatas:(NSArray *)cachedatas{
    [FSDBUploadCache fileUploadCache:cacheKey cacheDatas:cachedatas];
//    [FSFileUploadCache fileUploadCache:cacheKey cacheDatas:cachedatas];
}
+(void)fileUploadSuccess:(FSFileSlice *)fileSlice cacheKey:(NSString *)cacheKey{
    [FSDBUploadCache fileUploadSuccess:fileSlice cacheKey:cacheKey];
//   [FSFileUploadCache fileUploadSuccess:fileSlice cacheKey:cacheKey]
}
// 未上传的文件片段
+(NSArray *)fileUploadCache:(NSString *)cacheKey{
    return [FSDBUploadCache fileUploadCache:cacheKey];
//    return [FSFileUploadCache fileUploadCache:cacheKey];
}
// 将文件标记为已经完成上传
+(void)fileUploadCacheComplete:(NSString *)cacheKey{
    [FSDBUploadCache fileUploadCacheComplete:cacheKey];
//    [FSFileUploadCache fileUploadCacheComplete:cacheKey];
}
// 检查文件是否已经完成上传
+(BOOL)fileUploadIsCompleted:(NSString *)cacheKey{
    return [FSDBUploadCache fileUploadIsCompleted:cacheKey];
    return [FSFileUploadCache fileUploadIsCompleted:cacheKey];
}

@end
