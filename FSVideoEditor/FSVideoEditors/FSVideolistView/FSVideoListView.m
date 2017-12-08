//
//  FSVideoListView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoListView.h"
#import "FSAlbumVideoCell.h"
#import "FSVideoEditorCommenData.h"
#import "FSAlertView.h"
@interface FSVideoListView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
@property(nonatomic,strong)UICollectionView *contentView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
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
        _selectedIndexPath = nil;
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

- (void)enterEditView {
    if (!_selectedIndexPath) {
        FSAlertView *alertView = [[FSAlertView alloc] init];
        [alertView showWithMessage:@"Please select a video!"];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(videoListView:didSelectedVideo:)]) {
        [self.delegate videoListView:self didSelectedVideo:[_videos objectAtIndex:_selectedIndexPath.row]];
    }
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
    if (_selectedIndexPath) {
        FSAlbumVideoCell *cell = (FSAlbumVideoCell*)[collectionView cellForItemAtIndexPath:_selectedIndexPath];
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        cell.layer.borderWidth = 0;
        cell.layer.masksToBounds = YES;
    }
    FSAlbumVideoCell *cell = (FSAlbumVideoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = FSHexRGB(0x0BC2C6).CGColor;
    cell.layer.borderWidth = 3;
    cell.layer.masksToBounds = YES;
    _selectedIndexPath = indexPath;
    
    if ([self.delegate respondsToSelector:@selector(videoListViewDidChooseOneVideo)]) {
        [self.delegate videoListViewDidChooseOneVideo];
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
