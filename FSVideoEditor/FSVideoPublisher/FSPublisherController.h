//
//  FSPublisherController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVideoFxController.h"
#import "FSPublisherToolView.h"
#import "NvsLiveWindow.h"

@class FSDraftInfo;

@interface FSPublisherController : UIViewController

@property (nonatomic,assign) NvsTimeline *timeLine;
@property (nonatomic,assign) CGFloat playSpeed;
@property (nonatomic,copy)   NSString *musicPath;
@property (nonatomic, assign) NSInteger musicId;
@property (nonatomic,assign) NSTimeInterval musicStartTime;


@property(nonatomic,strong)FSDraftInfo *draftInfo;
@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property (nonatomic, strong) FSPublisherToolView *toolView;

@end
