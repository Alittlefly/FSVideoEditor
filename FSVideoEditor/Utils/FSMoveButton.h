//
//  FSMoveButton.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSMoveButtonDelegate <NSObject>

- (void)FSMoveButtonBeginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)FSMoveButtonContinueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)FSMoveButtonEndTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)FSMoveButtonCancelTrackingWithEvent:(UIEvent *)event;

@end

@interface FSMoveButton : UIButton

@property (nonatomic, weak) id<FSMoveButtonDelegate> delegate;

@end
