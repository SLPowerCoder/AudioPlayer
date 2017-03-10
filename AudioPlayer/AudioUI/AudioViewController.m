//
//  AudioViewController.m
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "AudioViewController.h"
#import "RecorderedTableViewCell.h"
#import "SLAudioRecorder.h"
#import "SLAudioPlayer.h"
#import "SLAudioTools.h"


static NSString *const kRecorderedTableViewCell = @"RecorderedTableViewCell";

@interface AudioViewController ()<UITableViewDelegate,UITableViewDataSource,SLAudioRecorderDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) UILabel *timeProgressLbl;  //显示录音时间
@property (nonatomic, strong) UIButton *playAudioBtn;    //播放录音
@property (nonatomic, strong) UIButton *recordBtn;       //录音或暂停
@property (nonatomic, strong) UIButton *saveAudioBtn;    //保存录音

@property (nonatomic, strong) SLAudioRecorder *audioRecorder;   //录音对象

@end

@implementation AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //初始化数据源
    NSArray *dataTmp = [SLAudioTools getFilenamelistOfType:@"caf" fromDirPath:[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]];
    _dataArray = [dataTmp mutableCopy];

    [self createContents];
}

-(void)createContents{
    
    /////
    UIView *showTimeProgressView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_W, 150)];
    showTimeProgressView.backgroundColor = [UIColor grayColor];
    self.timeProgressLbl = [[UILabel alloc]initWithFrame:CGRectMake(0, (showTimeProgressView.frame.size.height - 60)/2, showTimeProgressView.frame.size.width, 60)];
    self.timeProgressLbl.textAlignment = NSTextAlignmentCenter;
    self.timeProgressLbl.text = @"00:00";
    [showTimeProgressView addSubview:self.timeProgressLbl];
    [self.view addSubview:showTimeProgressView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissVC)];
    [showTimeProgressView addGestureRecognizer:tap];
    
    
    ///////
    UIView *controlView = [[UIView alloc]initWithFrame:CGRectMake(0, 150, SCREEN_W, 200)];
    controlView.backgroundColor = [UIColor purpleColor];
    //播放
    self.playAudioBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, (controlView.frame.size.height - 40)/2, 40, 40)];
    self.playAudioBtn.backgroundColor = [UIColor orangeColor];
    [self.playAudioBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playAudioBtn addTarget:self action:@selector(playAudioBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //录音
    self.recordBtn = [[UIButton alloc]initWithFrame:CGRectMake((controlView.frame.size.width - 40)/2, (controlView.frame.size.height - 40)/2, 40, 40)];
    self.recordBtn.backgroundColor = [UIColor orangeColor];
    [self.recordBtn setTitle:@"录音" forState:UIControlStateNormal];
    [self.recordBtn addTarget:self action:@selector(recordBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //保存
    self.saveAudioBtn = [[UIButton alloc]initWithFrame:CGRectMake(controlView.frame.size.width - 40 - 80, (controlView.frame.size.height - 40)/2, 40, 40)];
    self.saveAudioBtn.backgroundColor = [UIColor orangeColor];
    [self.saveAudioBtn setTitle:@"保存" forState:UIControlStateNormal];
    [self.saveAudioBtn addTarget:self action:@selector(saveAudioBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [controlView addSubview:self.playAudioBtn];
    [controlView addSubview:self.recordBtn];
    [controlView addSubview:self.saveAudioBtn];
    
    [self.view addSubview:controlView];
    
    ///////
    CGRect tableRect =  self.tableView.frame;
    tableRect.origin.y += controlView.frame.origin.y + controlView.frame.size.height;
    tableRect.size.height = SCREEN_H - tableRect.origin.y;
    
    self.tableView.frame = tableRect;
    
    [self.view addSubview:self.tableView];
}

-(void)dismissVC{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//播放录音
-(void)playAudioBtn:(UIButton *)button{
    [self.audioRecorder playAudio];
}

//录音
-(void)recordBtn:(UIButton *)button{
    [self.audioRecorder startRecord];
}


//保存录音
-(void)saveAudioBtn:(UIButton *)button{
    //暂停录音
    [self.audioRecorder pauseRecord];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"新建文件名称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称";
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //得到输入框
        UITextField *tf=[[alertVC textFields] objectAtIndex:0];
        [self.audioRecorder saveAudioFileNamed:tf.text];
        
        self.timeProgressLbl.text = @"00:00";
    }];
    
    [alertVC addAction:cancel];
    [alertVC addAction:ok];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


#pragma mark - tableView的代理方法
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArray.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RecorderedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecorderedTableViewCell];
    if (!cell) {
        cell = [[RecorderedTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRecorderedTableViewCell];
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *fileName = self.dataArray[indexPath.row];
    NSString *audioPath = [kAudioSavedPath stringByAppendingPathComponent:fileName];
    
    if ([SLAudioTools isFileExistAtPath:audioPath]) {
        SLAudioPlayer *audioPlayer = [SLAudioPlayer shareAudioInstance];
        [audioPlayer setAudioPath:audioPath];
        [audioPlayer playAudio];
        
    }else{
        NSLog(@"音频文件不存在");
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    lbl.backgroundColor = [UIColor whiteColor];
    lbl.text = @" 已录音文件";
    return lbl;
}


#pragma mark - Edit tableCell
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //需要在此处判断该音频文件是否正在被使用
    
    if (editingStyle ==UITableViewCellEditingStyleDelete){
        
        NSLog(@"%ld",(long)indexPath.row);
        //删除对应的音频文件
        NSString *fileName = self.dataArray[indexPath.row];
        NSString *audioPath = [kAudioSavedPath stringByAppendingPathComponent:fileName];
        
        [SLAudioTools deleteAudioAtAudioPath:audioPath];
        
        if (self.dataArray[indexPath.row]) {
            [self.dataArray removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        }
    }
}


#pragma mark -- SLAudioRecorder的代理方法

//录音时间
-(void)audioRecorderedProgress:(NSTimeInterval)progress{

    self.timeProgressLbl.text = [NSString stringWithFormat:@"%02d:%02d",((int)progress/60)%60,(int)progress%60];
}

//录音声波状态设置
-(void)audioPowerChange:(float)audioChange{

}

//获取到音频保存后的所有列表
-(void)audioList:(NSArray *)audioList{

    self.dataArray = [audioList copy];
    [self.tableView reloadData];
}

#pragma mark - getter
-(UITableView *)tableView{

    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}


-(NSMutableArray *)dataArray{

    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArray;
}


-(SLAudioRecorder *)audioRecorder{

    if (!_audioRecorder) {
        _audioRecorder = [[SLAudioRecorder alloc]init];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}


-(void)dealloc{
    self.audioRecorder = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
