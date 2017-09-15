//
//  FSUploadImageServer.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/20.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSUploadImageServer.h"
#import "FSUploadImageAPI.h"

@interface FSUploadImageServer()<FSUploadImageAPIDelegate>

@property (nonatomic, strong) FSUploadImageAPI *uploadAPI;

@end

@implementation FSUploadImageServer

- (void)uploadFirstImage:(id)param {
    if (!_uploadAPI) {
        _uploadAPI = [[FSUploadImageAPI alloc] init];
        _uploadAPI.delegate = self;
    }
    
    [_uploadAPI uploadFirstImage:param];
}

- (void)uploadWebP:(id)param {
    if (!_uploadAPI) {
        _uploadAPI = [[FSUploadImageAPI alloc] init];
        _uploadAPI.delegate = self;
    }
    
    [_uploadAPI uploadWebP:param];
}

#pragma mark - FSUploadImageAPIDelegate
- (void)FSUploadImageAPIWebPFaild:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerWebPFailed:)]) {
        [self.delegate FSUploadImageServerWebPFailed:error];
    }
}

- (void)FSUploadImageAPIWebPSuccess:(NSString *)filePath {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerWebPSucceed:)]) {
        [self.delegate FSUploadImageServerWebPSucceed:filePath];
    }
}

- (void)FSUploadImageAPIWebPProgress:(float)progress {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerWebPProgress:)]) {
        [self.delegate FSUploadImageServerWebPProgress:progress];
    }
}

- (void)FSUploadImageAPIFirstImageFaild:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerFirstImageFailed:)]) {
        [self.delegate FSUploadImageServerFirstImageFailed:error];
    }
}

- (void)FSUploadImageAPIFirstImageSuccess:(NSString *)filePath {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerFirstImageSucceed:)]) {
        [self.delegate FSUploadImageServerFirstImageSucceed:filePath];
    }
}

- (void)FSUploadImageAPIFirstImageProgress:(float)progress {
    if ([self.delegate respondsToSelector:@selector(FSUploadImageServerFirstImageProgress:)]) {
        [self.delegate FSUploadImageServerFirstImageProgress:progress];
    }
}

@end
