//
//  FSTimelineConfiger.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimeline.h"
#import "FSDraftInfo.h"
@interface FSTimelineConfiger : NSObject
+(void)configTimeline:(NvsTimeline *)timeLine timeLineInfo:(FSDraftInfo *)timeLineInfo;
@end
