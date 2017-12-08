//
//  FSPublisherAPI.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/7.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSPublisherAPIDelegate <NSObject>

- (void)FSPublisherAPISucceed:(NSString*)fileUrl;
- (void)FSPublisherAPIFailed:(NSError *)error;
- (void)FSPublisherAPIProgress:(long long)progress;

@end

@interface FSPublisherAPI : NSObject

@property (nonatomic, weak) id<FSPublisherAPIDelegate> delegate;

- (void)publisherVideo:(id)param;

@end
