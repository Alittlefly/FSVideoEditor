//
//  FSFileUploadChecker.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FSFileUpLoadState){
    FSFileUpLoadStateFinish = 0,
    FSFileUpLoadStateProcessing,
    FSFileUpLoadStateWait
};
@class FSFileSlice,FSFile;
@interface FSFileUploadChecker : NSObject
/**
 *
 *  获取当前文件的上传的进度
 *
 ****/
+(float )fileUploadCheckerCheckProgress:(NSString *)filePath;
/**
 *
 *  检查当前文件上传状态
 *
 ****/
+(FSFileUpLoadState)fileUploadCheckerCheckState:(NSString *)filePath;
/**
 *
 *  获取当前文件的上传的分片文件
 *
 *  状态可能是 有部分 可能全部 可能没有
 *
 ****/
+(NSArray <FSFileSlice *>*)fileUploadCheckerGetUnUploadRanges:(NSString *)filePath;
/**
 *
 *  更新当前sliceFile 的状态为上传成功
 *
 ****/
+(float )fileUploadCheckUploadSuccess:(FSFileSlice *)file filePath:(NSString *)filePath;
/**
 *
 *  讲要上传的分片记录到本地的cache中
 *
 ****/
+(void)fileUploadCheckerSaveFiles:(NSArray <FSFileSlice *>*)files filePath:(NSString *)filePath;


// TODO:
/**
 *
 *  添加等待上传的文件
 *
 ****/
//+(void)fileUploadCheckerAddWaitingUploadFile:(FSFile *)file;
/**
 *
 *  返回当前状态下的文件
 *
 ****/
//+(NSArray *)fileUploadCheckerCheckFilesWithState:(FSFileUpLoadState)state;
/**
 *
 *  文件信息
 *
 ****/
//+(FSFile *)fileUploadCheckerCheckInfoWithFilePath:(NSString *)filePath;

@end
