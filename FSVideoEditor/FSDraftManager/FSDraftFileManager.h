//
//  FSDraftFileManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface FSDraftFileManager : NSObject
+(NSString *)draftDataPathKey:(NSString *)key;
+(void)deleteFile:(NSString *)filePath;

+(NSString *)saveImageTolocal:(UIImage *)image;
@end
