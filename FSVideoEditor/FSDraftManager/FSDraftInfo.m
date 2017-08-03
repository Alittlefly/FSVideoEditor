//
//  FSTimeLineInfo.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftInfo.h"

@implementation FSDraftInfo
-(instancetype)initWithDraftInfo:(FSDraftInfo *)draftInfo{
    if (self = [super init]) {
        self.challenge = [draftInfo.challenge copy];
        self.vMusic = [draftInfo.vMusic copy];
        self.clips = [draftInfo.clips copy];
        self.vTimefx = [draftInfo.vTimefx copy];
    }
    return self;
}
-(void)copyValueFromeDraftInfo:(FSDraftInfo *)draftInfo{
    
}
@end
