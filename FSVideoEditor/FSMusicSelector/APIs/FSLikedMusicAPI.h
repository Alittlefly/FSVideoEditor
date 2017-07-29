//
//  FSLikedMusicAPI.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FSVideoEditorCommenData.h"

@protocol FSLikedMusicAPIDelegate <NSObject>

-(void)likedMusicApigetMusics:(NSDictionary *)responseObjct;
-(void)likedMusicApiGetFaild;
@end

@interface FSLikedMusicAPI : NSObject
{
    NSURLSessionTask *_currentTask;
}
@property(nonatomic,assign)id<FSLikedMusicAPIDelegate>delegate;
-(void)getCollectedMusics:(NSInteger)no;
@end
