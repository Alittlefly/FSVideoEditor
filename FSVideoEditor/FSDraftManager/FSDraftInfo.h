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

typedef NS_ENUM(NSInteger,FSDraftInfoType){
    FSDraftInfoTypeVideo = 1,
    FSDraftInfoTypeRecoder,
};

@interface FSDraftInfo : NSObject<NSCoding>

@property(nonatomic,assign)FSDraftInfoType vType;  //视频来源
@property(nonatomic,strong)FSDraftMusic *vMusic;
@property(nonatomic,strong)FSVideoFxOperationStack *stack;
@property(nonatomic,strong)FSDraftChallenge *challenge;
@property(nonatomic,strong)FSDraftTimeFx *vTimefx;
@property(nonatomic,assign)BOOL vBeautyOn;
@property(nonatomic,assign)BOOL isFrontCamera;                        //是否前置
@property(nonatomic,assign)double vOriginalVolume;
@property(nonatomic,assign)double vMusicVolume;
@property(nonatomic,strong)NSString *vTitle;
@property(nonatomic,strong)NSString *vFinalPath;
@property(nonatomic,strong)NSString *vOriginalPath;
@property(nonatomic,strong)NSString *vFirstFramePath;
@property(nonatomic,assign)double vSpeed;
@property(nonatomic,strong)NSArray<NSString *> *clips;
@property(nonatomic,strong)NSString *vConvertPath;
@property(nonatomic,strong)NSString *vFilterid;
@property(nonatomic,assign)BOOL vSaveToAlbum;
@property(nonatomic,strong)NSArray<NSString *> *recordVideoPathArray;  //录制视频片段地址
@property(nonatomic,strong)NSArray<NSNumber *> *recordVideoTimeArray;  //录制视频片段时长
@property(nonatomic,strong)NSArray<NSNumber *> *recordVideoSpeedArray;  //录制视频片段速度
@property(nonatomic,strong)NSArray<UIView *> *vAddedFxViews;

-(instancetype)initWithDraftInfo:(FSDraftInfo *)draftInfo;
-(void)copyValueFromeDraftInfo:(FSDraftInfo *)draftInfo;
-(void)clearFxInfos;
@end
