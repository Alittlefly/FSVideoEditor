//
//  FSDraftWriter.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftInfo.h"
@interface FSDraftWriter : NSObject
-(void)deleteLocalDraftInfo:(FSDraftInfo *)draftInfo;
-(void)updateLocalDraftInfo:(FSDraftInfo *)draftInfo;
-(void)insertLocalDraftInfo:(FSDraftInfo *)draftInfo;
@end
