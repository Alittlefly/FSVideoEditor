//
//  FSMusicController.m
//  FSVideoEditor
//
//  Created by Charles on 2017/6/29.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSMusicController.h"

@interface FSMusicController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *musics;
@end

@implementation FSMusicController
-(NSArray *)musics{
    if (!_musics) {
        _musics = [NSArray arrayWithObjects:@"month",@"wind",@"ugly",nil];
    }
    return _musics;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    
    [self.view addSubview:_tableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.musics count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellid = @"asdasd";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];//[tableView dequeueReusableCellWithIdentifier:cellid forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellid];
    }
    [cell.textLabel setText:[self.musics objectAtIndex:indexPath.row]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!_timeLine) {
        return;
    }
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[self.musics objectAtIndex:indexPath.row] ofType:@"mp3"];
    
    if (bundlePath) {
        
        int64_t length = _timeLine.duration;
        
        [_timeLine removeAudioTrack:0];
        NvsAudioTrack *audioTrack = [_timeLine appendAudioTrack];
        [audioTrack appendClip:bundlePath];
        NvsAudioClip *audio = [audioTrack getClipWithIndex:0];
        [audio changeTrimOutPoint:length affectSibling:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
