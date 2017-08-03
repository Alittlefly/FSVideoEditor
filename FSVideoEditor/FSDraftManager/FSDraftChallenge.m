//
//  FSChallenge.m
//  FSVideoEditor
//
//  Created by Charles on 2017/8/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSDraftChallenge.h"

@implementation FSDraftChallenge

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super init]) {
        self.challengeId = [[aDecoder decodeObjectForKey:@"challengeId"] integerValue];
        self.challengeName = [aDecoder decodeObjectForKey:@"challengeName"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:[NSNumber numberWithInteger:self.challengeId] forKey:@"challengeId"];
    [aCoder encodeObject:self.challengeName forKey:@"challengeName"];
}

-(id)copyWithZone:(NSZone *)zone{
    
    FSDraftChallenge *draftChallenge = [FSDraftChallenge allocWithZone:zone];
    draftChallenge -> _challengeId = self.challengeId;
    draftChallenge -> _challengeName = self.challengeName;
    return draftChallenge;
}

@end
