//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Aug 28. 2017
//   Author:        NewAuto video team
//================================================================================
#pragma once

#import "NvsCommonDef.h"
#import <UIKit/UIScrollView.h>


@interface NvsThumbnailSequenceDesc : NSObject

@property (nonatomic) NSString *mediaFilePath;
@property (nonatomic) int64_t inPoint;
@property (nonatomic) int64_t outPoint;
@property (nonatomic) int64_t trimIn;
@property (nonatomic) int64_t trimOut;
@property (nonatomic) BOOL stillImageHint;

@end


/*!
    \brief 多缩略图序列

    多缩略图序列，可以显示一个时间线内多个片段的缩略图序列。支持缩略图时间比例尺的调节，当有效内容超长时支持滚动浏览。

    \since 1.10.0
 */
@interface NvsMultiThumbnailSequenceView : UIScrollView

@property (nonatomic) NSArray *descArray;           //!< 缩略图序列描述数组。注意：一旦设置，再修改数组里面的内容是不起作用的，除非再次设置缩略图序列描述数组
@property (nonatomic) CGFloat thumbnailAspectRatio; //!< 缩略图横纵比
@property (nonatomic) double pointsPerMicrosecond;  //!< 比例尺，每微秒所占用的point数量
@property (nonatomic) CGFloat startPadding;         //!< 起始边距，单位为point
@property (nonatomic) CGFloat endPadding;           //!< 结束边距，单位为point

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/*!
 *  \brief 将控件的X坐标映射到时间线位置
 *  \param x 控件的X坐标，单位为point
 *  \return 返回映射的时间线位置，单位为微秒
 *  \sa mapXFromTimelinePos
 */
- (int64_t)mapTimelinePosFromX:(CGFloat)x;

/*!
 *  \brief 将时间线位置映射到控件的X坐标
 *  \param timelinePos 时间线位置，单位为微秒
 *  \return 返回映射的控件的X坐标，单位为point
 *  \sa mapTimelinePosFromX
 */
- (CGFloat)mapXFromTimelinePos:(int64_t)timelinePos;

/*!
 *  \brief 缩放当前比例尺
 *  \param scaleFactor 缩放的比例
 *  \param anchorX 缩放的锚点X坐标，单位为point
 */
- (void)scale:(double)scaleFactor withAnchor:(CGFloat)anchorX;

@end

