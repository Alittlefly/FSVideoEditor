//
//  FSDraftMusic.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSMusic.h"
#import "FSMusicManager.h"

@interface FSDraftMusic : NSObject<NSCoding,NSCopying>
@property(nonatomic,strong)NSString *mUrl;
@property(nonatomic,strong)NSString *mPath;
@property(nonatomic,assign)NSInteger mId;
@property(nonatomic,assign)int64_t mInPoint;
@property(nonatomic,assign)int64_t mOutPoint;
@property(nonatomic,strong)NSString *mAutor;
@property(nonatomic,strong)NSString *mName;
@property(nonatomic,strong)NSString *mPic;
-(instancetype)initWithMusic:(FSMusic *)music;
@end
