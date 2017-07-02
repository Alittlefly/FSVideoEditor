//
//  FSMusicSever.m
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicSever.h"
#import "FSMusicAPI.h"
#import "MJExtension.h"
@interface FSMusicSever()<FSMusicAPIDelegate>
{
    FSMusicAPI *_Api;
}
@end
@implementation FSMusicSever
-(void)getMusicList{
    if (_Api) {
        [_Api cancleTask];
    }
    
     _Api = [[FSMusicAPI alloc] init];
    [_Api setDelegate:self];
    [_Api getMusicWithParam:nil];
}
#pragma mark -
-(void)musicApiGetMusics:(id)responesObject{
    
    if ([responesObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDict = (NSDictionary *)responesObject;
        NSArray *ms = [dataDict valueForKey:@"dataInfo"];
        
        NSArray *musics = [FSMusic mj_objectArrayWithKeyValuesArray:ms];
        
        if ([self.delegate respondsToSelector:@selector(musicSeverGetMusics:)]) {
            [self.delegate musicSeverGetMusics:musics];
        }
    }
    
}
@end
