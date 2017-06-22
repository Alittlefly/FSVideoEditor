//
//  FSFileSlice.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/13.
//  Copyright © 2017年 Fission. All rights reserved.
//


#import "FSFile.h"

@interface FSFileSlice : FSFile


//@property (nonatomic,strong)UIImage* fileImage;//文件缩略图
@property (nonatomic,assign)NSInteger trunks;//总片数

@property (nonatomic,assign)NSUInteger fileTrunk;//文件位置

@property (nonatomic,assign)NSRange fileRange;

@property (nonatomic,assign)NSInteger fileId; //id;

@property (nonatomic,assign)long long totalSize;

@property (nonatomic,assign)BOOL state;

+(FSFileSlice *)fileWithfilePath:(NSString *)filePath;
@end
