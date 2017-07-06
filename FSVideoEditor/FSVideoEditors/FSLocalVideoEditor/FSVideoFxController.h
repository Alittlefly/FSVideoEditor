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

@protocol FSVideoFxControllerDelegate <NSObject>

-(void)videoFxControllerSaved:(NSArray *)addedViews;

-(void)videoFxControllerTimelineFxType:(FSVideoFxType)fxType startPoint:(int64_t)startPoint duration:(int64_t)duration;

@end

@interface FSVideoFxController : UIViewController

@property(nonatomic,assign)id<FSVideoFxControllerDelegate>delegate;
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,copy)NSString *convertFilePath;
@property(nonatomic,assign)NvsTimeline *timeLine;
@property(nonatomic,strong)FSControlView *controlView;
@property(nonatomic,strong)FSVideoFxView *videoFxView;
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property(nonatomic,assign)NSTimeInterval musicAttime;
@property(nonatomic,strong)NSString *musicUrl;
@property(nonatomic,strong)NSMutableArray *addedViews;

@property(nonatomic,strong)FSVideoFxOperationStack *fxOperationStack;
@property(nonatomic,strong)NvsThumbnailSequenceView *thumBailView;
@property(nonatomic,assign)FSVideoFxType currentFxType;
@end
