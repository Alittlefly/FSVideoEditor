//
//  FSTimeCountdownView.m
//  7nujoom
//
//  Created by jiapeng on 16/6/7.
//  Copyright © 2016年 Fission. All rights reserved.
//

#import "FSTimeCountdownView.h"
//#import "GTCommont.h"
#import "NSString+GC.h"
#import "NSString+Time.h"

@interface FSTimeCountdownView (){
    
    dispatch_source_t _timer;
    UILabel *_timeLabel;
    UIImageView *_timeImageView;
}
@property (nonatomic ,assign) NSInteger numberSize;
@property (assign) CGFloat backViewWidth;
@end

@implementation FSTimeCountdownView

-(void)dealloc
{
    NSLog(@"FSTimeCountdownView dealloc");
}
-(void)releaseTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}
- (id)initWithFrame:(CGRect)frame timeNumber:(int)timeNumber number:(NSInteger)number{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.numberSize =number;
        //[self greatPartView];
        [self createPartImageView];
        [self begainCalculateCountdown:timeNumber];
        
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

-(void)greatPartView{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setTextAlignment:(NSTextAlignmentCenter)];
        [_timeLabel setTextColor:[UIColor blackColor]];
        [_timeLabel setBackgroundColor:[UIColor redColor]];
         _timeLabel.font =[UIFont systemFontOfSize:self.numberSize];
        [_timeLabel setFrame:self.bounds];
    }
    [self addSubview:_timeLabel];
}

- (void)createPartImageView {
    if (!_timeImageView) {
        _timeImageView = [[UIImageView alloc] init];
        _timeImageView.backgroundColor = [UIColor clearColor];
        _timeImageView.frame = self.bounds;
    }
    [self addSubview:_timeImageView];
}

-(void)begainCalculateCountdown:(int)number{
    
    if (_timer==nil) {
        __block int timeout = number; //倒计时时间
        if (timeout!=0) {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
            dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                if(timeout<=0){ //倒计时结束，关闭
                    dispatch_source_cancel(_timer);
                    _timer = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([self.delegate respondsToSelector:@selector(timeCountViewCountToZero)]) {
                            [self.delegate timeCountViewCountToZero];
                        }
                        if (self.numberSize==15) {
                            //目的是取消预告进入排行榜界面
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeDownToZeroInterVideoActivityView" object:nil];
                        }else{
                            //目的是更改排行榜内文案
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"TimeDownToZeroShouldUpdateLabel" object:nil];
                        }
                        
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSString *ctime = [NSString lastTimeWithOutZeroStartWithUnit:timeout];
                       // [_timeLabel setText:[NSString stringWithFormat:@"%d",timeout]];
                        [_timeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"countdown%d",timeout]]];
                    });
                    timeout--;
                }
            });
            
            dispatch_resume(_timer);
        }
        else {
            if ([self.delegate respondsToSelector:@selector(timeCountViewCountToZero)]) {
                [self.delegate timeCountViewCountToZero];
            }
        }
    }
    
}
@end
