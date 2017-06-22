//
//  FSFile.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFile.h"

@implementation FSFile
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        self.fileInfo = [aDecoder decodeObjectForKey:@"fileInfo"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.fileSize = [aDecoder decodeDoubleForKey:@"fileSize"];
        self.fileType = [aDecoder decodeObjectForKey:@"fileType"];
        self.filePath = [aDecoder decodeObjectForKey:@"filePath"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeDouble:self.fileSize  forKey:@"fileSize"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.fileType forKey:@"fileType"];
    [aCoder encodeObject:self.fileInfo forKey:@"fileInfo"];
    [aCoder encodeObject:self.filePath forKey:@"filePath"];
}
@end
