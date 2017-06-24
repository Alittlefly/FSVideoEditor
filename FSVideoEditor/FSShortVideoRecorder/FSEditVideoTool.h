//
//  FSEditVideoTool.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/23.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSEditVideoTool;

typedef enum {
    FSEditVideoToolDerection_Horizontal = 0,
    FSEditVideoToolDerection_Vertical,
}FSEditVideoToolDerection;

@protocol FSEditVideoToolDelegate <NSObject>

- (void)FSEditVideoToolSelect:(FSEditVideoTool *)toolView index:(NSInteger)index;

@end

@interface FSEditVideoTool : UIView

@end
