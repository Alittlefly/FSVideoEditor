//
//  FSSearchBar.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/25.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface FSSearchBar : UIView

@property(nonatomic,assign)BOOL showCancle;
-(instancetype)initWithFrame:(CGRect)frame delegate:(id<UISearchBarDelegate>)delegate;

@end
