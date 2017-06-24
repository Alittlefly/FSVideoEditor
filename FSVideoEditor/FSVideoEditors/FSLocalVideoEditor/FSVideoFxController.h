//
//  FSVideoFxController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"

@interface FSVideoFxController : UIViewController
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,assign)NvsTimeline *timeLine;

@end
