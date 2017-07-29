//
//  FSMusicSearchResultView.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicSearchResultView.h"
#import "FSVideoEditorCommenData.h"
#import "FSMusicCell.h"


@interface FSMusicSearchResultView ()

@end
@implementation FSMusicSearchResultView
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setTag:100];
    }
    return self;
}

@end
