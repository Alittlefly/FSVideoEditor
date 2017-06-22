//
//  FSFileSizeDivider.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileSizeDivider.h"

@implementation FSFileSizeDivider
-(NSArray<FSFileSlice *> *)fileDividerDeviderWithFile:(FSFile *)file{
    if (_divideSize == 0) {
        _divideSize = 8*8;
    }
    NSData *allData = [NSData dataWithContentsOfFile:file.filePath];
    NSUInteger dataLength = allData.length;
    NSUInteger lastLength = dataLength % _divideSize;
    NSUInteger trunks = (dataLength - lastLength)/_divideSize;
    
    NSMutableArray *files = [NSMutableArray array];
    for (NSUInteger offset = 0; offset < trunks; offset ++) {
        FSFileSlice *offsetFile = [[FSFileSlice alloc] init];
        offsetFile.fileSize = _divideSize;
        offsetFile.totalSize = dataLength;
        offsetFile.fileTrunk = offset;
        offsetFile.trunks = trunks;
        offsetFile.fileRange = NSMakeRange(offset * _divideSize, _divideSize - 1);
        offsetFile.fileId = offset;
        offsetFile.fileName = [file.filePath lastPathComponent];
        offsetFile.fileInfo = file.fileInfo;
        offsetFile.filePath = file.filePath;
        offsetFile.author = file.author;
        offsetFile.creatDate = file.creatDate;
        [files addObject:offsetFile];
    }
    
    if (lastLength != 0) {
        // 取余 也算一片
        FSFileSlice *offsetFile = [[FSFileSlice alloc] init];
        offsetFile.fileSize = lastLength;
        offsetFile.fileTrunk = trunks ;
        offsetFile.trunks = trunks ;
        offsetFile.fileRange = NSMakeRange(trunks * _divideSize, lastLength - 1);
        offsetFile.fileId = trunks;
        offsetFile.totalSize = dataLength;
        offsetFile.fileName = file.fileName;
        offsetFile.author = file.author;
        offsetFile.creatDate = file.creatDate;
        [files addObject:offsetFile];
    }
    
    return files;
}
-(NSArray<FSFileSlice *> *)fileDividerDeviderWithFilePath:(NSString *)filePath{
    
    if (_divideSize == 0) {
        _divideSize = 16.0*16.0;
    }
    NSData *allData = [NSData dataWithContentsOfFile:filePath];
    NSUInteger dataLength = allData.length;
    NSUInteger lastLength = dataLength % _divideSize;
    NSUInteger trunks = (dataLength - lastLength)/_divideSize;
    NSString *arch_name = [NSString stringWithFormat:@"%u_",arc4random_uniform(10000)];
    
    NSString *fileName = [arch_name stringByAppendingString:[filePath lastPathComponent]];
 
    NSMutableArray *files = [NSMutableArray array];
    for (NSUInteger offset = 0; offset < trunks; offset ++) {
        FSFileSlice *offsetFile = [[FSFileSlice alloc] init];
        offsetFile.fileSize = _divideSize;
        offsetFile.totalSize = dataLength;
        offsetFile.fileTrunk = offset;
        offsetFile.trunks = trunks;
        offsetFile.fileRange = NSMakeRange(offset * _divideSize, _divideSize - 1);
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
        offsetFile.fileRange = NSMakeRange(trunks * _divideSize, lastLength - 1);
        offsetFile.fileId = trunks;
        offsetFile.totalSize = dataLength;
        offsetFile.fileName = fileName;
        [files addObject:offsetFile];
    }
    
    return files;
}
@end
