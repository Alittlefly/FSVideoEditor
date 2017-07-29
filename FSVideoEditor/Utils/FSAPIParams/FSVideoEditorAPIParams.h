//
//  FSVideoEditorAPIParams.h
//  FSVideoEditor
//
//  Created by Charles on 2017/7/27.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSVideoEditorAPIParams : NSObject
@property(nonatomic,copy)NSMutableDictionary *params;
+(instancetype)videoEdiorParams;
@end
