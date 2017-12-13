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
    [_manager photosWithType:(PHAssetMediaTypeVideo)];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _videoListView = [[FSVideoListView alloc] init];
    [_videoListView setDelegate:self];
    [self.view addSubview:_videoListView];
    [self initCancleButton];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    [_videoListView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 49)];
    
   // [self.cancleButton setFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 49, CGRectGetWidth(self.view.bounds), 49)];
}

- (void)enterEditView {
    [_videoListView enterEditView];
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

- (void)videoListViewDidChooseOneVideo {
    if ([self.delegate respondsToSelector:@selector(FSLocalVideoControllerDidChooseOneVideo)]) {
        [self.delegate FSLocalVideoControllerDidChooseOneVideo];
    }
}

- (void)enterSettingPage {
    [self clickLimitsOfAuthorityOpenButtonStatistics];
    
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)localPhotoManager:(FSLocalPhotoManager *)manager authorizedStatus:(PHAuthorizationStatus)status{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status != PHAuthorizationStatusAuthorized) {
            [_videoListView setHidden:YES];
            UILabel *notAuthoredLabel = [[UILabel alloc] init];
            [notAuthoredLabel setTextColor:FSHexRGB(0x999999)];
            [notAuthoredLabel setNumberOfLines:0];
            [notAuthoredLabel setFont:[UIFont systemFontOfSize:13.0]];
            [notAuthoredLabel setPreferredMaxLayoutWidth:255];
            NSString *text = [FSShortLanguage CustomLocalizedStringFromTable:@"notAuthored"];
            notAuthoredLabel.lineBreakMode = NSLineBreakByWordWrapping;
            [notAuthoredLabel setTextAlignment:(NSTextAlignmentCenter)];
            [notAuthoredLabel setText:text];
            [notAuthoredLabel setBackgroundColor:[UIColor clearColor]];
            CGRect labelSize = [text boundingRectWithSize:CGSizeMake(255, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13.0]} context:nil];
            [notAuthoredLabel setFrame:CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(labelSize))/2.0, (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(labelSize)-40-40)/2.0,CGRectGetWidth(labelSize), CGRectGetHeight(labelSize))];
            [self.view addSubview:notAuthoredLabel];
            
            UIButton *enterSettingView = [UIButton buttonWithType:UIButtonTypeCustom];
            enterSettingView.frame = CGRectMake((CGRectGetWidth(self.view.bounds)-150)/2, CGRectGetMaxY(notAuthoredLabel.frame)+40, 150, 40);
            enterSettingView.backgroundColor = FSHexRGB(0x0BC2C6);
            enterSettingView.layer.cornerRadius = 5;
            enterSettingView.layer.masksToBounds = YES;
            [enterSettingView setTitle:@"Open" forState:UIControlStateNormal];
            [enterSettingView setTitleColor:FSHexRGB(0xFFFFFF) forState:UIControlStateNormal];
            [enterSettingView addTarget:self action:@selector(enterSettingPage) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:enterSettingView];
        }
    });
}

-(void)localPhotoManager:(FSLocalPhotoManager *)manager localVideos:(NSArray*)assets{
    [_videoListView setHidden:NO];
    NSMutableArray *videoArray = [NSMutableArray arrayWithCapacity:0];
    for (PHAsset *asset in assets) {
        if (asset.duration >= 5) {
            [videoArray addObject:asset];
        }
    }
    [_videoListView setVideos:videoArray];
}
-(void)dealloc{
    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

- (void)clickLimitsOfAuthorityOpenButtonStatistics {}

@end
