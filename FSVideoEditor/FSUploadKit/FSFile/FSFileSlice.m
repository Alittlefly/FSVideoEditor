
//
//  FSFileSlice.m
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileSlice.h"
@interface FSFileSlice()
@end
@implementation FSFileSlice
+(FSFileSlice *)fileWithfilePath:(NSString *)filePath{
    FSFileSlice *slice = [[FSFileSlice alloc] init];
    slice.filePath = filePath;
    return slice;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        self.fileRange = NSRangeFromString([aDecoder decodeObjectForKey:@"fileRange"]);
        self.totalSize = [aDecoder decodeIntegerForKey:@"totalSize"];
        self.fileTrunk = [aDecoder decodeIntegerForKey:@"fileTrunk"];
        self.trunks = [aDecoder decodeIntegerForKey:@"trunks"];
        self.fileId = [aDecoder decodeIntegerForKey:@"fileId"];
        
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:NSStringFromRange(self.fileRange) forKey:@"fileRange"];
    [aCoder encodeInteger:self.fileTrunk forKey:@"fileTrunk"];
    [aCoder encodeInteger:self.trunks forKey:@"trunks"];
    [aCoder encodeInteger:self.fileId  forKey:@"fileId"];
    [aCoder encodeInteger:self.totalSize  forKey:@"totalSize"];
}
@end
