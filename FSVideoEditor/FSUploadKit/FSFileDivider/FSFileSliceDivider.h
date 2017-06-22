//
//  FSFileSliceDivider.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/22.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileDivider.h"

@interface FSFileSliceDivider : FSFileDivider
@property(nonatomic,assign)NSUInteger sliceCount;
-(instancetype)initWithSliceCount:(NSUInteger)sliceCount;
@end
