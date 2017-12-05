//
//  FSLocalVideoController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVideoListView.h"
#import "FSCancleController.h"

@protocol FSLocalVideoControllerDelegate <NSObject>
- (void)FSLocalVideoControllerDidChooseOneVideo;

@end

@interface FSLocalVideoController : FSCancleController<FSVideoListViewDelegate>
@property (nonatomic, weak) id<FSLocalVideoControllerDelegate> delegate;

- (void)enterEditView;

@end
