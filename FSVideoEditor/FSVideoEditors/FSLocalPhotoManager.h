//
//  FSLocalPhotoManager.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface FSLocalPhotoManager : NSObject
-(NSArray *)photosWithType:(PHAssetSourceType)type;
@end
