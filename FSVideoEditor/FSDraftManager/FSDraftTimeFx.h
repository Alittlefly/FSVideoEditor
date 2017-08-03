//
//  FSTimeFx.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FSDraftTimeFxType){
    FSDraftTimeFxTypeNone = 1,
    FSDraftTimeFxTypeRevert,
    FSDraftTimeFxTypeRePlay,
    FSDraftTimeFxTypeSlow,
};

@interface FSDraftTimeFx : NSObject<NSCoding,NSCopying>

@property(nonatomic,assign)FSDraftTimeFxType tFxType;
@property(nonatomic,assign)int64_t tFxInPoint;
@property(nonatomic,assign)int64_t tFxOutPoint;
@end
