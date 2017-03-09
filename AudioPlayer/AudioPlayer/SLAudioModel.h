//
//  SLAudioModel.h
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>

/*****这个model是多余的，其实只要知道caf音频文件的名字，可以根据该音频文件创建一个audioRecorder对象，那么该音频文件的信息就能知道啦，此模型没有用，算了也不想删除了******/

@interface SLAudioModel : NSObject

@property (nonatomic, strong) NSString *audioName;  //音频文件名字
@property (nonatomic, strong) NSString *audioPath;  //音频文件路径
@property (nonatomic, assign) NSInteger totalTime;  //总时长

@end
