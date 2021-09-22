//
//  ELFFmpegManger.m
//  test
//
//  Created by 吴小宇 on 2020/12/17.
//  Copyright © 2020 why. All rights reserved.
//

#import "ELFFmpegManger.h"
#import "ffmpeg.h"

#define ELFFmpegMangerLog(a) NSLog(@"ELFFmpegManger : %@", a);

@implementation ELFFmpegItem

@end

@interface ELFFmpegManger ()
{
    ELFFmpegItem *currentConvertItem;
}

@property (nonatomic, strong) NSMutableArray<ELFFmpegItem *> *ffmpegItemArr;
@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, strong) NSMutableDictionary *fileDurationDic;
@property (nonatomic, strong) dispatch_queue_t queue;

@end

@implementation ELFFmpegManger
+ (instancetype)sharedManager {
    static ELFFmpegManger *_sharedManger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManger = [[ELFFmpegManger alloc]init];
    });

    return _sharedManger;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("ELFFmpegManger Queue", NULL);
    }
    return _queue;
}

- (NSMutableArray *)ffmpegItemArr {
    if (!_ffmpegItemArr) {
        _ffmpegItemArr = [[NSMutableArray alloc]init];
    }
    return _ffmpegItemArr;
}

- (NSMutableDictionary *)fileDurationDic {
    if (!_fileDurationDic) {
        _fileDurationDic = [[NSMutableDictionary alloc]init];
    }
    return _fileDurationDic;
}

- (void)beginConvert {
    if (!self.delegate) {
        ELFFmpegMangerLog(@"delegate should initialize first");
    }
    dispatch_async(self.queue, ^(void) {
        if (self.ffmpegItemArr.count == 0) {
            self.isRunning = NO;
            return;
        }
        ELFFmpegItem *item = self.ffmpegItemArr.firstObject;
        self->currentConvertItem = item;
        [self convertWithInputPath:item.inputPath];
    });
}

- (void)addFFmpegItem:(ELFFmpegItem *)item {
    dispatch_async(self.queue, ^(void) {
//        if(isEmpty(item.path))
        [self.ffmpegItemArr addObject:item];
    });
}

- (void)convertWithInputPath:(NSString *)inputPath {
//    NSString *outpath = [[inputPath.stringByDeletingPathExtension stringByAppendingString:@"_temp"] stringByAppendingString:inputPath.pathExtension];

    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *outpath = [docDir stringByAppendingPathComponent:inputPath.lastPathComponent];
    NSString *commandStr = [NSString stringWithFormat:@"ffmpeg -i %@ -vcodec copy -acodec aac -ac 1 -ar 44100 -y %@", inputPath, outpath];
    if (self.isRunning) {
        ELFFmpegMangerLog(@"converting now，please waiting");
    }
    self.isRunning = YES;

    // 根据空格将指令分割为指令数组
    NSArray *argvArray = [commandStr componentsSeparatedByString:(@" ")];
    // 将OC对象转换为对应的C对象
    int argc = (int)argvArray.count;
    char **argv = (char **)malloc(sizeof(char *) * argc);
    for (int i = 0; i < argc; i++) {
        argv[i] = (char *)malloc(sizeof(char) * 1024);
        strcpy(argv[i], [[argvArray objectAtIndex:i] UTF8String]);
    }

    NSString *finalCommand = @"ffmpeg:";
    for (NSString *temp in argvArray) {
        finalCommand = [finalCommand stringByAppendingFormat:@"%@", temp];
    }
    ELFFmpegMangerLog(finalCommand);

    ffmpeg_main(argc, argv);
}

- (void)setDuration:(NSInteger)time inputFilePath:(NSString *)inputFilePath {
    dispatch_async(self.queue, ^(void) {
        self.fileDurationDic[inputFilePath] = @(time);
    });
}

- (void)setCurrentTime:(NSInteger)time inputFilePath:(NSString *)inputFilePath {
    dispatch_async(self.queue, ^(void) {
        float process = time / ([self.fileDurationDic[inputFilePath] integerValue] * 1.00);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.delegate convertItem:inputFilePath process:process];
        });
    });
}

- (void)convertEnd:(BOOL)isSuccess {
    dispatch_async(self.queue, ^(void) {
        if (self->currentConvertItem) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate convertItem:self->currentConvertItem.inputPath finished:isSuccess];
            });
            [self replaceFileWhenConvertSuccess];
            [self.ffmpegItemArr removeObject:self->currentConvertItem];
        }
        self.isRunning = NO;
        if (self.ffmpegItemArr.count > 0) {
            ELFFmpegItem *item = self.ffmpegItemArr.firstObject;
            self->currentConvertItem = item;
            [self convertWithInputPath:item.inputPath];
        }
    });
}

- (void)replaceFileWhenConvertSuccess {
//    if(currentConvertItem) {
//        NSString *inputPath = currentConvertItem.inputPath;
//        NSString *outpath = [[inputPath.stringByDeletingPathExtension stringByAppendingString:@"_temp"] stringByAppendingString:inputPath.pathExtension];
//    }
    //whytodo
}

@end
