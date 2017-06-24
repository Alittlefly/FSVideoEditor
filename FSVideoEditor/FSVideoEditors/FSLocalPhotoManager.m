//
//  FSLocalPhotoManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalPhotoManager.h"

@implementation FSLocalPhotoManager

-(NSArray *)photosWithType:(PHAssetMediaType)type{
    
    
    __block NSMutableArray *assetArray = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    void (^AuthorizedHandler)(PHAuthorizationStatus status) = ^(PHAuthorizationStatus status){
        if (status != PHAuthorizationStatusAuthorized) {
            if ([weakSelf.delegate respondsToSelector:@selector(localPhotoManager:authorizedStatus:)]) {
                [weakSelf.delegate localPhotoManager:weakSelf authorizedStatus:status];
            }
            return ;
        }
        PHFetchOptions *option = [PHFetchOptions new];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:type options:option];
        
        for (PHAsset *asset in fetchResult) {
//            NSLog(@"asset %@",asset);
            [assetArray addObject:asset];
        }
    };
    

    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
         AuthorizedHandler(PHAuthorizationStatusAuthorized);
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            AuthorizedHandler(status);
        }];
    }
    
    return assetArray;
}
@end
