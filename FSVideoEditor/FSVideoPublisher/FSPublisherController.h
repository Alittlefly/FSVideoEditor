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

@interface FSPublisherController : UIViewController
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,assign)NvsTimeline *timeLine;

@property(nonatomic,assign)int64_t trimIn;
@property(nonatomic,assign)int64_t trimOut;

@property(nonatomic,strong)NvsLiveWindow *prewidow;
@property (nonatomic, strong) FSPublisherToolView *toolView;


@end
