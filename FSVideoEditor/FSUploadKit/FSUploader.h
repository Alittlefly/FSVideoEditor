//
//  FSUploader.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileUploader.h"
#import "FSFileSliceDivider.h"


@protocol FSUploaderDelegate <NSObject>
-(void)uploadUpFiles:(NSString *)filePath progress:(float)progress;
@end

@interface FSUploader : NSObject
@property(nonatomic,assign)id<FSUploaderDelegate>delegate;

+(instancetype)new NS_UNAVAILABLE;
-(instancetype)init NS_UNAVAILABLE;

// 默认使用size divider
+(instancetype)defaultUploader;
//
+(instancetype)uploaderWithDivider:(FSFileDivider *)divider;

-(void)uploadFileWithFile:(FSFile *)file;
-(void)uploadFileWithFilePath:(NSString *)filePath;

-(void)uploadFileProgressWithFilePath:(NSString *)filePath complete:(void(^)(float progress,NSString *filePath))complete;
-(void)uploadFilesWithState:(FSFileUpLoadState)state complete:(void(^)(NSArray<FSFile *> *files))complete;
-(void)uploadFileInfoWith:(NSString *)filePath complete:(void(^)(FSFile *file))complete;
- (void)uploadFileWithFilePath:(NSString *)filePath complete:(FSUploadProgressBlock)complete;

@end
