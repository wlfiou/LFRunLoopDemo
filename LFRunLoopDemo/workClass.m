//
//  workClass.m
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import "workClass.h"
#import <Foundation/NSPort.h>
@interface workClass ()<NSMachPortDelegate,NSPortDelegate>
{
    NSPort *remotePort;
    NSPort *myPort;
    NSMutableArray *arr;
    NSTimer *t;
}
@end
#define kMsg1 100
#define kMsg2 101
@implementation workClass
-(void)launchThreadWithPort:(NSPort *)port{
    @autoreleasepool {
        // 获得当前thread的Run loop
        NSRunLoop* myRunLoop = [NSRunLoop currentRunLoop];
        CFRunLoopObserverContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
        // 创建Run loop observer对象
        // 第一个参数用于分配该observer对象的内存
        // 第二个参数用以设置该observer所要关注的的事件，详见回调函数myRunLoopObserver中注释
        // 第三个参数用于标识该observer是在第一次进入run loop时执行还是每次进入run loop处理时均执行
        // 第四个参数用于设置该observer的优先级
        // 第五个参数用于设置该observer的回调函数
        // 第六个参数用于设置该observer的运行环境
        CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAllActivities, YES, 0, &mythreadObserver, &context);
        if (observer){
            CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];
            CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
        }
        //保存主线程传入的port
        remotePort = port;
//        设置子线程名字
        [[NSThread currentThread] setName:@"myworkclassThread"];
//        开始runloop
        [[NSRunLoop currentRunLoop] run];
//        创建自己的port
        myPort = [NSPort port];
        myPort.delegate = self;
        //将自己的port添加到runloop
        //作用1、防止runloop执行完毕之后推出
        //作用2、接收主线程发送过来的port消息
//        当没有时间发生时，CFRunLoop将在mach_msg处等待事件发生。
        [[NSRunLoop currentRunLoop] addPort:myPort forMode:NSDefaultRunLoopMode];
         // 完成向主线程port发送消息
        [self sendPortMessage];
//        t= [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
//            NSLog(@"asd");
//        }];
//        [[NSRunLoop currentRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
//        [t fire];
    }
}
void mythreadObserver(CFRunLoopObserverRef observerref,CFRunLoopActivity activity,void *info){
    switch (activity) {
        case kCFRunLoopEntry:
            NSLog(@"即将进入runloop");
            break;
        case kCFRunLoopBeforeTimers:
            NSLog(@"即将处理timer");
            break;
        case kCFRunLoopBeforeSources:
            NSLog(@"即将处理source");
            break;
        case kCFRunLoopBeforeWaiting:
            NSLog(@"即将进入休眠");
            break;
        case kCFRunLoopAfterWaiting:
            NSLog(@"刚从休眠中唤醒");
            break;
        case kCFRunLoopExit:
            NSLog(@"即将退出runloop");
            break;
            
        default:
            break;
    }
}
/**
 *   完成向主线程发送port消息
 */
-(void)sendPortMessage{
    NSString *str1 = @"aaa111";
    NSString *str2 = @"bbb222";
    arr = [[NSMutableArray alloc] initWithArray:@[[str1 dataUsingEncoding:NSUTF8StringEncoding],[str2 dataUsingEncoding:NSUTF8StringEncoding]]];
    //发送消息到主线程 操作1
    [remotePort sendBeforeDate:[NSDate date] msgid:kMsg1 components:arr from:myPort reserved:0];
    //发送消息到主线程 操作2
//    [remotePort sendBeforeDate:[NSDate date]
     //                         msgid:kMsg2
     //                    components:nil
     //                          from:myPort
     //                      reserved:0];
}
-(void)handlePortMessage:(NSPortMessage *)message
{
    NSLog(@"接收到副线程的消息。。。\n");
    
}
@end
