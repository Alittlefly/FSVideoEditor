//
//  FSMusicCell.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicCell.h"
#import "UIImageView+WebCache.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"

@interface FSMusicUseButton : UIButton
{
    CAGradientLayer *_glayer;
}
@end
@implementation FSMusicUseButton

+(Class)layerClass {
    return [CAGradientLayer class];
}

-(instancetype)init{
    if (self = [super init]) {
//        _glayer = (CAGradientLayer *)self.layer;
//        _glayer.colors = @[(__bridge id)FSHexRGB(0x3023AE).CGColor,(__bridge id)FSHexRGB(0xC96DD8).CGColor];
//        _glayer.startPoint = CGPointMake(0, 0);
//        _glayer.endPoint = CGPointMake(0, 1);
    }
    return self;
}
@end



@interface FSMusicCell()
@property(nonatomic,strong)UIButton *playButton;
@property(nonatomic,strong)UIImageView *pic;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *authorLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIButton *collectButton;
@property(nonatomic,strong)UIButton *deatilButton;

@property(nonatomic,strong)FSMusicUseButton *useButton;

@end
@implementation FSMusicCell
static NSString *identifier = @"FSMusicCell";
+(instancetype)musicCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    
    [tableView registerClass:[FSMusicCell class] forCellReuseIdentifier:identifier];
    FSMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setSelectionStyle:(UITableViewCellSelectionStyleNone)];
    [cell setSeparatorInset:(UIEdgeInsetsMake(0, 10.0, 0, 10.0))];
    return cell;
}
-(FSMusicUseButton *)useButton{
    if (!_useButton) {
         _useButton = [[FSMusicUseButton alloc] init];
        [_useButton setImage:[UIImage imageNamed:@"musicSelectRecoder"] forState:(UIControlStateNormal)];
        _useButton.backgroundColor = FSHexRGB(0x0BC2C6);
        [_useButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"RecordNow"] forState:UIControlStateNormal];
        [_useButton setAdjustsImageWhenHighlighted:NO];
        [_useButton addTarget:self action:@selector(useMusic:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _useButton;
}
-(UIButton *)playButton{
    if (!_playButton) {
         _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"musicPlay"] forState:(UIControlStateNormal)];
        [_playButton setImage:[UIImage imageNamed:@"musicPause"] forState:(UIControlStateSelected)];
        [_playButton addTarget:self action:@selector(playMusic:) forControlEvents:(UIControlEventTouchUpInside)];
        [_playButton setUserInteractionEnabled:NO];
    }
    return _playButton;
}
-(UIImageView *)pic{
    if (!_pic) {
         _pic = [[UIImageView alloc] init];
    }
    return _pic;
}
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:FSHexRGB(0x010a12)];
        [_nameLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_nameLabel setTextAlignment:(NSTextAlignmentLeft)];
    }
    return _nameLabel;
}
-(UILabel *)authorLabel{
    if (!_authorLabel) {
        _authorLabel = [[UILabel alloc] init];
        [_authorLabel setTextColor:FSHexRGB(0xb8b9bd)];
        [_authorLabel setFont:[UIFont systemFontOfSize:14.0]];
        [_authorLabel setTextAlignment:(NSTextAlignmentLeft)];
    }
    return _authorLabel;
}
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setTextColor:FSHexRGB(0xb8b9bd)];
        [_timeLabel setFont:[UIFont systemFontOfSize:15.0]];
        [_timeLabel setTextAlignment:(NSTextAlignmentLeft)];
    }
    return _timeLabel;
}
-(UIButton *)collectButton{
    if (!_collectButton) {
         _collectButton = [[UIButton alloc] init];
        [_collectButton setImage:[UIImage imageNamed:@"musicCollectNormal"] forState:(UIControlStateNormal)];
        [_collectButton setImage:[UIImage imageNamed:@"musicCollectSelect"] forState:(UIControlStateSelected)];
        [_collectButton addTarget:self action:@selector(collectMusic:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _collectButton;
}
-(UIButton *)deatilButton{
    if (!_deatilButton) {
         _deatilButton = [[UIButton alloc] init];
        [_deatilButton setImage:[UIImage imageNamed:@"musicDetailBtn"] forState:(UIControlStateNormal)];
        [_deatilButton addTarget:self action:@selector(showDetail:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _deatilButton;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self addSubview:self.pic];
    [self addSubview:self.playButton];
    [self addSubview:self.nameLabel];
    [self addSubview:self.authorLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.useButton];
    [self addSubview:self.collectButton];
    [self addSubview:self.deatilButton];
    
    [self setClipsToBounds:YES];
    
    [self.pic setFrame:CGRectMake(10, 20, 72, 72)];
    
    [self.pic setImage:[UIImage imageNamed:@"musicPlaceHolder"]];
    [self.playButton setFrame:self.pic.frame];
    
    [self.nameLabel setFrame:CGRectMake(100.0, 20, CGRectGetWidth(self.bounds) - 38 - 82, 21)];
    [self.authorLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.nameLabel.frame) + 1, CGRectGetWidth(self.nameLabel.frame) - 60, 20)];
    
    [self.timeLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.authorLabel.frame) + 8.0, CGRectGetWidth(self.nameLabel.frame), 18)];
    [self.useButton setFrame:CGRectMake(10, 102, CGRectGetWidth(self.bounds) - 20, 40)];
    
    [self.deatilButton setFrame:CGRectMake(CGRectGetWidth(self.bounds) - 80, (107 - 30)/2.0, 30, 30)];
    [self.collectButton setFrame:CGRectMake(CGRectGetWidth(self.bounds) - 40, (107 - 30)/2.0, 30, 30)];
}

-(void)setMusic:(FSMusic *)music{
    [self.nameLabel setText:music.songTitle];
    [self.authorLabel setText:music.songAuthor];
    [self.timeLabel setText:[self getCurrentTimeString:music.songTime]];
     _music = music;
    NSString *songPic = music.songPic;
    if (![songPic hasPrefix:@"http"] && songPic) {
        songPic = [@"http://35.158.218.231/" stringByAppendingString:songPic];
    }
    [self.pic sd_setImageWithURL:[NSURL URLWithString:songPic] placeholderImage:[UIImage imageNamed:@"musicPlaceHolder"]];
    [self.useButton setHidden:!_music.opend];
    [self.playButton setSelected:_music.isPlaying];
    [self.collectButton setSelected:_music.collected];
    [self setIsPlayIng:_music.isPlaying];
}

- (NSString *)getCurrentTimeString:(NSTimeInterval)time {
    int min = floor(time/60);
    int sec = ((int)time)%60;
    
    return [NSString stringWithFormat:@"%.2d:%.2d",min,sec];
}

-(void)setIsPlayIng:(BOOL)isPlayIng{
    _isPlayIng = isPlayIng;
    
    _music.isPlaying = isPlayIng;
    
    [self.playButton setSelected:isPlayIng];
}
-(void)playMusic:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(musicCell:wouldPlay:)]) {
        [self.delegate musicCell:self wouldPlay:_music];
    }
}
-(void)useMusic:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(musicCell:wuoldUseMusic:)]) {
        [self.delegate musicCell:self wuoldUseMusic:_music];
    }
}
-(void)collectMusic:(UIButton *)button{
    _music.collected = !_music.collected;
    [self.collectButton setSelected:_music.collected];
    if ([self.delegate respondsToSelector:@selector(musicCell:wouldCollect:)]) {
        [self.delegate musicCell:self wouldCollect:_music];
    }
}
-(void)showDetail:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(musicCell:wouldShowDetail:)]) {
        [self.delegate musicCell:self wouldShowDetail:_music];
    }
}

@end
