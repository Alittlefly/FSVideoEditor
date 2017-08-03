//
//  FSChallenge.h
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSDraftChallenge : NSObject<NSCoding>
@property(nonatomic,assign)NSInteger challengeId;
@property(nonatomic,strong)NSString *challengeName;
@end
