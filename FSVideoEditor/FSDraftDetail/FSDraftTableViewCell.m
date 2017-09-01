//
//  FSDraftTableViewCell.m
//  FSVideoEditor
//
//  Created by stu on 2017/8/6.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftTableViewCell.h"
#import "FSPublishSingleton.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSDraftTableViewCell ()

@property(nonatomic ,strong) UIImageView *photo;
@property(nonatomic ,strong) UIButton *playIcon;

@property(nonatomic ,strong) UILabel *topic;
@property(nonatomic ,strong) UILabel *tagLabel;

@property(nonatomic ,strong) UIButton *moreButton;

@property(nonatomic ,strong) UIView *deleteView;

@end


@implementation FSDraftTableViewCell

-(UIImageView *)photo{
    if (!_photo) {
         _photo = [[UIImageView alloc] init];
        [_photo setContentMode:(UIViewContentModeScaleAspectFill)];
        [_photo setClipsToBounds:YES];
        [self addSubview:_photo];
    }
    return _photo;
}

-(UIButton *)playIcon{
    if (!_playIcon) {
        _playIcon = [[UIButton alloc] init];
        [_playIcon addTarget:self action:@selector(palyIconOnclick) forControlEvents:UIControlEventTouchUpInside];
        [_playIcon setImage:[UIImage imageNamed:@"paly_video_image"] forState:UIControlStateNormal];
        [_playIcon setImageEdgeInsets:UIEdgeInsetsMake(20, 23, 20, 17)];
        [self addSubview:_playIcon];
    }
    return _playIcon;
}

-(UILabel *)topic{
    if (!_topic) {
        _topic = [[UILabel alloc] init];
        [_topic setFont:[UIFont systemFontOfSize:16]];
        [_topic setTextColor:FSHexRGB(0x292929)];
        [_topic setTextAlignment:[FSPublishSingleton sharedInstance].isAutoReverse?NSTextAlignmentRight:NSTextAlignmentLeft];
        [self addSubview:_topic];
    }
    return _topic;
}


-(UILabel *)tagLabel{
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        [_tagLabel setFont:[UIFont systemFontOfSize:13]];
        [_tagLabel setTextColor:FSHexRGB(0x999999)];
        [_tagLabel setTextAlignment:[FSPublishSingleton sharedInstance].isAutoReverse?NSTextAlignmentRight:NSTextAlignmentLeft];
        [self addSubview:_tagLabel];
    }
    return _tagLabel;
}

-(UIButton *)moreButton{
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton addTarget:self action:@selector(moreButtonOnclick) forControlEvents:UIControlEventTouchUpInside];
        [_moreButton setImage:[UIImage imageNamed:@"nav_btn_menu copy"] forState:UIControlStateNormal];
        [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 9, 9)];
        [self addSubview:_moreButton];
    }
    return _moreButton;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setSelected:NO];
        [self setSelectedBackgroundView:[[UIView alloc] init]];
        [self setSelectionStyle:(UITableViewCellSelectionStyleNone)];
        
        self.deleteView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0, 200, 101)];
        self.deleteView.backgroundColor = FSHexRGB(0xD50000);
        [self.contentView addSubview:self.deleteView];
        
        UIImageView *deleteImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 36, 30, 30)];
        [self.deleteView addSubview:deleteImage];
        [deleteImage setImage:[UIImage imageNamed:@"list_btn_delete"]];
    }
    return self;
}






- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat cellW = CGRectGetWidth(self.frame);
    [self.photo setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?cellW - 15 - 80:15, 10, 80, 80)];
    
    [self.playIcon setFrame:self.photo.frame];
    
    [self.topic setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?cellW - 110 - 160:110, 20, 160, 18)];
    
    [self.tagLabel setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?cellW - 110 - 160:110, 53, 160, 15)];
    
    [self.moreButton setFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse?0:cellW - 44, 28, 44, 44)];
}


-(void)setInfo:(FSDraftInfo *)info{
    _info = info;

    NSData *data = [NSData dataWithContentsOfFile:info.vFirstFramePath];
    UIImage * currentImage = [UIImage imageWithData:data];
    if(currentImage){
        [self.photo setImage:currentImage];
    }else{
        [self.photo setImage:[UIImage imageNamed:@"draft_default_image"]];
    }
    if (info.vTitle && info.vTitle.length) {
        [self.topic setText:info.vTitle];
    }else{
        [self.topic setText:[FSShortLanguage CustomLocalizedStringFromTable:@"NoTitle"]];
    }
    if (info.challenge.challengeName && info.challenge.challengeName.length) {
        [self.tagLabel setText:[NSString stringWithFormat:@"# %@",info.challenge.challengeName]];
    }else{
        [self.tagLabel setText:[NSString stringWithFormat:@"# %@",[FSShortLanguage CustomLocalizedStringFromTable:@"NoTopic"]]];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


-(void)palyIconOnclick{
    if ([self.delegate respondsToSelector:@selector(FSDraftTableCellDelegatePlayIconOnclik:)]) {
        [self.delegate FSDraftTableCellDelegatePlayIconOnclik:self];
    }
}

-(void)moreButtonOnclick{
    if ([self.delegate respondsToSelector:@selector(FSDraftTableCellDelegateMoreButtonOnclik:)]) {
        [self.delegate FSDraftTableCellDelegateMoreButtonOnclik:self];
    }
}

@end
