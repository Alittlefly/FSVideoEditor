//
//  FSVideoFx.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimelineVideoFx.h"

@interface FSVideoFx : NSObject<NSCopying>
@property(nonatomic,strong)NSString *videoFxId;
@property(nonatomic,assign)int64_t startPoint;
@property(nonatomic,assign)int64_t endPoint;

@end
