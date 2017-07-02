//
//  FSMusicCell.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicCell.h"

@interface FSMusicCell()
@property(nonatomic,strong)UIButton *playButton;
@property(nonatomic,strong)UIImageView *pic;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *authorLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIButton *collectButton;
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
-(UIButton *)playButton{
    if (!_playButton) {
         _playButton = [[UIButton alloc] init];
        [_playButton setImage:[UIImage imageNamed:@"fx_play"] forState:(UIControlStateNormal)];
        [_playButton addTarget:self action:@selector(playMusic) forControlEvents:(UIControlEventTouchUpInside)];
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
    
    [self.pic setFrame:CGRectMake(10, 20, 72, 72)];
    [self.playButton setFrame:self.pic.frame];
    
    [self.nameLabel setFrame:CGRectMake(100.0, 20, CGRectGetWidth(self.bounds) - 38 - 82, 21)];
    [self.authorLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.nameLabel.frame) + 1, CGRectGetWidth(self.nameLabel.frame) - 60, 20)];
    
    [self.timeLabel setFrame:CGRectMake(100.0, CGRectGetMaxY(self.authorLabel.frame) + 8.0, CGRectGetWidth(self.nameLabel.frame), 18)];
}

-(void)setMusic:(NSString *)music{
    [self.nameLabel setText:@"哈哈哈哈哈"];
    [self.authorLabel setText:@"薛之谦"];
    [self.timeLabel setText:@"00:18"];
    _music = music;
}
-(void)playMusic{
    if ([self.delegate respondsToSelector:@selector(musicCell:wouldPlay:)]) {
        [self.delegate musicCell:self wouldPlay:_music];
    }
}

@end
