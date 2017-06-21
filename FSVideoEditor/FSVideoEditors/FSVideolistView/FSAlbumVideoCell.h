//
//  FSAlbumVideoCell.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface FSAlbumVideoCell : UICollectionViewCell
// 缩略图
@property(nonatomic,strong)UIImageView *thumbnail;
//
@property(nonatomic,strong)UILabel *durationLabel;

@property(nonatomic,strong)PHAsset *asset;
@end
