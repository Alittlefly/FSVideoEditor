//
//  FSFileSliceDivider.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/22.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileSliceDivider.h"

@implementation FSFileSliceDivider
-(instancetype)initWithSliceCount:(NSUInteger)sliceCount{
    if (self = [super init]) {
        _sliceCount = sliceCount;
    }
    return self;
}
-(NSArray<FSFileSlice *> *)fileDividerDeviderWithFilePath:(NSString *)filePath{
    if (_sliceCount == 0) {
        _sliceCount = 1;
    }
    NSFileHandle *handler = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *allData = [handler readDataToEndOfFile];
    NSUInteger dataLength = allData.length;

    NSUInteger avgDataLength = dataLength/_sliceCount;

    NSUInteger lastLength = dataLength - avgDataLength * _sliceCount;

    NSUInteger trunks = _sliceCount;
    NSString *arch_name = [NSString stringWithFormat:@"%u_",arc4random_uniform(10000)];
    
    NSString *fileName = [arch_name stringByAppendingString:[filePath lastPathComponent]];
    
    NSMutableArray *files = [NSMutableArray array];
    for (NSUInteger offset = 0; offset < trunks; offset ++) {
        FSFileSlice *offsetFile = [[FSFileSlice alloc] init];
        offsetFile.fileSize = avgDataLength;
        offsetFile.totalSize = dataLength;
        offsetFile.fileTrunk = offset;
        offsetFile.trunks = trunks;
        offsetFile.fileRange = NSMakeRange(offset * avgDataLength, avgDataLength - 1);
        offsetFile.fileId = offset;
        offsetFile.fileName = fileName;
        [files addObject:offsetFile];
    }
    
    if (lastLength != 0) {
        // 取余 也算一片
        FSFileSlice *offsetFile = [[FSFileSlice alloc] init];
        offsetFile.fileSize = lastLength;
        offsetFile.fileTrunk = trunks ;
        offsetFile.trunks = trunks ;
        offsetFile.fileRange = NSMakeRange(trunks * avgDataLength, lastLength - 1);
        offsetFile.fileId = trunks;
        offsetFile.totalSize = dataLength;
        offsetFile.fileName = fileName;
        [files addObject:offsetFile];
    }
    
    
    return files;
}
@end
