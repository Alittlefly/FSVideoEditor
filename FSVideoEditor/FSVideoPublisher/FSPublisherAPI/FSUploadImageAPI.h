//
//  FSUploadImageAPI.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSUploadImageAPIDelegate <NSObject>

- (void)FSUploadImageAPIFirstImageSuccess:(NSString *)filePath;
- (void)FSUploadImageAPIFirstImageFaild:(NSError *)error;
- (void)FSUploadImageAPIFirstImageProgress:(float)progress;

- (void)FSUploadImageAPIWebPSuccess:(NSString *)filePath;
- (void)FSUploadImageAPIWebPFaild:(NSError *)error;
- (void)FSUploadImageAPIWebPProgress:(float)progress;


@end

@interface FSUploadImageAPI : NSObject

@property (nonatomic, weak) id<FSUploadImageAPIDelegate> delegate;

- (void)uploadFirstImage:(id)param;
- (void)uploadWebP:(id)param;

@end
