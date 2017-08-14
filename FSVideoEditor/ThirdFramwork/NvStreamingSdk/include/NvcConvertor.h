//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    June 28. 2017
//   Author:        NewAuto video team
//================================================================================
#pragma once

#include "NvcConvertorBaseDef.h"
#include "NvcConvertorDelegate.h"
#import <Foundation/Foundation.h>

/*!
*  \brief 视频文件转码
*
*  视频文件转码，是通过设置待转码视频文件的路径，打开视频文件，然后开启视频转码并输出转码的视频文件的过程。视频转码分为正向转码，反向转码。转码的结果是生成.mov或者.webp格式的视频文件。同时在转码过程中可通过代理显示转码进度及转码结果。
*/
@interface NvcConvertor : NSObject{
    
  id<NvcConvertorDelegate> _delegate;
}

@property(nonatomic, strong) id<NvcConvertorDelegate> delegate;  //!<代理

/*!
 *  \brief 安装许可
 *  \param licenseFile 许可文件
 *  \return 返回BOOL值。值为true,则安装成功，否则安装失败。
 */
+ (BOOL)InstallLicense:(NSData*)licenseFile;

/*!
 *  \brief 通过最大缓存数初始化
 *  \param maxCacheCount 最大缓存数
 *  \return 返回instancetype类型，表示返回类对象
 */
- (instancetype)initWithMaxCacheSample:(NSInteger)maxCacheCount;

/*!
 *  \brief 设置纯I帧
 *  \param iFrameOnly 是否设置纯I帧
 */
- (void)setIFrameOnly:(BOOL)iFrameOnly;

/*!
 *  \brief 打开转码视频文件
 *  \param inputFile 待转码文件路径
 *  \param outputPath 要转码输出的文件。注：转码可输出.webp或者.mov文件。
 *  \param config 转码参数配置对象
 *  \return 返回NSInteger值，表示文件打开的状态值。
 */
- (NSInteger)open:(NSString*)inputFile outputFile:(NSString*)outputPath setting:(struct SNvcOutputConfig*)config;

/*!
 *  \brief 文件关闭
 */
- (void)close;

/*!
 *  \brief 开启转码
 *  \return 返回NSInteger值，表示文件转码开启的状态值。
 */
- (NSInteger)start;

/*!
 *  \brief 停止转码
 *  \return 返回NSInteger值，表示文件转码停止的状态值。
 */
- (NSInteger)stop;

/*!
 *  \brief 获取转码进度值
 *  \return 返回double值。表示文件转码进度值。
 */
- (float)getProgress;

/*!
 *  \brief 当前转码器已经开启转码状态
 *  \return 返回BOOL值, 表示转码器是否已经开启转码。值为TRUE, 则转码器正在转码，否则开启转码。
 */
- (BOOL)IsOpened;

@end


