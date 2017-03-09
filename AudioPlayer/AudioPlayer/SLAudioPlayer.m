//
//  SLAudioPlayer.m
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "SLAudioPlayer.h"

@interface SLAudioPlayer ()
@property (nonatomic, copy) NSString *currentAudioPath;   // 音频路径
@property (nonatomic, assign) NSTimeInterval time;        // 音频播放指定时间
@end

@implementation SLAudioPlayer

//指定音频路径和播放时间
- (instancetype)initWithUrl:(NSString *)urlStr atTime:(NSTimeInterval)time
{
    self = [super init];
    if (self) {
        
        self.currentAudioPath = urlStr;
        self.time = time;
    }
    return self;
}

/************************************播放音乐********************************/

#pragma mark - 创建AVAudioPlayer对象
//播放器对象，每一个音频路径对应一个AVAudioPlayer，所以不要用懒加载为好
-(AVAudioPlayer *)createAudioPlayerWithAudioUrl:(NSString *)urlStr{
    
    //设置为播放和录音状态，以便可以在录制完之后播放录音，暂停后台音乐
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    NSURL *url;
    if ([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:urlStr];
    }else{
        url = [NSURL fileURLWithPath:urlStr];
    }
    NSError *error = nil;
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
    //只播放一次
    audioPlayer.numberOfLoops = 0;
    audioPlayer.enableRate = YES;
    [audioPlayer prepareToPlay];
    audioPlayer.delegate = self;
    
    if (error) {
        NSLog(@"创建播放器过程中发生错误，请检查音频文件的路径对否，错误信息：%@",error.localizedDescription);
        return nil;
    }
    
    return audioPlayer;
}


/**
 创建并从指定的时间播放音频
 */
-(void)playAudio{
    //每次一次播放都要创建一个新的对象
    if (!_audioPlayer) {
        _audioPlayer = [self createAudioPlayerWithAudioUrl:self.currentAudioPath];
    }
    
    if (self.time) {
        if (![_audioPlayer isPlaying]) {
            [_audioPlayer playAtTime:self.time];
        }else{
            [self pauseAudio];
        }
        
    }else{
        if (![_audioPlayer isPlaying]) {
            [_audioPlayer play];
        }else{
            [self pauseAudio];
        }
        
    }
}

/**
 暂停播放音频
 */
-(void)pausePlayAudio{
    if (_audioPlayer) {
        [_audioPlayer pause];
    }
}

/**
 停止播放音频
 */
-(void)stopPlayAudio{
    if (_audioPlayer) {
        [_audioPlayer stop];
        //一定要在此处置为空
        _audioPlayer = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate的代理方法

/* audioPlayerDidFinishPlaying:successfully: is called when a sound has finished playing. This method is NOT called if the player is stopped due to an interruption. */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"播放完成。。");
    
    //后台音乐继续播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{

    NSLog(@"解码失败--%@",error.localizedDescription);
}

/*******************************************播放特效（简短的声音）*************************************/
/*音频播放时间不能超过30s
 数据必须是PCM或者IMA4格式
 音频文件必须打包成.caf、.aif、.wav中的一种（注意这是官方文档的说法，实际测试发现一些.mp3也可以播放）
 */



@end
