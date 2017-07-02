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
@property(nonatomic,assign)NSInteger songId;
@property(nonatomic,assign)NSInteger songIndex;
@property(nonatomic,copy)NSString *songAuthor;
@property(nonatomic,strong)NSString *songPic;
@property(nonatomic,copy)NSString *songTitle;
@property(nonatomic,copy)NSString *songUrl;

@property(nonatomic,assign)BOOL opend;
@property(nonatomic,assign)BOOL isPlaying;
@end
