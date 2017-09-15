//
//  FSUploadImageServer.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSUploadImageServerDelegate <NSObject>

- (void)FSUploadImageServerFirstImageSucceed:(NSString *)filePath;
- (void)FSUploadImageServerFirstImageFailed:(NSError *)error;
- (void)FSUploadImageServerFirstImageProgress:(float)progess;

- (void)FSUploadImageServerWebPSucceed:(NSString *)filePath;
- (void)FSUploadImageServerWebPFailed:(NSError *)error;
- (void)FSUploadImageServerWebPProgress:(float)progess;

@end

@interface FSUploadImageServer : NSObject

@property (nonatomic, weak) id<FSUploadImageServerDelegate> delegate;

- (void)uploadFirstImage:(id)param;
- (void)uploadWebP:(id)param;

@end
