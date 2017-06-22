//
//  FSLocalVideoController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalVideoController.h"
#import "FSLocalPhotoManager.h"
#import "FSUploader.h"
#import "FSFileSliceDivider.h"

@interface FSLocalVideoController ()<FSUploaderDelegate>
{
    FSLocalPhotoManager *_manager;
    FSUploader *_uploader;
}
@property(nonatomic,strong)FSVideoListView *videoListView;
@end

@implementation FSLocalVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     _manager = [FSLocalPhotoManager new];
    NSArray *assets = [_manager photosWithType:(PHAssetMediaTypeVideo)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
     _videoListView = [[FSVideoListView alloc] initWithFrame:self.view.bounds];
    [_videoListView setDelegate:self];
    [_videoListView setVideos:assets];
    [self.view addSubview:_videoListView];
    
     FSFileSliceDivider *divider = [[FSFileSliceDivider alloc] initWithSliceCount:1];
     _uploader = [FSUploader uploaderWithDivider:divider];
    [_uploader setDelegate:self];
}
#pragma mark - 
-(void)videoListView:(FSVideoListView *)videoListView didSelectedVideo:(PHAsset *)video{
    
    PHVideoRequestOptions *videoOption = [PHVideoRequestOptions new];
    
    __weak typeof(self) weakS = self;
    [[PHImageManager defaultManager] requestAVAssetForVideo:video options:videoOption resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        NSString *tokenKey = [info valueForKey:@"PHImageFileSandboxExtensionTokenKey"];
        NSArray *tokenS = [tokenKey componentsSeparatedByString:@";"];
        NSString *filePath = [tokenS lastObject];
        
        NSString *localFilePath = [weakS saveVideoFileToCache:filePath];
        
        [weakS uploadFile:localFilePath];
    }];
    
}
- (NSString *)saveVideoFileToCache:(NSString *)filePath{
    NSData *videoData = [NSData dataWithContentsOfFile:filePath];
    NSLog(@"fileSize %ld",videoData.length);
    NSString *localFilePath = NSTemporaryDirectory();
    localFilePath = [localFilePath stringByAppendingPathComponent:[filePath lastPathComponent]];
    [videoData writeToFile:localFilePath atomically:YES];
    return localFilePath;
}

- (void)uploadFile:(NSString *)filePath{
    NSLog(@"filePath %@",filePath);
    [_uploader uploadFileWithFilePath:filePath];
}
-(void)uploadUpFiles:(NSString *)filePath progress:(float)progress{
    NSLog(@"progress %.2f",progress);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
