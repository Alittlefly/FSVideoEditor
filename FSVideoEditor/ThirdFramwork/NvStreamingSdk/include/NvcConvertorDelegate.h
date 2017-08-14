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

#ifndef NvcConvertorDelegate_h
#define NvcConvertorDelegate_h

#import <Foundation/Foundation.h>

/*!
*  \brief 视频文件转码代理
*
*  在转码过程中可通过代理显示转码进度及转码结果。
*/
@protocol NvcConvertorDelegate <NSObject>
@optional

/*!
 *  \brief 转码完成
 */
- (void)convertFinished;

/*!
 *  \brief 转码失败
 *  \param error 错误值
 */
- (void)convertFaild:(NSError *)error;

/*!
 *  \brief 转码进度
 *  \param progress 当前进度值
 */
- (void)convertProgress:(int)progress;
@end

#endif /* NvcConvertorDelegate_h */
