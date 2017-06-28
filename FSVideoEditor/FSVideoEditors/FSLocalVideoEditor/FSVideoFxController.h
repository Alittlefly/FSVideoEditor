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

@interface FSVideoFxController : UIViewController
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,assign)NvsTimeline *timeLine;
@property(nonatomic,strong)FSControlView *controlView;
@property(nonatomic,strong)FSVideoFxView *videoFxView;
@property(nonatomic,strong)NvsLiveWindow *prewidow;


@end
