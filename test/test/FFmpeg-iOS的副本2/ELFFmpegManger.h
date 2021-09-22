//
//  ELFFmpegManger.h
//  test
//
//  Created by 吴小宇 on 2020/12/17.
//  Copyright © 2020 why. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol ELFFmpegMangerDelegate<NSObject>

- (void)convertItem:(NSString *)inputPath finished:(BOOL)isSuccess;
- (void)convertItem:(NSString *)inputPath process:(float)process;

@end

@interface ELFFmpegItem : NSObject

@property (nonatomic, copy) NSString *inputPath;
//@property (nonatomic, copy) NSString *outputPath;

@end

@interface ELFFmpegManger : NSObject

@property (nonatomic, weak) id<ELFFmpegMangerDelegate> delegate;

+ (ELFFmpegManger *)sharedManager;

- (void)addFFmpegItem:(ELFFmpegItem *)item;

- (void)beginConvert;

- (void)setDuration:(NSInteger)time inputFilePath:(NSString *)inputFilePath;

- (void)setCurrentTime:(NSInteger)time inputFilePath:(NSString *)inputFilePath;

- (void)convertEnd:(BOOL) isSuccess;

@end

NS_ASSUME_NONNULL_END
