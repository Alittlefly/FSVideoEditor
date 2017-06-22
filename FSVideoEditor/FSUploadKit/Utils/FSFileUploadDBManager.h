//
//  FSFileUploadDBManager.h
//  FSUploadDemo
//
//  Created by Charles on 2017/5/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileSlice.h"

@interface FSFileUploadDBManager : NSObject<NSCopying>
+(FSFileUploadDBManager *)shareDBManager;

+(NSArray *)unUploadFilesWithKey:(NSString *)cacheKey;

+(void)insertWillUploadFiles:(NSString *)cacheKey files:(NSArray *)files;

+(void)insertCompleteInfo:(NSString *)cacheKey;

+(BOOL)fileUploadStateWithCacheKey:(NSString *)cacheKey;

+(void)fileUploadSuccessUpdate:(FSFileSlice *)slice cacheKey:(NSString *)cacheKey;

+(NSArray *)filesAnyUploadCompleted;
@end
