//
//  FSChallengeCell.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSChallengeCell.h"
#import "FSVideoEditorCommenData.h"
#import "FSShortLanguage.h"
#import "FSPublishSingleton.h"

@interface FSChallengeCell()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *personNumLabel;
@property (nonatomic, strong) UILabel *descripLabel;
@property (nonatomic, strong) UIButton *addChallengeButton;

@end

@implementation FSChallengeCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self createBaseUI];
    }
    return self;
}

- (void)createBaseUI {
    // UITableViewCell的frame应该在layoutSubviews里获取，init时没有
    _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width - 20-18 : 20, 12, 18, 18)];
    _logoImageView.image = [UIImage imageNamed:@"#"];
    [self.contentView addSubview:_logoImageView];
    
    _personNumLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 :self.frame.size.width-20-100, 12, 100, 15)];
    _personNumLabel.backgroundColor = [UIColor clearColor];
    _personNumLabel.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentLeft : NSTextAlignmentRight;
    _personNumLabel.textColor = FSHexRGB(0x000000);
    _personNumLabel.font = [UIFont systemFontOfSize:13];
    NSString *personCount = [FSShortLanguage CustomLocalizedStringFromTable:@"ChallengePeopleCount"];
    personCount = [personCount stringByReplacingOccurrencesOfString:@"(x)" withString:@"0"];
    _personNumLabel.text = personCount;
    [self.contentView addSubview:_personNumLabel];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMaxX(_personNumLabel.frame)+5 : CGRectGetMaxX(_logoImageView.frame)+5, 10, 100, 20)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = [FSPublishSingleton sharedInstance].isAutoReverse ? NSTextAlignmentRight : NSTextAlignmentLeft;
    _titleLabel.textColor = FSHexRGB(0x292929);
    _titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:_titleLabel];
    
    _descripLabel = [[UILabel alloc] initWithFrame:CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame)+5, self.frame.size.width-40-12-5, 30)];
    _descripLabel.backgroundColor = [UIColor clearColor];
    _descripLabel.textAlignment = NSTextAlignmentLeft;
    _descripLabel.textColor = FSHexRGB(0x292929);
    _descripLabel.numberOfLines = 0;
    _descripLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_descripLabel];

    _addChallengeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _addChallengeButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-100, 10, 100, 16);
    _addChallengeButton.backgroundColor = [UIColor clearColor];
    [_addChallengeButton setTitle:[FSShortLanguage CustomLocalizedStringFromTable:@"AddHashtag"] forState:UIControlStateNormal];
    [_addChallengeButton setTitleColor:FSHexRGB(0x292929) forState:UIControlStateNormal];
    _addChallengeButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_addChallengeButton addTarget:self action:@selector(addNewChallenger) forControlEvents:UIControlEventTouchUpInside];
    [_addChallengeButton.titleLabel sizeToFit];
    _addChallengeButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-_addChallengeButton.titleLabel.frame.size.width, 10, _addChallengeButton.titleLabel.frame.size.width, 16);
    [self.contentView addSubview:_addChallengeButton];
    _addChallengeButton.hidden = YES;
}

- (void)setChallengeModel:(FSChallengeModel *)challengeModel {
    if (challengeModel.challengeId == 0) {
        _addChallengeButton.hidden = NO;
        _personNumLabel.hidden = YES;
        _descripLabel.hidden = YES;

        _titleLabel.text = challengeModel.name;
    }
    else {
        _addChallengeButton.hidden = YES;
        _personNumLabel.hidden = NO;
        _descripLabel.hidden = NO;
        
        NSString *personCount = [FSShortLanguage CustomLocalizedStringFromTable:@"ChallengePeopleCount"];
        personCount = [personCount stringByReplacingOccurrencesOfString:@"(x)" withString:[NSString stringWithFormat:@"%ld",(long)challengeModel.personCount]];
        _personNumLabel.text = personCount;
        [_personNumLabel sizeToFit];

        _titleLabel.text = challengeModel.name;
        
        _descripLabel.text = challengeModel.content;
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

-(void)layoutSubviews{
    [super layoutSubviews];
   
    _logoImageView.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? self.frame.size.width - 20-18 : 20, 12, 18, 18); // add by gongruike
    
    if (_addChallengeButton.isHidden) {
        _personNumLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-_personNumLabel.frame.size.width, _personNumLabel.frame.origin.y, _personNumLabel.frame.size.width, 16);
        _titleLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMaxX(_personNumLabel.frame)+5 : CGRectGetMaxX(_logoImageView.frame)+5, 10, self.frame.size.width-40-CGRectGetWidth(_logoImageView.frame)-CGRectGetWidth(_personNumLabel.frame)-10, 24);

        CGSize size = [_descripLabel.text boundingRectWithSize:CGSizeMake(_descripLabel.frame.size.width, 999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_descripLabel.font} context:nil].size;
        _descripLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : CGRectGetMinX(_titleLabel.frame), CGRectGetMaxY(_titleLabel.frame)+5, self.frame.size.width-40-12-5, size.height);
    }
    else {
        _addChallengeButton.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? 20 : self.frame.size.width-20-_addChallengeButton.titleLabel.frame.size.width, 10, _addChallengeButton.titleLabel.frame.size.width, 16);

        _titleLabel.frame = CGRectMake([FSPublishSingleton sharedInstance].isAutoReverse ? CGRectGetMaxX(_addChallengeButton.frame)+5 : CGRectGetMaxX(_logoImageView.frame)+5, 10, self.frame.size.width-40-CGRectGetWidth(_logoImageView.frame)-CGRectGetWidth(_addChallengeButton.frame)-10, 24);
    }
}

- (void)addNewChallenger {
    if ([self.delegate respondsToSelector:@selector(fsChallengeCellAddNewChallenge:)]) {
        [self.delegate fsChallengeCellAddNewChallenge:_titleLabel.text];
    }
}

@end
