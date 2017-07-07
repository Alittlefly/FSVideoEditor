//
//  FSPublisherServer.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublisherServer.h"
#import "FSPublisherAPI.h"

@interface FSPublisherServer()<FSPublisherAPIDelegate>

@property (nonatomic, strong) FSPublisherAPI *publisherAPI;

@end

@implementation FSPublisherServer

- (void)publisherVideo:(id)param {
    if (!_publisherAPI) {
        _publisherAPI = [[FSPublisherAPI alloc] init];
        _publisherAPI.delegate = self;
    }
    
    [_publisherAPI publisherVideo:param];
}

#pragma mark - FSPublisherAPIDelegate
- (void)FSPublisherAPISucceed {
    if ([self.delegate respondsToSelector:@selector(FSPublisherServerSucceed)]) {
        [self.delegate FSPublisherServerSucceed];
    }
}

- (void)FSPublisherAPIFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSPublisherServerFailed:)]) {
        [self.delegate FSPublisherServerFailed:error];
    }
}

@end
