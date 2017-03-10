//
//  SLAudioTools.m
//  AudioPlayer
//
//  Created by 孙磊 on 2017/3/8.
//  Copyright © 2017年 孙磊. All rights reserved.
//

#import "SLAudioTools.h"

@implementation SLAudioTools


//获取caf类型的文件
+(NSArray *)getFilenamelistOfType:(NSString *)type fromDirPath:(NSString *)dirPath
{
    NSMutableArray *filenamelist = [NSMutableArray arrayWithCapacity:0];
    //浅遍历指定目录的item，包含文件和文件夹，不会深层次遍历
    NSArray *tmplist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirPath error:nil];
    
    for (NSString *fileName in tmplist) {//文件名包含后缀
        NSString *fullpath = [dirPath stringByAppendingPathComponent:fileName];
        NSLog(@"~~%@\n%@",fileName,fullpath);
        if ([SLAudioTools isFileExistAtPath:fullpath]) {
            if ([[fileName pathExtension] isEqualToString:type]) {
                [filenamelist  addObject:fileName];
            }
        }
    }
    return filenamelist;
}

+(BOOL)isFileExistAtPath:(NSString*)fileFullPath
{
    BOOL isExist = NO;
    isExist = [[NSFileManager defaultManager] fileExistsAtPath:fileFullPath];
    return isExist;
}


+(void)deleteAudioAtAudioPath:(NSString *)pathStr{

    NSFileManager *fileMr = [NSFileManager defaultManager];
    if ([self isFileExistAtPath:pathStr]) {
        NSError *err = nil;
        [fileMr removeItemAtPath:pathStr error:&err];
        if (err) {
            NSLog(@"移除文件 %@ 错误%@",pathStr,err.localizedDescription);
        }
    }
}

@end
