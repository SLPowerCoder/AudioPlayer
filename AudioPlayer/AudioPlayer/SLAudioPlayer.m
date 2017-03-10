//
//  SLAudioPlayer.m
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "SLAudioPlayer.h"

@interface SLAudioPlayer ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy)   NSString *currentAudioPath;

@end

@implementation SLAudioPlayer

static SLAudioPlayer *kInstance = nil;
+(SLAudioPlayer *)shareAudioInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kInstance = [[SLAudioPlayer alloc]init];
    });
    return kInstance;
}

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
    audioPlayer.delegate = self;
    
    if (error) {
        NSLog(@"创建播放器过程中发生错误，请检查音频文件的路径对否，错误信息：%@",error.localizedDescription);
        return nil;
    }
    return audioPlayer;
}



/**
 注意：只有在设置音频路径的时候才会创建音频对象并释放以前的对象
 所以每次播放新的视频的时候一定要设置
 @param currentAudioPath 音频路径
 */
-(void)setAudioPath:(NSString *)currentAudioPath{
    
    if (currentAudioPath && ![currentAudioPath isEqualToString:@""]) {
        //把上一次的音频对象和路径置为空
        if (self.currentAudioPath && ![self.currentAudioPath isEqualToString:currentAudioPath]) {
            _audioPlayer = nil;
            self.currentAudioPath = nil;
        }
        //重新设置本次的
        self.currentAudioPath = currentAudioPath;
        if (self.currentAudioPath) {
            self.audioPlayer = [self createAudioPlayerWithAudioUrl:currentAudioPath];
        }
    }else{
        NSLog(@"设置的音频路径无效");
    }
}

/**
 播放或暂停音频
 */
-(void)playAudio{
    //每次一次播放都要创建一个新的对象
    if (!_audioPlayer) {
        NSLog(@"音频对象为空，您还没有设置音频的路径!!!");
        return;
    }
    if (![_audioPlayer isPlaying]) {
        [_audioPlayer play];
    }else{
        [self pausePlayAudio];
    }
}

/**
 从指定的时间播放音频
 @param time 指定的时间
 */
-(void)playAudioAtTime:(NSTimeInterval)time{
    //每次一次播放都要创建一个新的对象
    if (!_audioPlayer) {
        NSLog(@"音频对象为空，您还没有设置音频的路径!!!");
        return;
    }
    if (![_audioPlayer isPlaying]) {
        [_audioPlayer playAtTime:time];
    }else{
        [self pausePlayAudio];
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
    [self stopPlayAudio];
    //后台音乐继续播放
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    _currentAudioPath = nil;
    NSLog(@"解码失败--%@",error.localizedDescription);
}


@end


@implementation SLPlaySoundEffect

/**
 播放音效文件
 
 @param audioPathStr 音频文件路径
 */
+(void)playSoundEffect:(NSString *)audioPathStr{
    
    NSURL *fileUrl;
    if (audioPathStr && ([audioPathStr hasPrefix:@"https://"] || [audioPathStr hasPrefix:@"http://"])) {
        fileUrl = [NSURL URLWithString:audioPathStr];
    }else{
        fileUrl = [NSURL fileURLWithPath:audioPathStr];
    }
    
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}

/**
 播放完成回调函数，C函数
 
 @param soundID 系统声音ID
 @param clientData 回调时传递的数据
 */
void soundCompleteCallback(SystemSoundID soundID,void * clientData){
    NSLog(@"播放完成...");
}

@end
