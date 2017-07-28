//
//  FSMusicSearchAPI.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/28.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSMusicSearchAPIDelegate <NSObject>

@optional
-(void)musicSearchAPISearchSuccess:(NSDictionary *)searchInfo;

-(void)musicSearchAPISearchFaild;

@end

@interface FSMusicSearchAPI : NSObject
{
    NSURLSessionTask *_currentTask;
}
@property(nonatomic,assign)id<FSMusicSearchAPIDelegate>delegate;
-(void)searchMusicWithText:(NSString *)text no:(NSInteger)no;

@end
