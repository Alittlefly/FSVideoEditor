//
//  FSMusic.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/2.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSMusic : NSObject

/*
 createTime = 1498986357211;
 lastSeconds = 0;
 songAuthor = "\U5218\U5fb7\U534e";
 songId = 3;
 songIndex = 0;
 songPic = "group1/M00/11/E3/CgogmFlWMliALlkNAAUNoQfOmJ8181.jpg";
 songTitle = "\U5927\U6d77";
 songUrl = "group1/M00/11/E3/CgogmFlYoWOATZTmAASYvJmhk-Q395.mp3";
 */
@property(nonatomic,assign)long long createTime;
@property(nonatomic,assign)long long lastSeconds;
@property(nonatomic,assign)NSInteger songId;        //歌曲id
@property(nonatomic,assign)NSInteger songIndex;     //歌曲序号
@property(nonatomic,copy)NSString *songAuthor;      //歌曲作者
@property(nonatomic,strong)NSString *songPic;       //歌曲封面url
@property(nonatomic,copy)NSString *songTitle;       //歌曲名称
@property(nonatomic,copy)NSString *songUrl;         //歌曲url

@property(nonatomic,assign)BOOL opend;
@property(nonatomic,assign)BOOL isPlaying;

+ (NSArray *)getDataArrayFromArray:(NSArray *)array;
@end
