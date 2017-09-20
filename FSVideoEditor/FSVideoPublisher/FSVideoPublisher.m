//
//  FSVideoPublisher.m
//  FSVideoEditor
//
//  Created by Charles on 2017/9/8.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoPublisher.h"
#import "FSDraftFileManager.h"
#import "FSUploadImageServer.h"
#import "FSUploader.h"
#import "FSPublisherServer.h"
#import "FSPublishSingleton.h"
#import "FSDraftManager.h"
#import "FSVideoEditorCommenData.h"


@implementation FSVideoPublishParam

@end


@interface FSVideoPublisher()<FSUploadImageServerDelegate,FSPublisherServerDelegate>
{
    dispatch_group_t _group;
    dispatch_queue_t _uploadImageQueue;
    dispatch_queue_t _uploadWebpQueue;
    dispatch_queue_t _uploadLogoVideoQueue;
    dispatch_queue_t _uploadNologoVideoQueue;

    
    FSUploadImageServer *_uploadImageSever;
    FSUploadImageServer *_uploadWebpSever;
    FSPublisherServer *_publishServer;
    FSUploader *_uploadVideo;
    FSUploader *_uploadLogoVideo;
    
    NSString *_firstImageUrl;
    NSString *_webpUrl;
    NSString *_logoVideoUrl;
    NSString *_nologoVideoUrl;
    
   // CGFloat _uploadProgress;
    
    long long _totalFileSize;
    float _firstImageUploadSize;
    float _webpUploadSize;
    float _videoUploadSize;
    float _videoLogoUploadSize;
}

@property(nonatomic,strong)FSVideoPublishParam *currentParam;
@property(nonatomic, assign) long long totalUploadSize;

@end

@implementation FSVideoPublisher
+(instancetype)sharedPublisher{
    return [[FSVideoPublisher alloc] init];
}
-(instancetype)init{
    static id object = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if ((object = [super init]) != nil) {
            _group = dispatch_group_create();
            _uploadImageQueue = dispatch_queue_create("fission.Videologo.upload", 0);
            _uploadWebpQueue = dispatch_queue_create("fission.VideoWebp.upload", 0);
            _uploadLogoVideoQueue = dispatch_queue_create("fission.Videoimage.upload", 0);
            _uploadNologoVideoQueue = dispatch_queue_create("fission.nologoVideo.upload", 0);
            _publishServer = [[FSPublisherServer alloc] init];
            _publishServer.delegate = self;
            _uploadImageSever = [[FSUploadImageServer alloc] init];
            [_uploadImageSever setDelegate:self];
            
            _uploadWebpSever = [[FSUploadImageServer alloc] init];
            [_uploadWebpSever setDelegate:self];
            
            _uploadVideo = [FSUploader uploaderWithDivider:[[FSFileSliceDivider alloc] initWithSliceCount:1]];
            _uploadLogoVideo = [FSUploader uploaderWithDivider:[[FSFileSliceDivider alloc] initWithSliceCount:1]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(terminate) name:UIApplicationWillTerminateNotification object:nil];
            
        }
    });
    return object;
}

- (long long)totalUploadSize {
    return _firstImageUploadSize+_webpUploadSize+_videoUploadSize+_videoLogoUploadSize;
}

- (unsigned long long)fileSize:(NSString*)filePath
{
    // 总大小
    unsigned long long size = 0;
    NSString *sizeText = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:filePath isDirectory:&isDir];
    
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:filePath];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [filePath stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
            
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:filePath error:nil].fileSize;
    }
    return size;
}


// 发布 视频文件
-(void)publishVideo:(FSVideoPublishParam *)param{

    self.currentParam = param;
   // _uploadProgress = 0.5;
    
    _firstImageUploadSize = 0;
    _webpUploadSize = 0;
    _videoUploadSize = 0;
    _videoLogoUploadSize = 0;
    
    _totalFileSize = [UIImageJPEGRepresentation(param.firstImageData,1) length]/1024;
    _totalFileSize += [self fileSize:param.webpPath];
    long long videoSize = [self fileSize:param.videoPath];

    _totalFileSize += videoSize;
    long long videoLogoSize = [self fileSize:param.videoPathWithLogo];
    _totalFileSize += videoLogoSize;

    
    
    
    dispatch_group_enter(_group);
    dispatch_group_async(_group, _uploadImageQueue, ^{
        NSData * imageData = UIImageJPEGRepresentation(param.firstImageData,1);
        CGFloat length = [imageData length]/1024;
        CGFloat bit = 1;
        if (length > 200) {
            bit = 200/length;
        }
        NSString *lastPath = [param.draftInfo.vFinalPath lastPathComponent];
        NSString *imageName = [[lastPath stringByDeletingPathExtension] stringByAppendingString:@".jpg"];
        [_uploadImageSever uploadFirstImage:[NSDictionary dictionaryWithObjectsAndKeys:UIImageJPEGRepresentation(param.firstImageData,bit),@"imageData",imageName,@"imageName",nil]];
    });
    
    
    dispatch_group_enter(_group);
    dispatch_group_async(_group, _uploadWebpQueue, ^{
        NSData *data = [NSData dataWithContentsOfFile:param.webpPath];
        NSString *name = [[param.draftInfo.vFinalPath lastPathComponent] stringByDeletingPathExtension];
        NSString *webpName = [name stringByAppendingString:@".webp"];
        [_uploadWebpSever uploadWebP:[NSDictionary dictionaryWithObjectsAndKeys:data,@"webpData",webpName,@"webpName",nil]];
    });
    
    dispatch_group_enter(_group);
    dispatch_group_async(_group,_uploadNologoVideoQueue, ^{
        [_uploadVideo uploadFileWithFilePath:param.videoPath progress:^(CGFloat progress, NSString *filePath, NSDictionary *info) {
            NSLog(@"_uploadVideo uploadFileWithFilePath %.2f",progress);
            _videoUploadSize = progress * videoSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
                    [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];                   }
            });
        } complete:^(FSFileSlice *file, BOOL success, NSDictionary *info) {

            if (info) {
                _nologoVideoUrl = [info objectForKey:@"dataInfo"];
            }
            dispatch_group_leave(_group);
        }];
    });
    
    dispatch_group_enter(_group);
    dispatch_group_async(_group, _uploadLogoVideoQueue, ^{
        [_uploadLogoVideo uploadFileWithFilePath:param.videoPathWithLogo progress:^(CGFloat progress, NSString *filePath, NSDictionary *info) {
            _videoLogoUploadSize = progress * videoLogoSize;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
                    [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];                   }
            });
        } complete:^(FSFileSlice *file, BOOL success, NSDictionary *info) {
            
            if (info) {
                _logoVideoUrl = [info objectForKey:@"dataInfo"];
            }
            dispatch_group_leave(_group);
        }];
    });
    
    
    dispatch_group_notify(_group, dispatch_get_main_queue(), ^{
        if (!_firstImageUrl || !_webpUrl || !_logoVideoUrl || !_nologoVideoUrl) {
                // 发布失败
            self.currentParam = nil;

            if ([self.delegate respondsToSelector:@selector(videoPublisherFaild)]) {
                [self.delegate videoPublisherFaild];
            }
          
        }else{
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
            [dic setValue:[NSNumber numberWithInt:4] forKey:@"requestType"];
            [dic setValue:_logoVideoUrl?:@"" forKey:@"lvu"];
            [dic setValue:_nologoVideoUrl?:@"" forKey:@"vu"];
            [dic setValue:_firstImageUrl?:@"" forKey:@"vp"];    //image
            [dic setValue:_webpUrl?:@"" forKey:@"vg"];   //webp
            [dic setValue:[FSPublishSingleton sharedInstance].loginKey forKey:@"loginKey"];
            [dic setValue:[[FSDraftManager  sharedManager] tempInfo].vTitle?:@"" forKey:@"vd"]; //
            [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].vMusic.mId) forKey:@"si"]; //歌曲id
            [dic setValue:@([[FSDraftManager  sharedManager] tempInfo].challenge.challengeId) forKey:@"di"];  //挑战ID
            [dic setValue:[NSArray array] forKey:@"a"];
            [_publishServer publisherVideo:dic];
        }
        
        _firstImageUrl = nil;
        _webpUrl = nil;
        _firstImageUrl = nil;
        _nologoVideoUrl = nil;
    });
}

- (void)FSUploadImageServerFirstImageSucceed:(NSString *)filePath {
    _firstImageUrl = filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];
        }
    });
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerFirstImageFailed:(NSError *)error {
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerFirstImageProgress:(float)progess {
    _firstImageUploadSize = progess;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"---- uploadProgress 1  %lld  %lld",self.totalUploadSize,_totalFileSize);

        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];
        }
    });
}

- (void)FSUploadImageServerWebPSucceed:(NSString *)filePath {
    _webpUrl = filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        //_uploadProgress += 0.1;
        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];
        }
    });
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerWebPFailed:(NSError *)error {
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerWebPProgress:(float)progess {
    _webpUploadSize = progess;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"---- uploadProgress 2  %lld  %lld",self.totalUploadSize,_totalFileSize);
        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:(((double)self.totalUploadSize/(double)_totalFileSize) * 100.0)/100.0];
        }
    });
}

- (void)FSPublisherServerSucceed {
    
    NSLog(@"完成发布视频: -----");
    if ([self.delegate respondsToSelector:@selector(videoPublisherSuccess)]) {
        [self.delegate videoPublisherSuccess];
    }
    self.currentParam = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoPublished object:nil];
}

- (void)FSPublisherServerFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(videoPublisherFaild)]) {
        [self.delegate videoPublisherFaild];
    }    
}

- (void)FSPublisherServerProgress:(long long)progress {

}


// 杀应用 要删除一下file
-(void)terminate{
    if (self.currentParam) {
        [[FSDraftManager sharedManager] delete:self.currentParam.draftInfo];
    }
}
@end
