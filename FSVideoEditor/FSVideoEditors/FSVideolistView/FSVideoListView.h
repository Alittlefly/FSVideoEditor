//
//  FSVideoListView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/6/21.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSVideoListViewDelegate <NSObject>


@end

@interface FSVideoListView : UIView

@property(nonatomic,assign)id<FSVideoListViewDelegate>delegate;
@property(nonatomic,strong)NSArray *videos;
@end
