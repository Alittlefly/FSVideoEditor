//
//  FSPublishView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FSPublishView;
@protocol FSPublishViewDelegate <NSObject>

-(void)publishViewClickVideoFx:(FSPublishView *)publish;

@end

@interface FSPublishView : UIView
@property(nonatomic,assign)id<FSPublishViewDelegate>delegate;
@end
