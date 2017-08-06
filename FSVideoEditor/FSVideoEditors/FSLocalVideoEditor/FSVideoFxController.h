//
//  FSVideoFxController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "FSControlView.h"
#import "FSVideoFxView.h"
#import "FSVideoFxOperationStack.h"
#import "NvsThumbnailSequenceView.h"
#import "FSDraftInfo.h"
@protocol FSVideoFxControllerDelegate <NSObject>

-(void)videoFxControllerSaved:(NSArray *)addedViews fxType:(FSVideoFxType)type position:(CGFloat)position convert:(BOOL)convert;


@end

@interface FSVideoFxController : UIViewController

@property(nonatomic,assign)id<FSVideoFxControllerDelegate>delegate;


@property(nonatomic,strong)FSControlView *controlView;
@property(nonatomic,strong)FSVideoFxView *videoFxView;



@property(nonatomic,strong)FSVideoFxOperationStack *fxOperationStack;
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,strong)NSMutableArray *addedViews;
@property(nonatomic,assign)NvsTimeline *timeLine;
@property(nonatomic,strong)FSDraftInfo *draftInfo;
@property(nonatomic,strong)NvsThumbnailSequenceView *thumBailView;
@end
