//
//  ViewController.m
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/8.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import "ViewController.h"
#import "LFRunloopSource.h"
#import "AppDelegate.h"
#import "workClass.h"
void myObserver(CFRunLoopObserverRef observerref,CFRunLoopActivity activity,void *info);
static inline void runCheck(id self){
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
    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault,kCFRunLoopAllActivities, YES, 0, &myObserver, &context);
    if (observer){
        CFRunLoopRef cfLoop = [myRunLoop getCFRunLoop];
        CFRunLoopAddObserver(cfLoop, observer, kCFRunLoopDefaultMode);
    }
}
@interface ViewController ()<NSPortDelegate,NSMachPortDelegate>
{
    NSTimer *t;
    LFRunloopSource *_source;
    
}
@property(nonatomic,strong)NSThread* thread;
@end

@implementation ViewController
- (IBAction)tapToFire:(id)sender {
    AppDelegate *delegate = [AppDelegate sharedAppDelegate];
    [delegate fireSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self testRunloop0_performselector];
    [self testRunloop1_CustomSource];
//    [self testPort];
//    [self testCoustomTimer];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)testCoustomTimer{
    runCheck(self);
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFRunLoopTimerContext timerContext = {0, NULL, NULL, NULL, NULL};
    CFRunLoopTimerRef Timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 1, 3, 0, 0, &myCFTimerCallback, &timerContext);
    CFRunLoopAddTimer(runLoop, Timer, kCFRunLoopDefaultMode);
    NSInteger loopCount = 2;
    do{
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        loopCount--;
    }while (loopCount);
}
void myCFTimerCallback(){
    NSLog(@"-----++++-------");
}
-(void)testPort{
//     创建主线程的port
    // 子线程通过此端口发送消息给主线程
    NSPort *myport = [NSPort port];
    if (myport) {
        //这个类持有即将到来的端口消息
        [myport setDelegate:self];
        //将端口作为输入源安装到当前的runloop
        [[NSThread currentThread] setName:@"port_tread"];
        [[NSRunLoop currentRunLoop] addPort:myport forMode:NSDefaultRunLoopMode];
        
//      启动次线程,并传入主线程的port
        workClass *work = [[workClass alloc] init];
        [NSThread detachNewThreadSelector:@selector(launchThreadWithPort:) toTarget:work withObject:myport];
//         [myport sendBeforeDate:[NSDate date] msgid:1 components:arr from:myPort reserved:0];
    }
    
}
#define kCheckinMessage 100
//port 代理
-(void)handlePortMessage:(id)portMessage
{
    //消息的 id
    unsigned int messageId = (int)[[portMessage valueForKeyPath:@"msgid"] unsignedIntegerValue];
    
    if (messageId == kCheckinMessage) {
        
        //1. 当前主线程的port
        NSPort *localPort = [portMessage valueForKeyPath:@"localPort"];
        //2. 接收到消息的port（来自其他线程,这里是workClass所在线程）
        NSPort *remotePort = [portMessage valueForKeyPath:@"remotePort"];
        //3. 获取工作线程关联的端口，并设置给远程端口，结果同2
        NSPort *distantPort = [portMessage valueForKeyPath:@"sendPort"];
        
        NSMutableArray *arr = [[portMessage valueForKeyPath:@"components"] mutableCopy];
        if ([arr objectAtIndex:0]) {
            NSData *data = [arr objectAtIndex:0];
            NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",str);
        }
        NSLog(@"%@",arr);
        //为了以后的使用保存工作端口
        //        [self storeDistantPort: distantPort];
    } else {
        //处理其他的消息
    }
}
/**
 *
 *  自定义source0源
 *
 */
-(void)testRunloop1_CustomSource
{
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(testForCustomSource) object:nil];
     [thread setName:@"CustomSource--Thread"];
    self.thread =thread;
    [self.thread start];
}
-(void)testForCustomSource{
    NSLog(@"starting thread .....");
    runCheck(self);
    _source = [[LFRunloopSource alloc]init];
    [_source addToCurrentRunloop];
    if (![self.thread isCancelled]) {
        NSLog(@"We can do other work");
//        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    }
    [_source invalidateSource];
    NSLog(@"finishing thread.........");
    
}
void myObserver(CFRunLoopObserverRef observerref,CFRunLoopActivity activity,void *info){
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
 *
 *  perform 测试
 *
 */
-(void)testRunloop0_performselector{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self performSelectorOnMainThread:@selector(test) withObject:nil waitUntilDone:YES];
        
        [self performSelector:@selector(test) withObject:nil afterDelay:0];//如果当前线程没runloop则方法无效
        [self performSelector:@selector(test1) onThread:[NSThread currentThread] withObject:nil waitUntilDone:YES];
        //不加runloop test 不会执行  test1 waitUntilDone 为YES时会执行，为NO时则不会执行
        CFRunLoopRun();
        
        
        //当调用上述API，实际上其内部会创建一个 Timer 并添加到当前线程的 RunLoop 中。所以如果当前线程没有 RunLoop 就会失效
    });
}

-(void)test{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"显示了");
}
-(void)test1{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"显示了111");
    static int i = 0;
//    timer加入到当前runloop后，必须让runloop 运行起来，否则timer仅执行一次
  t =  [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        NSLog(@"%d",i++);
    }];
    [[NSRunLoop currentRunLoop] addTimer:t forMode:NSRunLoopCommonModes];
//    [[NSRunLoop currentRunLoop] run];
    [t fire];
}
@end
