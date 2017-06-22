//
//  FSFileDivider.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileSlice.h"

@protocol FSFileDividerProtocol <NSObject>
@optional
-(NSArray<FSFileSlice *> *)fileDividerDeviderWithFilePath:(NSString *)filePath;

-(NSArray<FSFileSlice *> *)fileDividerDeviderWithFile:(FSFile *)file;
@end

@interface FSFileDivider : NSObject<FSFileDividerProtocol>
+(instancetype)divider;
@end
