//
//  FSPublisherToolView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,FSPublisherToolViewType){
    FSPublisherToolViewTypeFromAlbum,
    FSPublisherToolViewTypeFromRecoder,
};
@protocol FSPublisherToolViewDelegate <NSObject>

- (void)FSPublisherToolViewQuit;
- (void)FSPublisherToolViewChooseMusic;
- (void)FSPublisherToolViewEditMusic;
- (void)FSPublisherToolViewEditVolume;
- (void)FSPublisherToolViewAddEffects;
- (void)FSPublisherToolViewAddFilter;
- (void)FSPublisherToolViewSaveToDraft;
- (void)FSPublisherToolViewSaveToLibrary:(BOOL)isSave;
- (void)FSPublisherToolViewPublished;
- (void)FSPublisherToolViewChangeVideoDescription:(NSString *)description;

@end

@interface FSPublisherToolView : UIView

@property (nonatomic, weak) id<FSPublisherToolViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame type:(FSPublisherToolViewType)type;
- (void)canEditMusic:(BOOL)enable;
@end
