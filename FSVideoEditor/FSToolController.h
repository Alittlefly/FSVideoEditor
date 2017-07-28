//
//  FSToolController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/3.
//  Copyright © 2017年 Fission. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FSMusic.h"

@protocol FSToolControllerDelegate <NSObject>

@optional
-(UIViewController *)musicDetailControllerWithMusic:(FSMusic *)music;

@end


@interface FSToolController : UIViewController

@property(nonatomic,assign)id<FSToolControllerDelegate>delegate;

- (void)setAPI:(NSString *)api resApi:(NSString *)resApi userName:(NSString *)name;

@end
