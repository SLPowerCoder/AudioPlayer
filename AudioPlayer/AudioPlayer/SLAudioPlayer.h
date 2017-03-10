//
//  SLAudioPlayer.h
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/*播放比较长的音乐（理论上时间无限制，如果你内存够多的话），可以获取时间进度等等*/

@interface SLAudioPlayer : NSObject<AVAudioPlayerDelegate>

/**
 每次播放一个新的音频该方法必须设置，会根据该属性的路径来创建音频对象

 @param currentAudioPath 音频路径
 */
-(void)setAudioPath:(NSString *)currentAudioPath;

/**
 单例
 @return 单例
 */
+(SLAudioPlayer *)shareAudioInstance;

/**
 创建并从指定的时间播放音频
 */
-(void)playAudio;

/**
 从指定的时间播放音频
 @param time 指定的时间
 */
-(void)playAudioAtTime:(NSTimeInterval)time;

/**
 暂停播放音频
 */
-(void)pausePlayAudio;

/**
 停止播放音频
 */
-(void)stopPlayAudio;

@end

/*******************************************播放特效（简短的声音）有较多限制如下*************************************/
/*音频播放时间不能超过30s
 数据必须是PCM或者IMA4格式
 音频文件必须打包成.caf、.aif、.wav中的一种（注意这是官方文档的说法，实际测试发现一些.mp3也可以播放）
 */


@interface SLPlaySoundEffect : NSObject

/**
 播放音效文件
 
 @param audioPathStr 音频文件路径
 */
+(void)playSoundEffect:(NSString *)audioPathStr;

@end
