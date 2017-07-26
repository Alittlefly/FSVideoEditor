//
//  FSMusicSelectController.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSMusic.h"

@interface FSMusicListController : UIViewController
@property(nonatomic,strong)FSMusicType *musicType;
@property(nonatomic,strong)NSMutableArray *musiceList;
@end
