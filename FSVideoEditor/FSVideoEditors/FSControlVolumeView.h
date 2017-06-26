//
//  FSControlVolumeView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSControlVolumeViewDelegate <NSObject>

- (void)FSControlVolumeViewChangeScore:(CGFloat)value;
- (void)FSControlVolumeViewChangeSoundtrack:(CGFloat)value;
- (void)FSControlVolumeViewChangeFinished;

@end

@interface FSControlVolumeView : UIView

@property (nonatomic, weak) id<FSControlVolumeViewDelegate> delegate;

@end
