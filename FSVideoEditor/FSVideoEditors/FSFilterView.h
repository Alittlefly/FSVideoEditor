//
//  FSFilterView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSFilterViewDelegate <NSObject>

- (void)FSFilterViewChooseFilter:(NSString *)filter;
- (void)FSFilterViewFinishedChooseFilter;

@end

@interface FSFilterView : UIView

@property (nonatomic, weak) id<FSFilterViewDelegate> delegate;

@end
