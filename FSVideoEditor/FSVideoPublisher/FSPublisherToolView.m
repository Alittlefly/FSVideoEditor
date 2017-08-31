//
//  FSPublisherToolView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherToolView.h"
#import "FSEditVideoNameView.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"
#import "UIButton+WebCache.h"

@interface FSPublisherToolView()<FSEditVideoNameViewDelegate>

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *chooseMusicButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cutMusicButton;  //剪音乐
@property (nonatomic, strong) UIButton *volumeButton;  //音量调节
@property (nonatomic, strong) UIButton *effectsButton; //特效
@property (nonatomic, strong) UIButton *filterButton;

@property (nonatomic, strong) UILabel *cutMusicLabel;
@property (nonatomic, strong) UILabel *volumeLabel;
@property (nonatomic, strong) UILabel *effectsLabel;
@property (nonatomic, strong) UILabel *filterLabel;

@property (nonatomic, strong) FSEditVideoNameView *videoNameView;

@property (nonatomic, strong) UIButton *draftButton;
@property (nonatomic, strong) UIButton *publishButton;

@property (nonatomic, assign) FSDraftInfoType type;

@property (nonatomic, strong) FSDraftInfo *draftInfo;

@end

@implementation FSPublisherToolView

-(instancetype)initWithFrame:(CGRect)frame draftInfo:(FSDraftInfo *)draftInfo{
    if (self = [super initWithFrame:frame]) {
        _type = draftInfo.vType;
        _draftInfo = draftInfo;
        [self initBaseUI];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoradShows:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoradHides:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
    
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initBaseUI];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoradShows:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoradHides:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)initBaseUI {
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(self.frame.size.width - 20 - 15, 20, 20,20) : CGRectMake(15, 30, 20, 20);
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    if ([FSPublishSingleton sharedInstance].isAutoReverse) {
        _backButton.transform = CGAffineTransformMakeScale(-1, 1);
    }
    
    _chooseMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseMusicButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(15, 20, 40, 40) : CGRectMake(self.frame.size.width - 15 -40, 20, 40, 40);
    [_chooseMusicButton setImage:[UIImage imageNamed:@"choose-music"] forState:UIControlStateNormal];
    [_chooseMusicButton.layer setCornerRadius:20.0];
    [_chooseMusicButton.layer setMasksToBounds:YES];
    [_chooseMusicButton addTarget:self action:@selector(chooseMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chooseMusicButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 15+40+15 : 15+20+15, 20, self.frame.size.width-15-15-20-40-30, 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _titleLabel.shadowColor = [UIColor blackColor];
    _titleLabel.shadowOffset = CGSizeMake(1, 1);
    if (_draftInfo.vMusic) {
        _titleLabel.text = [NSString stringWithFormat:@"%@-@%@",_draftInfo.vMusic.mName,_draftInfo.vMusic.mAutor];

    }
    else {
        _titleLabel.text = [NSString stringWithFormat:@"%@-@%@",[FSShortLanguage CustomLocalizedStringFromTable:@"OriginalVoice"],[FSPublishSingleton sharedInstance].userName];
    }
    [self addSubview:_titleLabel];

    _cutMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutMusicButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(15, CGRectGetMaxY(_chooseMusicButton.frame)+30, 40, 40) : CGRectMake(CGRectGetWidth(self.frame) - 15 -40, CGRectGetMaxY(_chooseMusicButton.frame)+30, 40, 40);
    [_cutMusicButton setImage:[UIImage imageNamed:@"recorder-cut"] forState:UIControlStateNormal];
    [_cutMusicButton addTarget:self action:@selector(cutMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cutMusicButton];
    
    _cutMusicLabel = [[UILabel alloc] init];
    //_cutMusicLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10) : CGRectMake(CGRectGetMaxX(_cutMusicButton.frame) - CGRectGetWidth(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10);
    _cutMusicLabel.font = [UIFont systemFontOfSize:10];
    _cutMusicLabel.textColor = [UIColor whiteColor];
    _cutMusicLabel.backgroundColor = [UIColor clearColor];
    _cutMusicLabel.textAlignment = NSTextAlignmentCenter;
    _cutMusicLabel.shadowColor = [UIColor blackColor];
    _cutMusicLabel.shadowOffset = CGSizeMake(1, 1);
    _cutMusicLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Edit"];//NSLocalizedString(@"Edit", nil);
    [_cutMusicLabel sizeToFit];
    _cutMusicLabel.center = CGPointMake(_cutMusicButton.center.x, CGRectGetMaxY(_cutMusicButton.frame)+_cutMusicLabel.frame.size.height/2);
    [self addSubview:_cutMusicLabel];
    
    _volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _volumeButton.frame = CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicLabel.frame)+20, 40, 40);
    [_volumeButton setImage:[UIImage imageNamed:@"recorder-volume"] forState:UIControlStateNormal];
    [_volumeButton addTarget:self action:@selector(volumeClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_volumeButton];
    
    _volumeLabel = [[UILabel alloc] init];
    //_volumeLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_volumeButton.frame), CGRectGetWidth(_volumeButton.frame), 10) : CGRectMake(CGRectGetMaxX(_volumeButton.frame) - CGRectGetWidth(_volumeButton.frame), CGRectGetMaxY(_volumeButton.frame), CGRectGetWidth(_volumeButton.frame), 10);
    _volumeLabel.backgroundColor = [UIColor clearColor];
    _volumeLabel.font = [UIFont systemFontOfSize:10];
    _volumeLabel.textColor = [UIColor whiteColor];
    _volumeLabel.textAlignment = NSTextAlignmentCenter;
    _volumeLabel.shadowColor = [UIColor blackColor];
    _volumeLabel.shadowOffset = CGSizeMake(1, 1);
    _volumeLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Volume"];//NSLocalizedString(@"Volume", nil);
    [_volumeLabel sizeToFit];
    _volumeLabel.center = CGPointMake(_volumeButton.center.x, CGRectGetMaxY(_volumeButton.frame)+_volumeLabel.frame.size.height/2);
    [self addSubview:_volumeLabel];
    
    if (_type == FSDraftInfoTypeVideo) {
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButton.frame = CGRectMake(CGRectGetMinX(_volumeLabel.frame), CGRectGetMaxY(_volumeLabel.frame)+20, 40, 40);
        [_filterButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(filterClik) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_filterButton];
        
        _filterLabel = [[UILabel alloc] init];
        //_filterLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15) : CGRectMake(CGRectGetMaxX(_filterButton.frame) - CGRectGetWidth(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15);
        _filterLabel.backgroundColor = [UIColor clearColor];
        _filterLabel.font = [UIFont systemFontOfSize:10];
        _filterLabel.textColor = [UIColor whiteColor];
        _filterLabel.textAlignment = NSTextAlignmentCenter;
        _filterLabel.shadowColor = [UIColor blackColor];
        _filterLabel.shadowOffset = CGSizeMake(1, 1);
        _filterLabel.text = [FSShortLanguage
                             CustomLocalizedStringFromTable:@"ColorFilter"];
        [_filterLabel sizeToFit];
        _filterLabel.center = CGPointMake(_filterButton.center.x, CGRectGetMaxY(_filterButton.frame)+_filterLabel.frame.size.height/2);
        [self addSubview:_filterLabel];
    }
    
    _effectsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_type == FSDraftInfoTypeVideo) {
        _effectsButton.frame = CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_filterLabel.frame)+20, 40, 40);
    }
    else {
        _effectsButton.frame = CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_volumeLabel.frame)+20, 40, 40);
    }
    [_effectsButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_effectsButton addTarget:self action:@selector(effectsClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_effectsButton];
    
    _effectsLabel = [[UILabel alloc] init];
    //_effectsLabel.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(CGRectGetMinX(_effectsButton.frame), CGRectGetMaxY(_effectsButton.frame), CGRectGetWidth(_effectsButton.frame), 15) : CGRectMake(CGRectGetMaxX(_effectsButton.frame) - CGRectGetWidth(_effectsButton.frame), CGRectGetMaxY(_effectsButton.frame), CGRectGetWidth(_effectsButton.frame), 15);
    _effectsLabel.backgroundColor = [UIColor clearColor];
    _effectsLabel.font = [UIFont systemFontOfSize:10];
    _effectsLabel.textColor = [UIColor whiteColor];
    _effectsLabel.shadowColor = [UIColor blackColor];
    _effectsLabel.shadowOffset = CGSizeMake(1, 1);
    _effectsLabel.textAlignment = NSTextAlignmentCenter;
    _effectsLabel.text = [FSShortLanguage CustomLocalizedStringFromTable:@"Effects"];
    [_effectsLabel sizeToFit];
    _effectsLabel.center = CGPointMake(_effectsButton.center.x, CGRectGetMaxY(_effectsButton.frame)+_effectsLabel.frame.size.height/2);
    [self addSubview:_effectsLabel];
    
    _draftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _draftButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(self.frame.size.width-20-(self.frame.size.width-60)/2, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44) : CGRectMake(20, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44);
    [_draftButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Draft"] forState:UIControlStateNormal];
    _draftButton.backgroundColor = FSHexRGBAlpha(0xD8D8D8, 0.8);
    _draftButton.layer.cornerRadius = 5;
    _draftButton.layer.masksToBounds = YES;
    [_draftButton setImage:[UIImage imageNamed:@"draft"] forState:UIControlStateNormal];
    [_draftButton addTarget:self action:@selector(draftClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_draftButton];
    
    _publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton.frame = [FSPublishSingleton sharedInstance].isAutoReverse ? CGRectMake(20, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44) : CGRectMake(self.frame.size.width-20-(self.frame.size.width-60)/2, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44);
    [_publishButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"Upload"] forState:UIControlStateNormal];
    _publishButton.backgroundColor = FSHexRGB(0x0BC2C6);
    _publishButton.layer.cornerRadius = 5;
    _publishButton.layer.masksToBounds = YES;
     [_publishButton setImage:[UIImage imageNamed:@"publish"] forState:UIControlStateNormal];
    [_publishButton addTarget:self action:@selector(publishClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_publishButton];
    
    _videoNameView = [[FSEditVideoNameView alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(_publishButton.frame)-40-55, self.frame.size.width-40, 55) draftInfo:_draftInfo];
    _videoNameView.backgroundColor = [UIColor clearColor];
    _videoNameView.delegate = self;
    [self addSubview:_videoNameView];
}

- (void)canEditMusic:(BOOL)enable {
    self.cutMusicButton.enabled = enable;
}

- (void)updateChallengeName:(NSString *)challenge {
    [_videoNameView updateChallengeName:challenge];
}

- (void)updateMusicInfo:(FSMusic *)music {
     _titleLabel.text = [NSString stringWithFormat:@"%@-@%@",music.songTitle,music.songAuthor];
    NSString *songPic = [NSString stringWithFormat:@"%@%@",AddressResource,music.songPic];
    [_chooseMusicButton sd_setImageWithURL:[NSURL URLWithString:songPic] forState:(UIControlStateNormal)];

}

- (void)backClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewQuit)]) {
        [self.delegate FSPublisherToolViewQuit];
    }
}

- (void)chooseMusicClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewChooseMusic)]) {
        [self.delegate FSPublisherToolViewChooseMusic];
    }
}

- (void)cutMusicClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewEditMusic)]) {
        [self.delegate FSPublisherToolViewEditMusic];
    }
}

- (void)volumeClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewEditVolume)]) {
        [self.delegate FSPublisherToolViewEditVolume];
    }
}

- (void)filterClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewAddFilter)]) {
        [self.delegate FSPublisherToolViewAddFilter];
    }
}

- (void)effectsClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewAddEffects)]) {
        [self.delegate FSPublisherToolViewAddEffects];
    }
}

- (void)draftClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewSaveToDraft)]) {
        [self.delegate FSPublisherToolViewSaveToDraft];
    }
}

- (void)publishClik {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewPublished)]) {
        [self.delegate FSPublisherToolViewPublished];
    }
}

- (void)tapClick {
    [self.videoNameView hiddenKeyBorde];
}

#pragma mark - 
-(void)FSEditVideoNameViewEditVideoTitle:(NSString *)title {
    _draftInfo.vTitle = title;
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewChangeVideoDescription:)]) {
        [self.delegate FSPublisherToolViewChangeVideoDescription:title];
    }
}

- (void)FSEditVideoNameViewSaveToPhotoLibrary:(BOOL)isSave {
    _draftInfo.vSaveToAlbum = isSave;
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewSaveToLibrary:)]) {
        [self.delegate FSPublisherToolViewSaveToLibrary:isSave];
    }
}
- (void)FSEditVideoNameViewRemoveChallenge{
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewRemovechallenge)]) {
        [self.delegate FSPublisherToolViewRemovechallenge];
    }
}
- (void)FSEditVideoNameViewAddChallenge {
    if ([self.delegate respondsToSelector:@selector(FSPublisherToolViewShowChallengeView)]) {
        [self.delegate FSPublisherToolViewShowChallengeView];
    }
}

-(void)keyBoradShows:(NSNotification *)notification
{
    CGFloat editNameViewMaxY = CGRectGetMaxY(self.videoNameView.frame);

    NSDictionary *userInfo = [notification userInfo];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    CGRect keyboardRect;
    [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardRect];
    
    CGFloat keyboardMinY = self.frame.size.height - CGRectGetHeight(keyboardRect);
    if (editNameViewMaxY > keyboardMinY) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:[duration doubleValue]];
        [UIView setAnimationCurve:(UIViewAnimationCurve)[curve intValue]];
        [self.videoNameView setTransform:CGAffineTransformMakeTranslation(0, keyboardMinY-editNameViewMaxY)];
        [UIView commitAnimations];
    }
    
}
-(void)keyBoradHides:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:(UIViewAnimationCurve)[curve intValue]];
    [self.videoNameView setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end
