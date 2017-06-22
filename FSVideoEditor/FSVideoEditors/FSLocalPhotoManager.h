//
//  FSLocalPhotoManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@class FSLocalPhotoManager;
@protocol FSLocalPhotoManagerDelegate <NSObject>
@optional
-(void)localPhotoManager:(FSLocalPhotoManager *)manager authorizedStatus:(PHAuthorizationStatus)status;

@end

@interface FSLocalPhotoManager : NSObject
@property(nonatomic,assign)id<FSLocalPhotoManagerDelegate>delegate;
-(NSArray *)photosWithType:(PHAssetMediaType)type;
@end
