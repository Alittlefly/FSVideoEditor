//
//  FSAlertView.m
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/5.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSAlertView.h"
#import "FSVideoEditorCommenData.h"

@interface FSAlertView()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation FSAlertView

- (instancetype)init {
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.userInteractionEnabled = NO;
        [self addSubview:bgView];
        
        [self createBaseUI];
    }
    return self;
}

- (void)createBaseUI {
    _contentView = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width-270)/2, self.frame.size.height/2, 270, 0)];
    _contentView.backgroundColor = FSHexRGBAlpha(0x000000, 0.5);
    _contentView.layer.cornerRadius = 5;
    [self addSubview:_contentView];
    
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _contentView.frame.size.width-20, 0)];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.font = [UIFont systemFontOfSize:15];
    _messageLabel.textColor = [UIColor whiteColor];
    _messageLabel.textAlignment = NSTextAlignmentCenter;
    _messageLabel.numberOfLines = 0;
    [_contentView addSubview:_messageLabel];
}

- (void)showWithMessage:(NSString *)message {
    if (message == nil || message.length == 0) {
        return;
    }
    
    _messageLabel.text = message;
    [_messageLabel sizeToFit];
    _messageLabel.frame = CGRectMake(10, 10, _messageLabel.frame.size.width, _messageLabel.frame.size.height);
    
    _contentView.frame = CGRectMake((self.frame.size.width-270)/2, (self.frame.size.height-(_messageLabel.frame.size.height+20))/2, _contentView.frame.size.width, _messageLabel.frame.size.height+20);
    
    _messageLabel.center = CGPointMake(_contentView.frame.size.width/2, _contentView.frame.size.height/2);
    
    [self showView];
    
}

- (void)showView {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
   
    [self.contentView setAlpha:0];
    [UIView animateWithDuration:0.1 animations:^{
        [self.contentView setAlpha:1];
    }completion:^(BOOL finished) {
        [self performSelector:@selector(hideView) withObject:nil afterDelay:2];
    }];
}

- (void)hideView {
    [UIView animateWithDuration:0.3 animations:^{
        [self removeFromSuperview];
    }];
}

@end
