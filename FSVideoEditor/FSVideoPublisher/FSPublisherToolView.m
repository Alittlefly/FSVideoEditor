//
//  FSPublisherToolView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherToolView.h"
#import "FSEditVideoNameView.h"

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

@property (nonatomic, assign)FSPublisherToolViewType type;

@end

static BOOL IsArabic = NO;

@implementation FSPublisherToolView

-(instancetype)initWithFrame:(CGRect)frame type:(FSPublisherToolViewType)type{
    if (self = [super initWithFrame:frame]) {
        _type = type;
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
    _backButton.frame = IsArabic ? CGRectMake(self.frame.size.width - 20 - 15, 20, 20,20) : CGRectMake(15, 20, 20, 20);
    //[_backButton setTitle:@"back" forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"recorder-back"] forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(backClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backButton];
    
    _chooseMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseMusicButton.frame = IsArabic ? CGRectMake(15, 20, 40, 40) : CGRectMake(self.frame.size.width - 15 -40, 20, 40, 40);
    // [_finishButton setTitle:@"finish" forState:UIControlStateNormal];
    [_chooseMusicButton setImage:[UIImage imageNamed:@"recorder-finish-gray"] forState:UIControlStateNormal];
    [_chooseMusicButton addTarget:self action:@selector(chooseMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_chooseMusicButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(IsArabic ? 15+40+5 : 15+20+5, 20, self.frame.size.width-15-15-20-40-10, 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.text = @"视频原声-@用户昵称";
    [self addSubview:_titleLabel];

    _cutMusicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cutMusicButton.frame = IsArabic ? CGRectMake(15, CGRectGetMaxY(_chooseMusicButton.frame)+30, 40, 40) : CGRectMake(CGRectGetWidth(self.frame) - 15 -40, CGRectGetMaxY(_chooseMusicButton.frame)+30, 40, 40);
    //[_cutMusicButton setTitle:@"cutMusic" forState:UIControlStateNormal];
    [_cutMusicButton setImage:[UIImage imageNamed:@"recorder-cut"] forState:UIControlStateNormal];
    [_cutMusicButton addTarget:self action:@selector(cutMusicClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cutMusicButton];
    
    _cutMusicLabel = [[UILabel alloc] init];
    _cutMusicLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10) : CGRectMake(CGRectGetMaxX(_cutMusicButton.frame) - CGRectGetWidth(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_cutMusicButton.frame), 10);
    _cutMusicLabel.font = [UIFont systemFontOfSize:9];
    _cutMusicLabel.textColor = [UIColor whiteColor];
    _cutMusicLabel.backgroundColor = [UIColor lightGrayColor];
    _cutMusicLabel.textAlignment = NSTextAlignmentCenter;
    _cutMusicLabel.text = @"编辑";
    [self addSubview:_cutMusicLabel];
    
    _volumeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _volumeButton.frame = CGRectMake(CGRectGetMinX(_cutMusicButton.frame), CGRectGetMaxY(_cutMusicLabel.frame)+20, 40, 40);
    //[_beautyButton setTitle:@"beaty" forState:UIControlStateNormal];
    [_volumeButton setImage:[UIImage imageNamed:@"recorder-beauty-on"] forState:UIControlStateNormal];
    [_volumeButton addTarget:self action:@selector(volumeClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_volumeButton];
    
    _volumeLabel = [[UILabel alloc] init];
    _volumeLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_cutMusicButton.frame), CGRectGetWidth(_volumeButton.frame), 10) : CGRectMake(CGRectGetMaxX(_volumeButton.frame) - CGRectGetWidth(_volumeButton.frame), CGRectGetMaxY(_volumeButton.frame), CGRectGetWidth(_volumeButton.frame), 10);
    _volumeLabel.backgroundColor = [UIColor lightGrayColor];
    _volumeLabel.font = [UIFont systemFontOfSize:9];
    _volumeLabel.textColor = [UIColor whiteColor];
    _volumeLabel.textAlignment = NSTextAlignmentCenter;
    _volumeLabel.text = @"音量";
    [self addSubview:_volumeLabel];
    
    if (_type == FSPublisherToolViewTypeFromAlbum) {
        _filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _filterButton.frame = CGRectMake(CGRectGetMinX(_volumeLabel.frame), CGRectGetMaxY(_volumeLabel.frame)+20, 40, 40);
        //[_filterButton setTitle:@"filter" forState:UIControlStateNormal];
        [_filterButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
        [_filterButton addTarget:self action:@selector(filterClik) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_filterButton];
        
        _filterLabel = [[UILabel alloc] init];
        _filterLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15) : CGRectMake(CGRectGetMaxX(_filterButton.frame) - CGRectGetWidth(_filterButton.frame), CGRectGetMaxY(_filterButton.frame), CGRectGetWidth(_filterButton.frame), 15);
        _filterLabel.backgroundColor = [UIColor clearColor];
        _filterLabel.font = [UIFont systemFontOfSize:9];
        _filterLabel.textColor = [UIColor whiteColor];
        _filterLabel.textAlignment = NSTextAlignmentCenter;// IsArabic ? NSTextAlignmentLeft : NSTextAlignmentRight;
        _filterLabel.text = @"滤镜";
        [self addSubview:_filterLabel];
    }
    
    _effectsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (_type == FSPublisherToolViewTypeFromAlbum) {
        _effectsButton.frame = CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_filterLabel.frame)+20, 40, 40);
    }
    else {
        _effectsButton.frame = CGRectMake(CGRectGetMinX(_volumeButton.frame), CGRectGetMaxY(_volumeLabel.frame)+20, 40, 40);
    }
    //[_filterButton setTitle:@"filter" forState:UIControlStateNormal];
    [_effectsButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_effectsButton addTarget:self action:@selector(effectsClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_effectsButton];
    
    _effectsLabel = [[UILabel alloc] init];
    _effectsLabel.frame = IsArabic ? CGRectMake(CGRectGetMinX(_effectsButton.frame), CGRectGetMaxY(_effectsButton.frame), CGRectGetWidth(_effectsButton.frame), 15) : CGRectMake(CGRectGetMaxX(_effectsButton.frame) - CGRectGetWidth(_effectsButton.frame), CGRectGetMaxY(_effectsButton.frame), CGRectGetWidth(_effectsButton.frame), 15);
    _effectsLabel.backgroundColor = [UIColor lightGrayColor];
    _effectsLabel.font = [UIFont systemFontOfSize:9];
    _effectsLabel.textColor = [UIColor whiteColor];
    _effectsLabel.textAlignment = NSTextAlignmentCenter;// IsArabic ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _effectsLabel.text = @"特效";
    [self addSubview:_effectsLabel];
    
    _draftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _draftButton.frame = IsArabic ? CGRectMake(self.frame.size.width-20-(self.frame.size.width-60)/2, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44) : CGRectMake(20, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44);
    [_draftButton setTitle:@"草稿" forState:UIControlStateNormal];
    _draftButton.backgroundColor = [UIColor lightGrayColor];
   // [_draftButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_draftButton addTarget:self action:@selector(draftClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_draftButton];
    
    _publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton.frame = IsArabic ? CGRectMake(20, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44) : CGRectMake(self.frame.size.width-20-(self.frame.size.width-60)/2, self.frame.size.height-74-44, (self.frame.size.width-60)/2, 44);
    [_publishButton setTitle:@"发布" forState:UIControlStateNormal];
    _publishButton.backgroundColor = [UIColor redColor];
    // [_draftButton setImage:[UIImage imageNamed:@"recorder-filter"] forState:UIControlStateNormal];
    [_publishButton addTarget:self action:@selector(publishClik) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_publishButton];
    
    _videoNameView = [[FSEditVideoNameView alloc] initWithFrame:CGRectMake(20, CGRectGetMinY(_publishButton.frame)-40-55, self.frame.size.width-40, 55)];
    _videoNameView.backgroundColor = [UIColor clearColor];
    _videoNameView.delegate = self;
    [self addSubview:_videoNameView];
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
    
}

- (void)FSEditVideoNameViewSaveToPhotoLibrary {

}

- (void)FSEditVideoNameViewAddChallenge {

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
