//
//  FSChallengeDataServer.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSChallengeDataServer.h"
#import "FSSearchChallengeAPI.h"
#import "FSAddChallengeAPI.h"
#import "FSPublishSingleton.h"

@interface FSChallengeDataServer()<FSSearchChallengeAPIDelegate, FSAddChallengeAPIDelegate>

@property (nonatomic, strong) FSSearchChallengeAPI *searchApi;

@property (nonatomic, strong) FSAddChallengeAPI *addChallengeApi;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSMutableArray *searchDataArray;

@property (nonatomic, strong) FSChallengeModel *challengeModel;

@property (nonatomic, assign) BOOL isSearch;

@end

@implementation FSChallengeDataServer

- (instancetype)init {
    if (self = [super init]) {
        _dataArray = [NSArray array];
        _searchDataArray = [NSMutableArray arrayWithCapacity:0];
        _isSearch = NO;
    }
    return self;
}

- (void)requestChallengeDataList:(id)param isSearch:(BOOL)isSearch {
    _isSearch = isSearch;
    if (!_searchApi) {
        _searchApi = [[FSSearchChallengeAPI alloc] init];
        _searchApi.delegate = self;
    }
    [_searchApi searchChallenge:param];

}

- (void)addNewChallenge:(FSChallengeModel *)model {
    _challengeModel = model;
    
    if (!_addChallengeApi) {
        _addChallengeApi = [[FSAddChallengeAPI alloc] init];
        _addChallengeApi.delegate = self;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:model.name, @"dn", model.content, @"dd", [FSPublishSingleton sharedInstance].loginKey, @"loginKey", nil];
    [_addChallengeApi addNewChallenge:dic];
}

#pragma mark - FSSearchChallengeAPIDelegate
-(void)FSSearchChallengeAPISucceed:(NSDictionary *)dic {
    NSArray *array = [FSChallengeModel getDataArrayFromArray:[[dic objectForKey:@"dataInfo"] objectForKey:@"list"]];
    if (_isSearch) {
        BOOL isNew = YES;
        for (FSChallengeModel *model in array) {
            for (FSChallengeModel *oldModel in _searchDataArray) {
                if (oldModel.challengeId == model.challengeId) {
                    isNew = NO;
                    break;
                }
            }
            if (isNew) {
                [_searchDataArray addObject:model];
            }
        }
        if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerSucceed:)]) {
            [self.delegate FSChallengeDataServerSucceed:_searchDataArray];
        }
    }
    else {
        _dataArray = array;
        if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerSucceed:)]) {
            [self.delegate FSChallengeDataServerSucceed:_dataArray];
        }
    }

}

- (void)FSSearchChallengeAPIFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerFailed:)]) {
        [self.delegate FSChallengeDataServerFailed:error];
    }
}

#pragma mark - FSAddChallengeAPIDelegate
- (void)FSAddChallengeAPIAddChallengeSucceed:(NSDictionary *)dataInfo {
    NSInteger challengeId = [[dataInfo objectForKey:@"dataInfo"] integerValue];
    _challengeModel.challengeId = challengeId;
    
    if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerAddChallengeSucceed:)]) {
        [self.delegate FSChallengeDataServerAddChallengeSucceed:_challengeModel];
    }
}

- (void)FSAddChallengeAPIAddChallengeFailed:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerAddChallengeFailed:)]) {
        [self.delegate FSChallengeDataServerAddChallengeFailed:error];
    }
}

- (void)FSAddChallengeAPIAddChallengeCode:(NSInteger)code {
    if ([self.delegate respondsToSelector:@selector(FSChallengeDataServerAddChallengeCode:)]) {
        [self.delegate FSChallengeDataServerAddChallengeCode:code];
    }
}

@end
