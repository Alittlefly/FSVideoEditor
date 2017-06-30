//
//  FSMoveButton.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/30.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMoveButton.h"

@implementation FSMoveButton

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(FSMoveButtonBeginTrackingWithTouch:withEvent:)]) {
        [self.delegate FSMoveButtonBeginTrackingWithTouch:touch withEvent:event];
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if ([self.delegate respondsToSelector:@selector(FSMoveButtonContinueTrackingWithTouch:withEvent:)]) {
        [self.delegate FSMoveButtonContinueTrackingWithTouch:touch withEvent:event];
    }
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(FSMoveButtonEndTrackingWithTouch:withEvent:)]) {
        [self.delegate FSMoveButtonEndTrackingWithTouch:touch withEvent:event];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
    if ([self.delegate respondsToSelector:@selector(FSMoveButtonCancelTrackingWithEvent:)]) {
        [self.delegate FSMoveButtonCancelTrackingWithEvent:event];
    }
}

@end
