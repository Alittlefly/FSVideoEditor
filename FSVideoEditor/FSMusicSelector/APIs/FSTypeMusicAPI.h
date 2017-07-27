//
//  FSTypeMusicAPI.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSTypeMusicAPIDelegate <NSObject>

@optional
-(void)typeMusicApiGetMusics:(NSDictionary *)dictionary;
-(void)typeMusicApiGetFaild;

@end

@interface FSTypeMusicAPI : NSObject
@property(nonatomic,assign)id<FSTypeMusicAPIDelegate>delegate;
-(void)getTypeMusics:(NSInteger)type;
-(void)cancleTask;
@end
