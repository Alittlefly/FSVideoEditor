//
//  FSDraftFileManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftFileManager.h"

@implementation FSDraftFileManager
-(void)deleteFile:(NSString *)filePath{
    // 如果文件不存在就不继续执行
    BOOL *isDirt = NULL;
    BOOL exist  = [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:isDirt];
    if (exist ) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}
+(NSString *)draftDataPath{
    NSString *name = @"draft.archiver";
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documents stringByAppendingPathComponent:name];
    return path;
}
@end
