//
//  FSEditVideoNameView.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/6/24.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FSEditVideoNameViewDelegate <NSObject>

- (void)FSEditVideoNameViewAddChallenge;
- (void)FSEditVideoNameViewSaveToPhotoLibrary:(BOOL)isSave;
- (void)FSEditVideoNameViewEditVideoTitle:(NSString *)title;

@end

@interface FSEditVideoNameView : UIView

@property (nonatomic, weak) id<FSEditVideoNameViewDelegate> delegate;

- (void)hiddenKeyBorde;
- (void)updateChallengeName:(NSString *)name;

@end
