//
//  FSMusicSearchResultView.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/26.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSMusicSearchResultView : UIView
@property(nonatomic,assign)id<UITableViewDelegate>delagate;
@property(nonatomic,strong)NSArray *musics;
@end
