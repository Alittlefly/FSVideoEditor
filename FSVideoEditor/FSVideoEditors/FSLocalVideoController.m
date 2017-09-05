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
#import "FSShortLanguage.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSLocalVideoController ()<FSLocalPhotoManagerDelegate>
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
    [_manager setDelegate:self];
    NSArray *assets = [_manager photosWithType:(PHAssetMediaTypeVideo)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
    if ([assets count] != 0) {
        _videoListView = [[FSVideoListView alloc] init];
        [_videoListView setDelegate:self];
        [_videoListView setVideos:assets];
        [self.view addSubview:_videoListView];
    }
    [self initCancleButton];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [_videoListView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 49)];
    
    [self.cancleButton setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
}
#pragma mark - 
-(void)videoListView:(FSVideoListView *)videoListView didSelectedVideo:(PHAsset *)video{
    
    if (video.duration < 3) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:[FSShortLanguage CustomLocalizedStringFromTable:@"leastTime"] preferredStyle:(UIAlertControllerStyleAlert)];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Confirm"] style:(UIAlertActionStyleCancel) handler:nil];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
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
}

-(void)localPhotoManager:(FSLocalPhotoManager *)manager authorizedStatus:(PHAuthorizationStatus)status{
    if (status != PHAuthorizationStatusAuthorized) {
        UILabel *notAuthoredLabel = [[UILabel alloc] init];
        [notAuthoredLabel setTextColor:FSHexRGB(0x999999)];
        [notAuthoredLabel setNumberOfLines:0];
        [notAuthoredLabel setFont:[UIFont systemFontOfSize:13.0]];
        [notAuthoredLabel setPreferredMaxLayoutWidth:255];
        [notAuthoredLabel setText:[FSShortLanguage CustomLocalizedStringFromTable:@"没有授权没有授权没有授权没有授权没有授权没有授权没有授权没有授权没有授权没有授权"]];
        [notAuthoredLabel sizeToFit];
        [self.view addSubview:notAuthoredLabel];
        [notAuthoredLabel setCenter:self.view.center];
    }
}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
