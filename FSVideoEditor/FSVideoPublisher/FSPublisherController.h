//
//  FSPublisherController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVideoFxController.h"


@interface FSPublisherController : UIViewController
@property(nonatomic,copy)NSString *filePath;
@property(nonatomic,strong)NvsTimeline *timeLine;

@property(nonatomic,assign)int64_t trimIn;
@property(nonatomic,assign)int64_t trimOut;
@end
