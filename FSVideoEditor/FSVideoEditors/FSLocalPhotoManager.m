//
//  FSLocalPhotoManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalPhotoManager.h"

@implementation FSLocalPhotoManager

-(void)photosWithType:(PHAssetMediaType)type{
    
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([weakSelf.delegate respondsToSelector:@selector(localPhotoManager:localVideos:)]) {
                [weakSelf.delegate localPhotoManager:weakSelf localVideos:assetArray];
            }
        });
    };
    

    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
         AuthorizedHandler(PHAuthorizationStatusAuthorized);
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            AuthorizedHandler(status);
        }];
    }
}
@end
