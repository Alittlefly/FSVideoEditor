//
//  FSMusicListView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMusicCell.h"
@protocol FSMusicListViewDelegate <NSObject>

-(void)musicListWouldUseMusic:(FSMusic *)music musicPath:(NSString *)musicPath;

@end

@interface FSMusicListView : UIView
@property(nonatomic,strong)UIView *tableHeader;
@property(nonatomic,assign)id<FSMusicListViewDelegate>delegate;
@property(nonatomic,strong)NSArray *musics;

-(void)showLoading:(BOOL)show;
- (void)stopPlayCurrentMusic;
@end
