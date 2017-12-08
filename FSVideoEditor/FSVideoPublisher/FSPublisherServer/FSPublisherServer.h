//
//  FSPublisherServer.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSPublisherServerDelegate <NSObject>

- (void)FSPublisherServerSucceed:(NSString *)fileUrl;
- (void)FSPublisherServerFailed:(NSError *)error;
- (void)FSPublisherServerProgress:(long long)progress;

@end

@interface FSPublisherServer : NSObject

@property (nonatomic, weak) id<FSPublisherServerDelegate> delegate;

- (void)publisherVideo:(id)param;

@end
