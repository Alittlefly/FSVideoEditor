//
//  FSToolController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSToolController.h"
#import "FSShortVideoRecorderController.h"
#import "FSLocalVideoController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "FSMusicController.h"
#import "AFNetworking.h"
#import "FSPresentAnimator.h"
#import "FSMusicPlayer.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSRecordNowButton : UIButton
{
    NSString *_text;
}
@end
@implementation FSRecordNowButton

-(void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
    
    _text = title;
}
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    NSString *title = _text;
    CGFloat imageWidth = 20.0;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0]};
    CGRect newSize = [title boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat textW = CGRectGetWidth(newSize);
    CGFloat startX = (CGRectGetWidth(contentRect) - (textW + imageWidth + 1.0))/2.0 ;
    
    CGFloat imageX = 0;
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        imageX = startX;
    }else{
        imageX = startX + textW + 1.0;
    }
    
    CGFloat imageH = 20.0;
    CGFloat imageY = (CGRectGetHeight(contentRect)  - imageH)/2.0;
    return CGRectMake(imageX, imageY, imageWidth, imageH);
}
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    NSString *title = _text;
    CGFloat imageWidth = 20.0;
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0]};
    CGRect newSize = [title boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat textW = CGRectGetWidth(newSize);
    CGFloat startX = (CGRectGetWidth(contentRect) - (textW + imageWidth + 1.0))/2.0;
    CGFloat textX = 0.0;
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        textX = startX + imageWidth + 1.0;
    }else{
        textX = startX;

    }
    CGFloat textH = 21.0;
    CGFloat textY = (CGRectGetHeight(contentRect)  - textH)/2.0;
    return CGRectMake(textX, textY, textW, textH);
}

@end

@interface FSToolController ()<FSMusicControllerDelegate>
{
    UIButton *_currentButton;
}
@property(nonatomic,strong)UIView *contentView;
@property(nonatomic,strong)FSMusicController *musicView;
@property(nonatomic,strong)FSLocalVideoController *localView;

@end

@implementation FSToolController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 20,CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_contentView setBackgroundColor:[UIColor whiteColor]];
    [_contentView.layer setCornerRadius:5.0];
    [_contentView.layer setMasksToBounds:YES];
    [self.view addSubview:_contentView];
    
    
    NSString *recordText = [FSShortLanguage CustomLocalizedStringFromTable:@"Record"];
    NSDictionary *dict = @{NSFontAttributeName:[UIFont systemFontOfSize:15.0]};
    CGRect newSize = [recordText boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat textW = CGRectGetWidth(newSize);
    CGFloat buttonW = textW + 1.0 + 20.0;
    FSRecordNowButton *videoRecorderButton = [FSRecordNowButton buttonWithType:UIButtonTypeCustom];
    [videoRecorderButton setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentCenter)];
     videoRecorderButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20: CGRectGetWidth(_contentView.frame) - buttonW - 20, 17, buttonW, 21);
    [videoRecorderButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [videoRecorderButton setTitle:recordText forState:UIControlStateNormal];
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        [videoRecorderButton setImage:[UIImage imageNamed:@"startRecord_ar"] forState:(UIControlStateNormal)];
    }else {
        [videoRecorderButton setImage:[UIImage imageNamed:@"startRecord_en"] forState:(UIControlStateNormal)];
    }
    [videoRecorderButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [videoRecorderButton setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [videoRecorderButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    videoRecorderButton.tag = 1;
    [_contentView addSubview:videoRecorderButton];
    
    
    UIButton *selectMusic = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *chooseMusic = [FSShortLanguage CustomLocalizedStringFromTable:@"ChooseMusic"];
    CGRect chooseSize = [chooseMusic boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat chooseSizeW = CGRectGetWidth(chooseSize);
    selectMusic.frame = CGRectMake((CGRectGetWidth(_contentView.frame) - chooseSizeW)/2.0, 17, chooseSizeW, 21);
    [selectMusic setTitle:chooseMusic forState:UIControlStateNormal];
    [selectMusic addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    selectMusic.tag = 2;
    [selectMusic setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [selectMusic setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [selectMusic.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [selectMusic setSelected:YES];
     _currentButton = selectMusic;
    [_contentView addSubview:selectMusic];
    
    
    UIButton *videoListButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *UploadVideotext = [FSShortLanguage CustomLocalizedStringFromTable:@"UploadVideo"];
    CGRect UploadVideotextSize = [UploadVideotext boundingRectWithSize:CGSizeMake(0,MAXFLOAT) options:(NSStringDrawingUsesFontLeading) attributes:dict context:nil];
    CGFloat UploadVideotextW = CGRectGetWidth(UploadVideotextSize);
    videoListButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? _contentView.frame.size.width- UploadVideotextW - 20: 20, 17, UploadVideotextW, 21);
    [videoListButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"UploadVideo"] forState:UIControlStateNormal];
    [videoListButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    [videoListButton.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
     videoListButton.tag = 3;
    [videoListButton setTitleColor:FSHexRGB(0x73747B) forState:(UIControlStateNormal)];
    [videoListButton setTitleColor:FSHexRGB(0x010A12) forState:(UIControlStateSelected)];
    [_contentView addSubview:videoListButton];
    
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 54, CGRectGetWidth(_contentView.frame), 1.0)];
    [line setBackgroundColor:FSHexRGB(0xe5e5e5)];
    [_contentView addSubview:line];
    
    
    if (!_musicView) {
        
        FSMusicController *music = [[FSMusicController alloc] init];
        [music setDelegate:self];
        [self addChildViewController:music];
        [music.view setFrame:CGRectMake(0, 55, CGRectGetWidth(self.view.bounds), CGRectGetHeight(_contentView.frame)  - 55 - 20)];
        [_contentView addSubview:music.view];
         _musicView = music;
        
    }

    [self.view setBackgroundColor:[UIColor clearColor]];
    
}

- (void)videoRecorder {
    
    [self stopPlayer];
    
    FSShortVideoRecorderController *svc = [[FSShortVideoRecorderController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}
// 统计
-(void)clickUploadVideo{}
-(void)clickMusicButton{}
-(void)clickRecordButton{}
- (void)clickButton:(UIButton *)button{
    
    if (button.tag == 1) {
        [self videoRecorder];
    }else{
        [_currentButton setSelected:NO];
         _currentButton = button;
        [_currentButton setSelected:YES];
        
        if (button.tag == 2) {
            [self clickMusicButton];
        }else if (button.tag == 3){
            if (!_localView) {
                 _localView = [[FSLocalVideoController alloc] init];
                [_localView.view setFrame:_musicView.view.frame];
                [_contentView addSubview:_localView.view];
                [self addChildViewController:_localView];
            }
            [self stopPlayer];
            [self clickUploadVideo];
        }
    
        
        [_localView.view setHidden:button.tag != 3];
        [_musicView.view setHidden:button.tag != 2];
    }
}

- (void)videoList {
    
    [self stopPlayer];
    
    FSLocalVideoController *svc = [[FSLocalVideoController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}
-(void)stopPlayer{
    [_musicView stopPlayCurrentMusic];
    [[FSMusicPlayer sharedPlayer] stop];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    if (_currentButton.tag == 3) {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolWillShow object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

#pragma mark -
-(UIViewController *)musicControllerWouldShowMusicDetail:(FSMusic *)music{
    
    UIViewController *deatilController = nil;
    
    if ([self.delegate respondsToSelector:@selector(musicDetailControllerWithMusic:)]) {
        deatilController = [self.delegate musicDetailControllerWithMusic:music];
    }
    
    NSAssert(![deatilController isKindOfClass:[UINavigationController class]], @"返回的控制器不能为nav");
    return deatilController;
}
-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNSNotificationVideoEditToolDidHide object:nil];

    NSLog(@" %@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
}

@end
