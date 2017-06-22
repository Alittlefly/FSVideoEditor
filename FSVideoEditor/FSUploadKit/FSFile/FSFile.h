//
//  FSFile.h
//  FSUploadDemo
//
//  Created by Charles on 2017/3/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FSFile : NSObject<NSCoding>

@property (nonatomic,copy)NSString* fileType;//image or movie

@property (nonatomic,copy)NSString* fileName;//文件名

@property (nonatomic,assign)double fileSize;//文件大小

@property (nonatomic,copy)NSString* fileInfo; //简介

@property (nonatomic,copy)NSString* author; //作者

@property (nonatomic,copy)NSString* creatDate; //创建日期

@property (nonatomic,copy)NSString* filePath; //本地文件路径

@end
