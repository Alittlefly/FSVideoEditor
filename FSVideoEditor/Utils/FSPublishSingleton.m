//
//  FSPublishSingleton.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSPublishSingleton.h"

static FSPublishSingleton *publishSingleton = nil;

@implementation FSPublishSingleton

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        publishSingleton = [[FSPublishSingleton alloc] init];
    });
    return publishSingleton;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)cleanData {
    _chooseMusic = nil;
    _chooseChallenge = nil;
}

@end
