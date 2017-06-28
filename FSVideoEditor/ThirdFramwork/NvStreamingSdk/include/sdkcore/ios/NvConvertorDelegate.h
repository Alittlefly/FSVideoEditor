//
//  NvConvertorDelegate.h
//  NvFileConvert
//
//  Created by LionLee on 17/4/26.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvConvertorDelegate_h
#define NvConvertorDelegate_h

#import <Foundation/Foundation.h>

@protocol NVConvertorDelegate <NSObject>

- (void)convertFinished;
- (void)convertFaild:(NSError *)error;

@end


#endif /* NvConvertorDelegate_h */
