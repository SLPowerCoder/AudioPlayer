//
//  SLAudioPlayer.h
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>





@interface SLAudioPlayer : NSObject<AVAudioPlayerDelegate>

//总感觉这个属性不应该暴露出来
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


/**
 初始化播放器管理对象

 @param urlStr 音频路径
 @param time 音频播放指定时间
 @return 初始化播放器管理对象
 */
- (instancetype)initWithUrl:(NSString *)urlStr atTime:(NSTimeInterval)time;

/**
 创建并从指定的时间播放音频
 */
-(void)playAudio;


/**
 暂停音频
 */
-(void)pauseAudio;


/**
 停止音频
 */
-(void)stopAudio;


@end
