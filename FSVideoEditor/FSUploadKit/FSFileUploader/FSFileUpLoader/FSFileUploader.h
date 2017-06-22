//
//  FSFileUploader.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "FSFileSizeDivider.h"
#import "FSFileUploadChecker.h"

@protocol FSFileUploaderProtocol <NSObject>
// 停止上传
-(void)uploadFileStopUploadFile:(NSString *)filePath;
// 取消上传
-(void)uploadFileCancleUploadFile:(NSString *)filePath;
// 接着上传
-(void)uploadFileResumeUploadFile:(NSString *)filePath;

@optional
// 无回调的上传 用在不需要展示上传进度场景
-(void)uploadFile:(NSData *)data file:(FSFileSlice *)file;
// 有回调的上传 用在
-(void)uploadFile:(NSData *)data file:(FSFileSlice *)file completeBlock:(void (^)(FSFileSlice *file,BOOL success))completecomplete;

@end


@class FSFileUploader;
@protocol FSFileUploaderDelegate <NSObject>

@optional
-(id<FSFileUploaderProtocol>)fileUploaderWillUploadFilePath:(NSString *)filePath file:(FSFileSlice *)file fileData:(NSData *)fileData;

-(void)fileUploadUploaded:(NSString *)filePath progress:(float)progress uploader:(FSFileUploader *)uploader;
@end


@interface FSFileUploader : NSObject

@property(nonatomic,assign)id<FSFileUploaderDelegate>delegate;

+(instancetype)defaultUploader;
+(instancetype)uploaderWithDivider:(FSFileDivider *)divider;

-(void)uploadFileWithFile:(FSFile *)file;
-(void)uploadFileWithFilePath:(NSString *)filePath;
-(void)uploadFileWithFilePath:(NSString *)filePath completeBlock:(void(^)(CGFloat progress,NSString *filePath))complete;

-(void)uploadFileStopUpload:(NSString *)filePath;
-(void)uploadFileResumeUpload:(NSString *)filePath;
-(void)uploadFileCancleUpload:(NSString *)filePath;

-(void)uploadFileStopAllUpload;
-(void)uploadFileResumeAllUpload;

-(void)uploaderProgressWithFilePath:(NSString *)filePath completeQueue:(dispatch_queue_t )queue  complete:(void(^)(float progress,NSString *filePath))complete;
-(void)uploaderWithState:(FSFileUpLoadState)state completeQueue:(dispatch_queue_t )queue  complete:(void(^)(NSArray<FSFile *> *files))complete;
-(void)uploaderInfoWithFilePath :(NSString *)filePath completeQueue:(dispatch_queue_t )queue complete:(void(^)(FSFile *file))complete;
@end
