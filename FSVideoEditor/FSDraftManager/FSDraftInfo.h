//
//  FSDraftInfo.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftVideoFx.h"
#import "FSDraftMusic.h"
#import "FSDraftChallenge.h"
#import "FSDraftTimeFx.h"
#import "FSVideoFxOperationStack.h"

@interface FSDraftInfo : NSObject
@property(nonatomic,strong)FSDraftMusic *vMusic;
@property(nonatomic,strong)FSVideoFxOperationStack *stack;
@property(nonatomic,strong)FSDraftChallenge *challenge;
@property(nonatomic,strong)FSDraftTimeFx *vTimefx;
@property(nonatomic,assign)BOOL vBeautyOn;
@property(nonatomic,assign)double vOriginalVolume;
@property(nonatomic,assign)double vMusicVolume;
@property(nonatomic,strong)NSString *vTitle;
@property(nonatomic,strong)NSString *vFinalPath;
@property(nonatomic,strong)NSString *vFirstFramePath;
@property(nonatomic,assign)double vSpeed;
@property(nonatomic,strong)NSArray<NSString *> *clips;
@property(nonatomic,strong)NSString *vConvertPath;
@property(nonatomic,strong)NSString *vFilterid;
@end
