//
//  LFRunloopSource.m
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import "LFRunloopSource.h"
#import "AppDelegate.h"
#import <objc/runtime.h>
#import "RunloopContext.h"
@interface LFRunloopSource ()

@property (nonatomic, weak) NSTimer *timer;
@end
@implementation LFRunloopSource
/**
 *
 *  安装输入源到Run Loop－－－分两步首先初始化一个输入源(init)，然后将这个输入源添加到当前Run Loop里面(addToCurrentRunLoop)
 *typedef struct {
 CFIndex    version;
 void *    info;
 const void *(*retain)(const void *info);
 void    (*release)(const void *info);
 CFStringRef    (*copyDescription)(const void *info);
 Boolean    (*equal)(const void *info1, const void *info2);
 CFHashCode    (*hash)(const void *info);
 void (*schedule)(void *info, CFRunLoopRef rl, CFStringRef mode);//当source加入到model触发的回调
 void (*cancel)(void *info, CFRunLoopRef rl, CFStringRef mode);//当source从runloop中移除时触发的回调
 void (*perform)(void *info);//当source事件被触发时的回调，使用CFRunLoopSourceSignal方式触发。
 } CFRunLoopSourceContext;
 */
-(id)init{
    //source0
    self = [super init];
    CFRunLoopSourceContext context ={0,(__bridge void *)(self),NULL,NULL,NULL,NULL,NULL,
        &RunLoopSourceScheduleRoutine,
        &RunLoopSourceCancelRoutine,
        &RunLoopSourcePerformRoutine
    };
    _runloopSource = CFRunLoopSourceCreate(NULL, 0, &context);
    _commands = [[NSMutableArray alloc] init];
    
    return self;
}
-(void)addToCurrentRunloop{
    //
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, _runloopSource, kCFRunLoopDefaultMode);
}
-(void)sourceFired{
    NSLog(@"Source fired:do some work");
    NSThread *thread = [NSThread currentThread];
    //    [thread cancel];
    
    //既然线程没了，就把AppDelegate缓存的runloop也给删了，以免下次调用CFRunLoopWakeUp(runloop);会崩溃，因为只有runloop没了线程
    //    [[AppDelegate sharedAppDelegate].sources removeObjectAtIndex:0];
}
-(void)addCommand:(NSInteger)command withData:(id)data{
    
}
-(void)fireCommandsOnRunLoop:(CFRunLoopRef)runLoop{
    //标记为待处理
    if (_runloopSource) {
        CFRunLoopSourceSignal(_runloopSource);
        CFRunLoopWakeUp(runLoop);
    }
}
-(void)timerAction:(NSTimer *)timer{
    NSLog(@"-----------------");
}
-(void)invalidateSource{
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    CFRunLoopRemoveSource(runloop, _runloopSource, kCFRunLoopDefaultMode);
}
@end
void RunLoopSourceScheduleRoutine (void *info, CFRunLoopRef rl, CFStringRef mode){
    LFRunloopSource *obj = (__bridge LFRunloopSource *)info;
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    RunloopContext *context = [[RunloopContext alloc]initWithSource:obj andRunLoop:rl];
//    发送注册请求
    [delegate performSelectorOnMainThread:@selector(registerSource:) withObject:context waitUntilDone:YES];
}
/**
 *  处理例程
 *  在输入源被告知（signal source）时，调用这个处理例程，这儿只是简单的调用了 [obj sourceFired]方法
 *
 */
void RunLoopSourcePerformRoutine (void *info)
{
    LFRunloopSource*  obj = (__bridge LFRunloopSource*)info;
    [obj sourceFired];
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:obj selector:@selector(timerAction:) userInfo:nil repeats:YES];
}
/**
 *  取消例程
 *  如果使用CFRunLoopSourceInvalidate/CFRunLoopRemoveSource函数把输入源从run loop里面移除的话，系统会调用这个取消例程，并且把输入源从注册的客户端（可以理解为其他线程）里面移除
 *
 */
void RunLoopSourceCancelRoutine (void *info, CFRunLoopRef rl, CFStringRef mode)
{
    LFRunloopSource* obj = (__bridge LFRunloopSource*)info;
    AppDelegate* delegate = [AppDelegate sharedAppDelegate];
    RunloopContext* theContext = [[RunloopContext alloc]initWithSource:obj andRunLoop:rl];
    
    [delegate performSelectorOnMainThread:@selector(removeSource:) withObject:theContext waitUntilDone:NO];
}
