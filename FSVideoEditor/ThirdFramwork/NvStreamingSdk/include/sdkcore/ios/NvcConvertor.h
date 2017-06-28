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

@interface NvcConvertor : NSObject{
    
  id<NvcConvertorDelegate> _delegate;     //代理
}

@property(nonatomic, strong) id<NvcConvertorDelegate> delegate;

+ (BOOL)InstallLicense:(NSString*)licenseFile;

- (instancetype)initWithMaxCacheSample:(NSInteger)maxCacheCount;
//
- (NSInteger)open:(NSString*)inputFile outputFile:(NSString*)outputPath setting:(struct SNvcOutputConfig*)config;
//
- (void)close;

- (NSInteger)start;
- (NSInteger)stop;

- (float)getProgress;

- (BOOL)IsOpened;

@end


