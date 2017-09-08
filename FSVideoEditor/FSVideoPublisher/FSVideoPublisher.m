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
    
    CGFloat _uploadProgress;
}

@property(nonatomic,strong)FSVideoPublishParam *currentParam;
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

// 发布 视频文件
-(void)publishVideo:(FSVideoPublishParam *)param{

    self.currentParam = param;
    _uploadProgress = 0.0;
    
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
    dispatch_group_async(_group, _uploadLogoVideoQueue, ^{
        [_uploadVideo uploadFileWithFilePath:param.videoPath complete:^(CGFloat progress, NSString *filePath, NSDictionary *info) {
            if (info) {
                _nologoVideoUrl = [info objectForKey:@"dataInfo"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _uploadProgress += 0.2;
                    if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
                        [self.delegate videoPublisherProgress:_uploadProgress];
                    }
                });
            }
            dispatch_group_leave(_group);
        }];
    });
    
    dispatch_group_enter(_group);
    dispatch_group_async(_group, _uploadNologoVideoQueue, ^{
        [_uploadLogoVideo uploadFileWithFilePath:param.videoPathWithLogo complete:^(CGFloat progress, NSString *filePath, NSDictionary *info) {
            if (info) {
                _logoVideoUrl = [info objectForKey:@"dataInfo"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    _uploadProgress += 0.2;
                    if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
                        [self.delegate videoPublisherProgress:_uploadProgress];
                    }
                });
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
    });
}

- (void)FSUploadImageServerFirstImageSucceed:(NSString *)filePath {
    _firstImageUrl = filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        _uploadProgress += 0.2;

        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:_uploadProgress];
        }
    });
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerFirstImageFailed:(NSError *)error {
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerWebPSucceed:(NSString *)filePath {
    _webpUrl = filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        _uploadProgress += 0.2;
        if ([self.delegate respondsToSelector:@selector(videoPublisherProgress:)]) {
            [self.delegate videoPublisherProgress:_uploadProgress];
        }
    });
    dispatch_group_leave(_group);
}

- (void)FSUploadImageServerWebPFailed:(NSError *)error {
    dispatch_group_leave(_group);
}

- (void)FSPublisherServerSucceed {
    
    NSLog(@"完成发布视频: -----");

    if ([self.delegate respondsToSelector:@selector(videoPublisherSuccess)]) {
        [self.delegate videoPublisherSuccess];
    }
    self.currentParam = nil;
}

- (void)FSPublisherServerFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(videoPublisherFaild)]) {
        [self.delegate videoPublisherFaild];
    }    
}
// 杀应用 要删除一下file
-(void)terminate{
    if (self.currentParam) {
        [[FSDraftManager sharedManager] delete:self.currentParam.draftInfo];
    }
}
@end
