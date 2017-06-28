//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2014. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Mar 26. 2014
//   Author:        NewAuto video team
//================================================================================
#pragma once

#include "NvConvertorBaseDef.h"
#include "NvConvertorDelegate.h"
#import <Foundation/Foundation.h>

@interface NVConvertor : NSObject{
    
  id<NVConvertorDelegate> _delegate;     //代理
}

@property(nonatomic, strong) id<NVConvertorDelegate> delegate;

+ (BOOL)InstallLicense:(NSString*)licenseFile;

- (instancetype)initWithMaxCacheSample:(NSInteger)maxCacheCount;
//
- (NSInteger)open:(NSString*)inputFile outputFile:(NSString*)outputPath setting:(struct SNvOutputConfig*)config;
//
- (void)close;

- (NSInteger)start;
- (NSInteger)stop;

- (float)getProgress;

- (BOOL)IsOpened;

@end


