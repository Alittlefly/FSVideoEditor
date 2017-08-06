//
//  FSShortVideoRecorderController.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSShortLanguage.h"

@class FSDraftInfo;
@interface FSShortVideoRecorderController : UIViewController

@property (nonatomic, copy) NSString *musicFilePath;
@property (nonatomic, assign) BOOL isPresented;
@property (nonatomic, strong) FSDraftInfo *draftInfo;

@end
