//
//  FSFileUploadTool.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/15.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSFileUploader.h"
#import "FSFileSlice.h"

@interface FSFileUploadTool : NSObject<FSFileUploaderProtocol>{
@private
    NSData *_data;
    FSFileSlice *_file;
    NSString *_filePath;
}
-(instancetype)initWithData:(NSData *)data file:(FSFileSlice *)file filePath:(NSString *)filePath;
@end
