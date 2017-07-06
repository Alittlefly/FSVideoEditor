//
//  FSVideoFx.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSVideoFx.h"

@implementation FSVideoFx
-(id)copyWithZone:(NSZone *)zone{
    FSVideoFx *newFx = [FSVideoFx allocWithZone:zone];
    newFx -> _startPoint = self.startPoint;
    newFx -> _endPoint = self.endPoint;
    newFx -> _videoFxId = self.videoFxId;
    return newFx;
}
@end
