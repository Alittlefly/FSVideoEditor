//
//  FSMusic.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMusic : NSObject
@property(nonatomic,assign)NSString *name;
@property(nonatomic,strong)NSString *path;
@property(nonatomic,strong)NSString *pic;
@property(nonatomic,assign)long long time;
@property(nonatomic,strong)NSString *author;

@property(nonatomic,assign)BOOL opend;
@property(nonatomic,assign)BOOL isPlaying;
@end
