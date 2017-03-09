//
//  SLAudioRecorder.h
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>

//录音文件的默认存储位置
#define kAudioSavedPath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

@protocol SLAudioRecorderDelegate <NSObject>

//录音时间
-(void)audioRecorderedProgress:(NSTimeInterval)progress;

//录音声波状态设置
-(void)audioPowerChange:(float)audioChange;

//所有的保存的列表
-(void)audioList:(NSArray *)audioList;

@end

@interface SLAudioRecorder : NSObject

@property (nonatomic, weak) id<SLAudioRecorderDelegate>delegate;

//开始录音或暂停录音
- (void)startRecord;

//暂停录音
- (void)pauseRecord;

//保存录音
-(void)saveAudioFileNamed:(NSString *)nameStr;

//播放录音
-(void)playAudio;

@end
