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

@protocol NvcConvertorDelegate <NSObject>
@optional
- (void)convertFinished;
- (void)convertFaild:(NSError *)error;
- (void)convertProgress:(int)progress;
@end

#endif /* NvcConvertorDelegate_h */
