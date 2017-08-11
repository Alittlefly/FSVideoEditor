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

#define NVC_M_SEGMET_COMPLETE                1
#define NVC_NOERROR                          0
#define NVC_E_FAIL                           -1
#define NVC_E_FILE_EOF                       -2
#define NVC_E_INVALID_POINTER                -3
#define NVC_E_INVALID_PARAMETER              -4
#define NVC_E_NOT_INITIALIZED                -5
#define NVC_E_NO_VIDEO_STREAM                -6
#define NVC_E_CONVERTOR_IS_OPENED            -7
#define NVC_E_CONVERTOR_IS_STARTED           -8


// Structure to represent a rational num/den
struct SNvcRational {
    int num;    // Numerator
    int den;    // Denominator
};

enum ENvcOutputVideoResolution {
    NvcOutputVideoResolution_NotResize = 0,
    NvcOutputVideoResolution_360 = 1,
    NvcOutputVideoResolution_480 = 2,
    NvcOutputVideoResolution_720 = 3,
    NvcOutputVideoResolution_1080 = 4,
};

//
// output config
//
#define NVC_OUTPUT_CONFIG_REVERSE   0x1

struct SNvcOutputConfig {
    enum ENvcOutputVideoResolution videoResolution;
    float from; //  seconds unit
    float to; //  seconds unit
    uint64_t dataRate; // Bits per second
    int fpsForWebp;
};

#endif /* NvcConvertorBaseDef_h */
