//
//  FSShortVideoRecorderManager.h
//  7nujoom
//
//  Created by 王明 on 2017/6/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NvsStreamingContext.h>

@interface FSShortVideoRecorderManager : NSObject

+ (instancetype)sharedInstance;


/**
 获取预览视图

 @return <#return value description#>
 */
- (NvsLiveWindow *)getLiveWindow;

/**
 切换摄像头

 @return <#return value description#>
 */
- (BOOL)switchCamera;

/**
 切换闪光灯

 @param on <#on description#>
 */
- (void)switchFlash:(BOOL)on;

@end
