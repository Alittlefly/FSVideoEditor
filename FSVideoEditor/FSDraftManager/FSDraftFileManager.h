//
//  FSDraftFileManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDraftFileManager : NSObject
+(NSString *)draftDataPath;
+(void)deleteFile:(NSString *)filePath;
@end
