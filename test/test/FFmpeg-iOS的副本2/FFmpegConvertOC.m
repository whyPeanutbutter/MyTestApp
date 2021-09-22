//
//  FFmpegConvertOC.m
//
//  Created by 吴小宇 on 2020/12/17.
//  Copyright © 2020 why. All rights reserved.
//


#import "FFmpegConvertOC.h"
#import <Foundation/Foundation.h>
#import "ELFFmpegManger.h"

void convertEnd(int code){
    [[ELFFmpegManger sharedManager] convertEnd:code == 0];
}

void setDuration(long long int time ,char filename[1024]) {
    
    NSString *fileNames = @"";
    for (int i = 0; i < 1024; i++) {
        fileNames = [fileNames stringByAppendingFormat:@"%c", filename[i]];
    }
    // 将这个数值除以1000000后得到的是秒数
    [[ELFFmpegManger sharedManager] setDuration:time/1000000 + 1 inputFilePath:fileNames];
}

void setCurrentTime(char info[1024], char filename[1024]) {
    NSString *temp = @"";
    BOOL isBegin = false;
    int j = 5;
    for (int i = 0; i < 1024; i++) {
        // 获得时间开始的标记t
        if (info[i] == 't') {
            isBegin = true;
        }
        if (isBegin) {
            // 判断是否结束,结束了会输出空格
            if (info[i] == ' ') {
                break;
            }
            if (j > 0) {
                j--;
                continue;
            }else{
                temp = [temp stringByAppendingFormat:@"%c",info[i]];
            }
        }
    }
    
    NSString *fileNames = @"";
    for (int i = 0; i < 1024; i++) {
        fileNames = [fileNames stringByAppendingFormat:@"%c", filename[i]];
    }
    //结果是00:00:00.00格式,转换为秒的格式
    int hour,min,second;
    hour = [[temp substringWithRange:NSMakeRange(0, 2)] intValue];
    min = [[temp substringWithRange:NSMakeRange(3, 2)] intValue];
    second = [[temp substringWithRange:NSMakeRange(6, 2)] intValue];
    second = hour * 3600 + min * 60 + second + 1;
    [[ELFFmpegManger sharedManager] setCurrentTime:second inputFilePath:fileNames];
}



