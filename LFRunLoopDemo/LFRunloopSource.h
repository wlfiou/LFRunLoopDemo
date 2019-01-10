//
//  LFRunloopSource.h
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFRunloopSource : NSObject
{
    CFRunLoopSourceRef _runloopSource;
    NSMutableArray *_commands;
}
-(id)init;
-(void)addToCurrentRunloop;
-(void)sourceFired;
- (void)fireCommandsOnRunLoop:(CFRunLoopRef)runloop;
-(void)addCommand:(NSInteger)command withData:(id)data;
-(void)invalidateSource;
@end

NS_ASSUME_NONNULL_END

void RunLoopSourceScheduleRoutine(void *info, CFRunLoopRef rl, CFStringRef mode);
void RunLoopSourcePerformRoutine(void *info);
void RunLoopSourceCancelRoutine(void *info,CFRunLoopRef rl, CFStringRef mode);
