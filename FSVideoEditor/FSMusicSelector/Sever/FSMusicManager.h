//
//  FSMusicManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^FSMusicDownLoadComplete)(NSString *localPath,NSError *error);

@interface FSMusicManager : NSObject

+(void)downLoadMusic:(NSString *)filePath complete:(FSMusicDownLoadComplete)complete;

+(BOOL)existWithFileName:(NSString *)fileName;

+(NSString *)musicPathWithFileName:(NSString *)fileName;
@end
