//
//  NvConvertorBaseDef.h
//  NvConvertorLib
//
//  Created by LionLee on 17/6/8.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvConvertorBaseDef_h
#define NvConvertorBaseDef_h

#include <stdint.h>

#define NV_M_SEGMET_COMPLETE                1
#define NV_NOERROR                          0
#define NV_E_FAIL                           -1
#define NV_E_FILE_EOF                       -2
#define NV_E_INVALID_POINTER                -3
#define NV_E_INVALID_PARAMETER              -4
#define NV_E_NOT_INITIALIZED                -5
#define NV_E_NO_VIDEO_STREAM                -6
#define NV_E_CONVERTOR_IS_OPENED            -7
#define NV_E_CONVERTOR_IS_STARTED           -8


// Structure to represent a rational num/den
struct SNvRational {
    int num;    // Numerator
    int den;    // Denominator
};

//
// output config
//
#define NV_OUTPUT_CONFIG_REVERSE   0x1

struct SNvOutputConfig {
    struct SNvRational scale;
    float from; //  seconds unit
    float to; //  seconds unit
    uint64_t dataRate; // Bits per second
};

#endif /* NvConvertorBaseDef_h */
