//
//  FSLoginServer.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSLoginServerDelegate <NSObject>

- (void)FSLoginServerSucceed:(id)objec;
- (void)FSLoginServerFaild:(NSError *)error;

@end

@interface FSLoginServer : NSObject

@property (nonatomic, weak) id<FSLoginServerDelegate> delegate;

- (void)loginWithUid:(NSString *)uid password:(NSString *)password;

@end
