//
//  FSDraftMusic.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDraftMusic : NSObject
@property(nonatomic,strong)NSString *mPath;
@property(nonatomic,assign)int mId;
@property(nonatomic,assign)int64_t mInPoint;
@property(nonatomic,assign)int64_t mOutPoint;
@end
