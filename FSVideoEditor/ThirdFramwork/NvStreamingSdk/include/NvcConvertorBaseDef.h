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
#ifndef NvcConvertorBaseDef_h
#define NvcConvertorBaseDef_h

#include <stdint.h>

#define NVC_M_SEGMET_COMPLETE                1     //!< 注：内部使用，不作解释
#define NVC_NOERROR                          0     //!< 没有错误
#define NVC_E_FAIL                           -1    //!< 失败
#define NVC_E_FILE_EOF                       -2    //!< 文件末尾
#define NVC_E_INVALID_POINTER                -3    //!< 无效指针
#define NVC_E_INVALID_PARAMETER              -4    //!< 无效参数
#define NVC_E_NOT_INITIALIZED                -5    //!< 未初始化
#define NVC_E_NO_VIDEO_STREAM                -6    //!< 输入文件不存在视频流
#define NVC_E_CONVERTOR_IS_OPENED            -7    //!< 当前转码器已经打开
#define NVC_E_CONVERTOR_IS_STARTED           -8    //!< 正在转码


// Structure to represent a rational num/den

/*! 
 * 	\brief 比例值 
 */
struct SNvcRational {
    int num;     //!< 分子
    int den;     //!< 分母
};

/*! 
 * 	\brief 转码输出视频的分辨率高度级别 
 */
enum ENvcOutputVideoResolution {
    NvcOutputVideoResolution_NotResize = 0,    //!< 原始视频高度输出
    NvcOutputVideoResolution_360 = 1,          //!< 输出视频高度-360
    NvcOutputVideoResolution_480 = 2,          //!< 输出视频高度-480
    NvcOutputVideoResolution_720 = 3,          //!< 输出视频高度-720
    NvcOutputVideoResolution_1080 = 4,         //!< 输出视频高度-1080
};

//
// output config
//
#define NVC_OUTPUT_CONFIG_REVERSE   0x1

/*! 
 *  \brief 视频文件转码参数配置 
 */
struct SNvcOutputConfig {
    enum ENvcOutputVideoResolution videoResolution;//!< 转码输出视频高度级别类型
    float from; //!< 转换起始位置,以秒为单位
    float to; //!< 转换结束位置,以秒为单位
    uint64_t dataRate; //!< 转换后文件的码流,字节为单位
    int fpsForWebp; //!< 如果输出为WebP动画格式，需要设置帧率．最大２５，最小１
};

#endif /* NvcConvertorBaseDef_h */
