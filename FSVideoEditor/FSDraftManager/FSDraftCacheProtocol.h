//
//  FSDraftCacheProtocol.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class FSDraftInfo;

@protocol FSDraftCacheProtocol <NSObject>

@optional
-(void)insertToLocal:(FSDraftInfo *)draftInfo;
-(void)deleteToLocal:(FSDraftInfo *)draftInfo;
-(void)updateToLocal:(FSDraftInfo *)draftInfo;
-(void)deleteAllLocal;
-(NSArray *)allInfosInLocal;

-(void)clearMermoryLocal;
@end
