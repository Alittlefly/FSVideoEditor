//
//  FSLoginAPI.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSLoginAPIDelegate <NSObject>

- (void)FSLoginAPISecceed:(id)objec;
- (void)FSLoginAPIFaild:(NSError *)error;

@end

@interface FSLoginAPI : NSObject

@property (nonatomic, weak) id<FSLoginAPIDelegate> delegate;

- (void)loginWithParam:(id)param;

@end
