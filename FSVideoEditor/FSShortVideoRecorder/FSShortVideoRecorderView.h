//
//  FSShortVideoRecorderView.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSShortVideoRecorderViewDelegate <NSObject>

- (void)FSShortVideoRecorderViewQuitRecorderView;

@end

@interface FSShortVideoRecorderView : UIView

@property (nonatomic, weak) id<FSShortVideoRecorderViewDelegate> delegate;

@end
