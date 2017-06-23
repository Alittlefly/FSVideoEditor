//
//  FSFileUploader.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploader.h"

#import "FSFileUploadTool.h"
#import "FSFileUploadChecker.h"

@interface FSFileUploader(){
    FSFileDivider *_divider;
    dispatch_queue_t _uploadQueue;
}
@property(nonatomic,strong)NSMutableDictionary *uploadOperaters;
@end

@implementation FSFileUploader
-(instancetype)init{
    if (self = [super init]) {
        _uploadQueue = dispatch_queue_create("fileUpload.fission.queue", 0);
        _divider = [FSFileSizeDivider divider];
    }
    return self;
}
-(instancetype)initWithDivider:(FSFileDivider *)divider{
    if (self = [super init]) {
        _uploadQueue = dispatch_queue_create("fileUpload.fission.queue", 0);
        _divider = divider;
    }
    return self;
}
-(void)uploadFileWithFile:(FSFile *)file{
    [self uploadFileWithFile:file completeBlock:nil];
}
-(void)uploadFileWithFile:(FSFile *)file completeBlock:(FSUploadProgressBlock)complete{
    dispatch_async(_uploadQueue, ^{
        // 存储file
//          [FSFileUploadChecker fileUploadCheckerAddWaitingUploadFile:file];
        // 传文件
        [self uploadFileWithPath:file.filePath completBlock:complete];
    });
}
-(void)uploadFileWithFilePath:(NSString *)filePath{
    [self uploadFileWithFilePath:filePath completeBlock:nil];
}
-(void)uploadFileWithFilePath:(NSString *)filePath completeBlock:(FSUploadProgressBlock)complete{
    dispatch_async(_uploadQueue, ^{
        [self uploadFileWithPath:filePath completBlock:complete];
    });
}
-(void)uploadFileWithPath:(NSString *)filePath completBlock:(FSUploadProgressBlock)complete{
    //1.检查上传文件的状态
    FSFileUpLoadState state = [FSFileUploadChecker fileUploadCheckerCheckState:filePath];
    //1).上传剩余没上传的文件
    if (state == FSFileUpLoadStateProcessing) {
        NSLog(@"该文件正在上传中");
        NSArray *files = [FSFileUploadChecker fileUploadCheckerGetUnUploadRanges:filePath];
        [self uploadFileWithFileData:files filePath:filePath completeBlock:complete];
    }else if(state == FSFileUpLoadStateFinish){
        // 2.已经完成上传
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                complete(1.0,filePath,nil);
            });
        }

        NSLog(@"该文件已完成上传");
    }else{
        NSLog(@"该文件开始上传");
        //2.没有记录
        if([_divider respondsToSelector:@selector(fileDividerDeviderWithFilePath:)]){
            NSArray *dividedFiles = [_divider fileDividerDeviderWithFilePath:filePath];
            [self uploadFileWithFileData:dividedFiles filePath:filePath completeBlock:complete];
        }else{
            [self uploadWithFilePath:filePath completeBlock:complete];
        }
    }
}
-(void)uploadFileWithFileData:(NSArray<FSFileSlice *> *)fileDatas filePath:(NSString *)filePath completeBlock:(FSUploadProgressBlock)complete{
    NSFileHandle *handler = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    [FSFileUploadChecker fileUploadCheckerSaveFiles:fileDatas filePath:filePath];
    
    NSMutableArray *ops = [NSMutableArray array];
    
    __weak typeof(self) weakSelf = self;
    for (FSFileSlice *file in fileDatas) {
        [handler seekToFileOffset:file.fileRange.location];
        NSData *postData = [handler readDataOfLength:file.fileSize];
        if ([self.delegate respondsToSelector:@selector(fileUploaderWillUploadFilePath:file:fileData:)]) {
            id<FSFileUploaderProtocol> op = [self.delegate fileUploaderWillUploadFilePath:filePath file:file fileData:postData];
            [op uploadFile:postData file:file completeBlock:^(FSFileSlice *file, BOOL success,id info) {
                //
                if (success) {
                    dispatch_async(_uploadQueue, ^{
                        
                        if (complete) {
                            
                            float cprogress = [FSFileUploadChecker fileUploadCheckUploadSuccess:file filePath:filePath];

                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                if ([weakSelf.delegate respondsToSelector:@selector(fileUploadUploaded:progress:uploader:)]) {
                                    [weakSelf.delegate fileUploadUploaded:filePath progress:cprogress uploader:weakSelf];
                                }
                                complete(cprogress,filePath,info);
                            });
                            
                            NSLog(@"success:当前的上传进度是 %.2f",cprogress);
                        }
                    });
                }else{
                    //
                    // test
//                    float cprogress = [FSFileUploadChecker fileUploadCheckUploadSuccess:file filePath:filePath];

                    NSLog(@" test faild :当前的上传进度是 %.2f",1.0);
                }
            }];
            
            [ops addObject:op];
        }
    }
    [self.uploadOperaters setValue:ops forKey:filePath];
}
-(void)uploadWithFilePath:(NSString *)filePath completeBlock:(FSUploadProgressBlock)complete{
    NSFileHandle *handler = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *postData = [handler readDataToEndOfFile];
    FSFileSlice *file = [FSFileSlice fileWithfilePath:filePath];
    
    [FSFileUploadChecker fileUploadCheckerSaveFiles:@[file] filePath:filePath];

    __weak typeof(self) weakSelf = self;
    if ([self.delegate respondsToSelector:@selector(fileUploaderWillUploadFilePath:file:fileData:)]) {
        id<FSFileUploaderProtocol> op = [self.delegate fileUploaderWillUploadFilePath:filePath file:file fileData:postData];
        [op uploadFile:postData file:file completeBlock:^(FSFileSlice *file, BOOL success,id info) {
            //
            dispatch_async(_uploadQueue, ^{
                float cprogress = [FSFileUploadChecker fileUploadCheckUploadSuccess:file filePath:filePath];
                if (complete) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if ([weakSelf.delegate respondsToSelector:@selector(fileUploadUploaded:progress:uploader:)]) {
                            [weakSelf.delegate fileUploadUploaded:filePath progress:cprogress uploader:weakSelf];
                        }
                        
                        complete(cprogress,filePath,info);
                    });
                }
            });
        }];
    }
}
-(void)uploadFileStopUpload:(NSString *)filePath{
    NSArray *operters = [self.uploadOperaters valueForKey:filePath];
    for (id<FSFileUploaderProtocol> op in operters) {
        if ([op respondsToSelector:@selector(uploadFileStopUploadFile:)]) {
            [op uploadFileStopUploadFile:filePath];
        }
    }

}
-(void)uploadFileResumeUpload:(NSString *)filePath{
    NSArray *operters = [self.uploadOperaters valueForKey:filePath];
    for (id<FSFileUploaderProtocol> op in operters) {
        if ([op respondsToSelector:@selector(uploadFileResumeUploadFile:)]) {
            [op uploadFileResumeUploadFile:filePath];
        }
    }
}
-(void)uploadFileCancleUpload:(NSString *)filePath{
    NSArray *operters = [self.uploadOperaters valueForKey:filePath];
    for (id<FSFileUploaderProtocol> op in operters) {
        if ([op respondsToSelector:@selector(uploadFileCancleUploadFile:)]) {
            [op uploadFileCancleUploadFile:filePath];
        }
    }
}
-(void)uploadFileStopAllUpload{
    NSArray *keys = [self.uploadOperaters allKeys];
    for (NSString *filePathKey in keys) {
        [self uploadFileStopUpload:filePathKey];
    }
}
-(void)uploadFileResumeAllUpload{
    NSArray *keys = [self.uploadOperaters allKeys];
    for (NSString *filePathKey in keys) {
        [self uploadFileResumeUpload:filePathKey];
    }
}
-(void)uploaderProgressWithFilePath:(NSString *)filePath completeQueue:(dispatch_queue_t )queue  complete:(void(^)(float progress,NSString *filePath))complete{
    NSAssert(queue, @"queue can not be null");
    dispatch_async(_uploadQueue, ^{
        float progress = [FSFileUploadChecker fileUploadCheckerCheckProgress:filePath];
        if (complete) {
            dispatch_async(queue, ^{
                complete(progress,filePath);
            });
        }
    });
}

// TODO:


-(void)uploaderWithState:(FSFileUpLoadState)state completeQueue:(dispatch_queue_t )queue  complete:(void(^)(NSArray<FSFile *> *files))complete{
    NSAssert(queue, @"queue can not be null");
    dispatch_async(_uploadQueue, ^{
//        NSArray *files = [FSFileUploadChecker fileUploadCheckerCheckFilesWithState:state];
//        if (complete) {
//            dispatch_async(queue, ^{
//                complete(files);
//            });
//        }
        
    });
}
-(void)uploaderInfoWithFilePath:(NSString *)filePath completeQueue:(dispatch_queue_t )queue  complete:(void(^)(FSFile *file))complete{
    NSAssert(queue, @"queue can not be null");
    dispatch_async(_uploadQueue, ^{
//        FSFile *file = [FSFileUploadChecker fileUploadCheckerCheckInfoWithFilePath:filePath];
//        if (complete) {
//            dispatch_async(queue, ^{
//                complete(file);
//            });
//        }
    });
}
/* */

-(NSMutableDictionary *)uploadOperaters{
    if (!_uploadOperaters) {
        _uploadOperaters = [NSMutableDictionary dictionary];
    }
    return _uploadOperaters;
}
+(instancetype)defaultUploader{
    return [[FSFileUploader alloc] init];
}
+(instancetype)uploaderWithDivider:(FSFileDivider *)divider{
    return [[FSFileUploader alloc] initWithDivider:divider];
}

@end
