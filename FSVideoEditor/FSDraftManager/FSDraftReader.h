//
//  FSDraftReader.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftInfo.h"
@interface FSDraftReader : NSObject
-(NSArray<FSDraftInfo *> *)allDraftInfoInLocal;
-(void)clearMemoryDrafts;
@end
