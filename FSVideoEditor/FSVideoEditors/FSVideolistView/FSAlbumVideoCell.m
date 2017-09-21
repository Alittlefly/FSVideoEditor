//
//  FSAlbumVideoCell.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAlbumVideoCell.h"

@interface FSAlbumVideoCell()
{
    PHImageManager *_imageManager;
    
    PHImageRequestID _currentRequestId;
}
@end
@implementation FSAlbumVideoCell

-(UIImageView *)thumbnail{
    if (!_thumbnail) {
         _thumbnail = [[UIImageView alloc] init];
        [_thumbnail setBackgroundColor:[UIColor clearColor]];
        [_thumbnail setContentMode:(UIViewContentModeScaleAspectFill)];
        [_thumbnail setClipsToBounds:YES];

    }
    return _thumbnail;
}
-(UILabel *)durationLabel{
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        [_durationLabel setFont:[UIFont systemFontOfSize:11.0]];
        [_durationLabel setTextColor:[UIColor whiteColor]];
        [_durationLabel setTextAlignment:(NSTextAlignmentRight)];
        [_durationLabel setText:@"00.08"];
    }
    return _durationLabel;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _imageManager = [PHImageManager defaultManager];
        
        [self addSubview:self.thumbnail];

        [self addSubview:self.durationLabel];

    }
    return self;
}
-(void)prepareForReuse{
    [super prepareForReuse];

    [_imageManager cancelImageRequest:_currentRequestId];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self.durationLabel setFrame:CGRectMake(8.5, CGRectGetHeight(self.bounds) - 21, CGRectGetWidth(self.bounds) - 17,14)];
    [self.thumbnail setFrame:self.bounds];
}
-(void)setAsset:(PHAsset *)asset{
    _asset = asset;
    
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    _currentRequestId = [_imageManager requestImageForAsset:asset targetSize:self.bounds.size contentMode:(PHImageContentModeAspectFit) options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [self.thumbnail setImage:result];
    }];
    
    NSTimeInterval duration = asset.duration;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    
    NSString *durationStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:duration]];
    [_durationLabel setText:durationStr];
    
}
@end
