//
//  FSUploader.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/16.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSUploader.h"
#import "FSFileUploadTool.h"

@interface FSUploader()<FSFileUploaderDelegate>
@property(nonatomic,strong)FSFileUploader *fileUploader;
@end

@implementation FSUploader
+(instancetype)defaultUploader{
    FSUploader *loader = [[self alloc] init];
    loader.fileUploader = [FSFileUploader defaultUploader];
    [loader.fileUploader setDelegate:loader];
    return loader;
}
-(void)uploadFileWithFile:(FSFile *)file{
    [_fileUploader uploadFileWithFile:file];
}
+(instancetype)uploaderWithDivider:(FSFileDivider *)divider;{
    FSUploader *loader = [[self alloc] init];
    loader.fileUploader = [FSFileUploader uploaderWithDivider:divider];
    [loader.fileUploader setDelegate:loader];
    return loader;
}

-(void)uploadFileWithFilePath:(NSString *)filePath{
    NSAssert(filePath, @"filePath 不能为空");
    [_fileUploader uploadFileWithFilePath:filePath];
}
-(void)uploadFileProgressWithFilePath:(NSString *)filePath complete:(void (^)(float, NSString *))complete{
    NSAssert(complete,@"回调不能为空");
    NSAssert(filePath,@"文件路径不能为空");
    [_fileUploader uploaderProgressWithFilePath:filePath completeQueue:dispatch_get_main_queue() complete:complete];
}
-(void)uploadFilesWithState:(FSFileUpLoadState)state complete:(void(^)(NSArray<FSFile *> *files))complete{
    NSAssert(complete, @"回调不能为空");
    [_fileUploader uploaderWithState:state completeQueue:dispatch_get_main_queue() complete:complete];
}
-(void)uploadFileInfoWith:(NSString *)filePath complete:(void(^)(FSFile *file))complete{
    NSAssert(complete,@"回调不能为空");
    NSAssert(filePath,@"文件路径不能为空");
    [_fileUploader uploaderInfoWithFilePath:filePath completeQueue:dispatch_get_main_queue() complete:complete];
}
#pragma mark - ew
-(id<FSFileUploaderProtocol>)fileUploaderWillUploadFilePath:(NSString *)filePath file:(FSFileSlice *)file fileData:(NSData *)fileData{
    return [[FSFileUploadTool alloc] initWithData:fileData file:file filePath:filePath];
}
-(void)fileUploadUploaded:(NSString *)filePath progress:(float)progress{
    NSLog(@"upload filePath %@ progress %f",filePath,progress);
    if ([self.delegate respondsToSelector:@selector(uploadUpFiles:progress:)]) {
        [self.delegate uploadUpFiles:filePath progress:progress];
    }
}
@end
