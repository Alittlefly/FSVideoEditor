//
//  FSVideoPublisher.h
//  FSVideoEditor
//
//  Created by Charles on 2017/9/8.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FSDraftInfo.h"

@protocol FSVideoPublisherDelegate <NSObject>

-(void)videoPublisherProgress:(CGFloat)progress;

-(void)videoPublisherSuccess;

-(void)videoPublisherFaild;

@end

@interface FSVideoPublishParam : NSObject
@property(nonatomic,strong)UIImage *firstImageData;
@property(nonatomic,strong)NSString *webpPath;
@property(nonatomic,strong)NSString *videoPath;
@property(nonatomic,strong)NSString *videoPathWithLogo;
@property(nonatomic,strong)FSDraftInfo *draftInfo;
@end


@interface FSVideoPublisher : NSObject

@property(nonatomic,assign)id<FSVideoPublisherDelegate>delegate;

+(instancetype)sharedPublisher;

// 发布 视频文件
-(void)publishVideo:(FSVideoPublishParam *)param;

// 杀应用 要删除一下file
// -(void)terminate;
@end
