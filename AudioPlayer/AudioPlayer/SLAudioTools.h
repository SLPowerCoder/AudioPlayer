//
//  SLAudioTools.h
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLAudioTools : NSObject

//在指定目录下查找某一类型的文件
+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath;

//判读指定路径是否存在
+(BOOL)isFileExistAtPath:(NSString*)fileFullPath;

@end
