//
//  SLAudioRecorder.m
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "SLAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import "SLAudioTools.h"
#import "SLAudioPlayer.h"


typedef void (^recorderedBlock)();

@interface SLAudioRecorder ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;   //当前音频录音对象，每一次stop之后要重新创建
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;       //音频播放器，用于播放录音文件
@property (nonatomic, strong) NSTimer *timer;                   //录音声波监控（注意这里暂时不对播放进行监控）
@property (nonatomic, strong) NSURL *currentAudioFilePath;      //音频文件的路径，包括文件的名字

@end

@implementation SLAudioRecorder

//初始化音频会话
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //设置为播放和录音状态，以便可以在录制完之后播放录音，会暂停后台其他音乐
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        
        //解决播放audio音量太小
        NSError *audioError = nil;
        BOOL success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&audioError];
        if(!success)
        {
            NSLog(@"error doing outputaudioportoverride - %@", [audioError localizedDescription]);
        }
        //初始化当前录音文件的位置
        self.currentAudioFilePath = nil;
    }
    return self;
}

//取得录音文件保存路径
-(NSURL *)getSavePath{
    NSString *urlStr=kAudioSavedPath;
    urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.caf",(NSInteger)[[NSDate date] timeIntervalSince1970]]];
    NSLog(@"file path:%@",urlStr);
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    return url;
}

//取得录音文件设置
-(NSDictionary *)getAudioSetting{
    
    NSMutableDictionary *recordSetting  = [[NSMutableDictionary alloc] init];
    //设置录音格式  AVFormatIDKey==kAudioFormatLinearPCM，这个格式kAudioFormatMPEG4AAC录不了音
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    //是否使用浮点数采样
    [recordSetting setValue:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    return recordSetting;
}

//录音声波监控定制器
-(NSTimer *)timer{
    if (!_timer) {
        _timer=[NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(audioPowerChange) userInfo:nil repeats:YES];
    }
    return _timer;
}

//录音声波状态设置
-(void)audioPowerChange{
    
    if (_audioRecorder) {
        [_audioRecorder updateMeters];//更新测量值
        float power= [_audioRecorder averagePowerForChannel:0];//取得第一个通道的音频，注意音频强度范围时-160到0
        CGFloat progress=(1.0/160.0)*(power+160.0);
        
        if (self.delegate) {
            
            if ([self.delegate respondsToSelector:@selector(audioPowerChange:)]) {
                [self.delegate audioPowerChange:progress];
//                NSLog(@"声波。。。%f",progress);
            }
            if ([self.delegate respondsToSelector:@selector(audioRecorderedProgress:)]) {
                [self.delegate audioRecorderedProgress:_audioRecorder.currentTime];
                NSLog(@"录音中时间。。。%f",_audioRecorder.currentTime);
            }
        }
    }
}

//开始录音
//_audioRecorder对象只能在此函数中被创建
- (void)startRecord{
    
    if (self.currentAudioFilePath == nil) {
        self.currentAudioFilePath = [self getSavePath];
        self.audioRecorder = nil;
    }
    if (![self.audioRecorder isRecording]) { //执行audioRecorder的getter方法一定要在此处
        if (self.audioPlayer.isPlaying) {
            [self.audioPlayer stop];
        }
        [self.audioRecorder record];//首次使用应用时如果调用record方法会询问用户是否允许使用麦克风
        self.timer.fireDate = [NSDate distantPast]; //开启计时器
        NSLog(@"录音中。。。");
        
    }else{
        [self pauseRecord];
    }
}

//暂停录音
- (void)pauseRecord{
    if (_audioRecorder && [_audioRecorder isRecording]) {
        [_audioRecorder pause];
        [_audioPlayer pause];
        self.timer.fireDate=[NSDate distantFuture]; //关闭计时器
        NSLog(@"录音暂停。。。");
    }
}

//停止录音，关闭录音文件
- (void)stopRecord{
    if (_audioRecorder) {
        [_audioRecorder stop];
        self.timer.fireDate=[NSDate distantFuture];
        
        //将当前录音文件路径置为空
        self.currentAudioFilePath = nil;
        //将录音对象也置为空
        self.audioRecorder = nil;
    }
}

//保存录音
-(void)saveAudioFileNamed:(NSString *)nameStr{
    if (self.currentAudioFilePath == nil) {
        NSLog(@"您还没录音呢，，，，，保存不了。。");
        return;
    }
    //停止录音
    [self pauseRecord];
    //停止播放
    [self.audioPlayer pause];

    if (![nameStr isEqualToString:@""]&&nameStr) {
        
        NSString *urlStr=kAudioSavedPath;
        urlStr=[urlStr stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",nameStr]];
        NSLog(@"音频保存路径为:%@",urlStr);
        NSURL *url=[NSURL fileURLWithPath:urlStr];
        
        NSFileManager *fileM = [NSFileManager defaultManager];
        NSError *err = nil;
        [fileM moveItemAtURL:self.currentAudioFilePath toURL:url error:&err];
        if (err) {
            NSLog(@"保存失败：：%@",err.localizedDescription);
        }
        //将所有存储的音频文件显示到UI上
        if (self.delegate&&[self.delegate respondsToSelector:@selector(audioList:)]) {
            [self.delegate audioList:[SLAudioTools getFilenamelistOfType:@"caf" fromDirPath:kAudioSavedPath]];
        }
    }
    //停止录音
    [self stopRecord];
}

//播放或暂停播放录音
-(void)playAudio{
    [self pauseRecord];
    if (![self.audioPlayer isPlaying] && ([self getSavePath] != nil)){
        [self.audioPlayer play];
    }else{
        [self.audioPlayer pause];
    }
}

#pragma mark - 录音代理方法
//录音完成，录音完成后播放录音
-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"录音完成!");
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //后台音乐继续播放
    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error{
    NSLog(@"录音编码失败--%@",error.localizedDescription);
}


#pragma mark - getter方法

//获得录音机对象，一旦创建了录音对象，对应的音频文件的位置也就确定了，不能改变，除非重新创建录音对象
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url = self.currentAudioFilePath;
        //创建录音格式设置，如音频格式，音频采样率等等。
        NSDictionary *setting = [self getAudioSetting];
        //创建录音机
        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate = self;
        _audioRecorder.meteringEnabled = YES;//如果要监控声波则必须设置为YES
        [_audioRecorder prepareToRecord];//预录音
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
    }
    return _audioRecorder;
}

//播放器对象，每一个音频路径对应一个AVAudioPlayer，所以不要用懒加载为好
-(AVAudioPlayer *)audioPlayer{

    NSURL *url = self.currentAudioFilePath;
    NSError *error = nil;
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    _audioPlayer.numberOfLoops = 0;
    [_audioPlayer prepareToPlay];
    
    if (error) {
        NSLog(@"创建播放器过程中发生错误，请检查音频文件的路径对否，错误信息：%@",error.localizedDescription);
        return nil;
    }
    return _audioPlayer;
}

@end
