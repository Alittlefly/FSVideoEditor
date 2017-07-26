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
-(void)getMusicTypes{

}
#pragma mark -
-(void)musicApiGetMusics:(id)responesObject{
    
    if ([responesObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dataDict = [(NSDictionary *)responesObject valueForKey:@"dataInfo"];
        NSArray *ms = [dataDict valueForKey:@"shl"];
        NSArray *mtps = [dataDict valueForKey:@"slb"];
        NSArray *musics = [FSMusic getDataArrayFromArray:ms];
        NSArray *musicTypes = [FSMusicType getDataArrayFromArray:mtps];
        
        if ([self.delegate respondsToSelector:@selector(musicSeverGetMusics:musicTypes:)]) {
            [self.delegate musicSeverGetMusics:musics musicTypes:musicTypes];
        }
    }
    
}

- (void)musicApiGetMusicsFaild:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(musicSeverGetFaild)]) {
        [self.delegate musicSeverGetFaild];
    }
}
@end
