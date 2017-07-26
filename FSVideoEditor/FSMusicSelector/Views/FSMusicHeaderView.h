//
//  FSMusicHeaderView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMusic.h"

typedef NS_ENUM(NSInteger,FSMusicButtonType){
    FSMusicButtonTypeHot,
    FSMusicButtonTypeLike,
};
@protocol FSMusicHeaderViewDelegate <NSObject>
@optional
-(void)musicHeaderViewSelectItem:(FSMusicType *)item;
-(void)musicHeaderClickTypeButton:(FSMusicButtonType)type;
-(void)musicHeaderShouldBeFrame:(CGRect)frame;
@end

@interface FSMusicHeaderView : UIView
@property(nonatomic,strong)NSArray<FSMusicType *> *items;
@property(nonatomic,assign)id<FSMusicHeaderViewDelegate>delegate;
@end
