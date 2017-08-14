//
//  FSDraftCache.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSDraftCacheProtocol.h"
#import "FSDraftInfo.h"

@interface FSDraftCache : NSObject<FSDraftCacheProtocol>
@property(nonatomic,strong)NSString *cacheKey;
+(instancetype)sharedDraftCache;
@end
