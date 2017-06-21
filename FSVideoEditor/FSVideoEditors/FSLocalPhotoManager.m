//
//  FSLocalPhotoManager.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSLocalPhotoManager.h"

@implementation FSLocalPhotoManager
-(NSArray *)photosWithType:(PHAssetSourceType)type{

    NSMutableArray *assetArray = [NSMutableArray array];
    
    PHFetchOptions *option = [PHFetchOptions new];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithMediaType:(PHAssetMediaTypeVideo) options:option];
    
    for (PHAsset *asset in fetchResult) {
        NSLog(@"asset %@",asset);
        [assetArray addObject:asset];
    }
    
    //    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:(PHAssetCollectionTypeSmartAlbum) subtype:(PHAssetCollectionSubtypeSmartAlbumVideos) options:option];

//    for (PHAssetCollection *collection in fetchResult) {
//        PHFetchResult *assetsInCollection = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
//        NSLog(@"collection ====-----===== %@",collection);
//    }
    
    return assetArray;
}
@end
