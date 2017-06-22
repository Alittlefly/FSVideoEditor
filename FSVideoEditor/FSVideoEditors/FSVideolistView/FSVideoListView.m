//
//  FSVideoListView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoListView.h"
#import "FSAlbumVideoCell.h"
@interface FSVideoListView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView *contentView;
@end
@implementation FSVideoListView
-(UICollectionView *)contentView{
    if (!_contentView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumInteritemSpacing = 1.0;
        layout.minimumLineSpacing = 1.0;
        layout.sectionInset = UIEdgeInsetsMake(0, 1, 0, 1);
         _contentView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [_contentView setDelegate:self];
        [_contentView setDataSource:self];
    
        Class cellClass = [self  cellClass];
        [_contentView registerClass:cellClass forCellWithReuseIdentifier:NSStringFromClass(cellClass)];
    }
    return _contentView;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentView];
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    [self.contentView setFrame:self.bounds];
}
-(void)setVideos:(NSArray *)videos{
    _videos = videos;
    
    [self.contentView reloadData];

}
#pragma mark -
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_videos count];
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    FSAlbumVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self cellClass]) forIndexPath:indexPath];
    cell.asset = [_videos objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark -
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.delegate respondsToSelector:@selector(videoListView:didSelectedVideo:)]) {
        [self.delegate videoListView:self didSelectedVideo:[_videos objectAtIndex:indexPath.row]];
    }
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat itemWidth = (CGRectGetWidth(collectionView.frame) - 4.0)/3.0;
    return CGSizeMake(itemWidth,itemWidth);
}

#pragma mark - 
-(Class)cellClass{
    return [FSAlbumVideoCell class];
}
@end
