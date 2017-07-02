//
//  FSMusicCell.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicCell.h"


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
        _glayer = (CAGradientLayer *)self.layer;
        _glayer.colors = @[(__bridge id)FSHexRGB(0x3023ae).CGColor,(__bridge id)FSHexRGB(0xC96DD8).CGColor];
        _glayer.startPoint = CGPointMake(0, 0);
        _glayer.endPoint = CGPointMake(0, 1);
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
        [_useButton setTitle:@"确定使用并开始" forState:UIControlStateNormal];
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
    }
    return _playButton;
}
-(UIImageView *)pic{
    if (!_pic) {
         _pic = [[UIImageView alloc] init];
        [_pic setBackgroundColor:[UIColor redColor]];
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
    }
    return _collectButton;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self addSubview:self.pic];
    [self addSubview:self.playButton];
    [self addSubview:self.nameLabel];
    [self addSubview:self.authorLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.useButton];
    
    [self setClipsToBounds:YES];
    
    [self.pic setFrame:CGRectMake(10, 20, 72, 72)];
    [self.playButton setFrame:self.pic.frame];
    
    [self.nameLabel setFrame:CGRectMake(100.0, 20, CGRectGetWidth(self.bounds) - 38 - 82, 21)];
    [self.authorLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.nameLabel.frame) + 1, CGRectGetWidth(self.nameLabel.frame) - 60, 20)];
    
    [self.timeLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.authorLabel.frame) + 8.0, CGRectGetWidth(self.nameLabel.frame), 18)];
    [self.useButton setFrame:CGRectMake(10, 102, CGRectGetWidth(self.bounds) - 20, 40)];
}

-(void)setMusic:(FSMusic *)music{
    [self.nameLabel setText:music.name];
    [self.authorLabel setText:music.author];
    [self.timeLabel setText:@"00:18"];
    _music = music;
    
    [self.useButton setHidden:!_music.opend];
    [self.playButton setSelected:_music.isPlaying];
}
-(void)playMusic:(UIButton *)button{
    
    [button setSelected:!button.selected];
    
    if ([self.delegate respondsToSelector:@selector(musicCell:wouldPlay:)]) {
        [self.delegate musicCell:self wouldPlay:_music];
    }
}
-(void)useMusic:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(musicCell:wuoldUseMusic:)]) {
        [self.delegate musicCell:self wuoldUseMusic:_music];
    }
}

@end
