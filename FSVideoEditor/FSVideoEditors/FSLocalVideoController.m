//
//  FSLocalVideoController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalVideoController.h"
#import "FSLocalPhotoManager.h"
#import "FSLocalEditorController.h"

@interface FSLocalVideoController ()
{
    FSLocalPhotoManager *_manager;
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
}
#pragma mark - 
-(void)videoListView:(FSVideoListView *)videoListView didSelectedVideo:(PHAsset *)video{
    
    PHVideoRequestOptions *videoOption = [PHVideoRequestOptions new];
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:video options:videoOption resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {

        AVURLAsset *urlAsset = (AVURLAsset *)asset;
        dispatch_async(dispatch_get_main_queue(), ^{
            FSLocalEditorController *vc = [[FSLocalEditorController alloc] init];
            vc.filePath = urlAsset.URL.relativeString;
            [self.navigationController pushViewController:vc animated:YES];
        });
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
