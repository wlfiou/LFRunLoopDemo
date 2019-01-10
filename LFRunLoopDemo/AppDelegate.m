//
//  AppDelegate.m
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/8.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import "AppDelegate.h"
#import "LFRunloopSource.h"
#import "RunloopContext.h"
@interface AppDelegate ()
@property (nonatomic,strong)NSMutableArray *sources;
@end

@implementation AppDelegate
-(id)init{
    if (self =[super init]) {
        _sources = [NSMutableArray arrayWithCapacity:2];
    }
    return self;
}
+(AppDelegate *)sharedAppDelegate
{
    static AppDelegate *d;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        d = [[AppDelegate alloc]init];
    });
    return d;
}

-(void)fireSource{
    if (self.sources>0) {
        RunloopContext *context = self.sources[0];
        LFRunloopSource *source = context.source;
        CFRunLoopRef runloop = context.runLoop;
        //给缓冲区发送命令
        if (runloop) {
            [source fireCommandsOnRunLoop:runloop];
        }
    }
}
/**
 *
 *  协调输入源的客户端（将输入源注册到客户端）
 *
 */
-(void)registerSource:(RunloopContext *)sourceContext{
    NSLog(@"source 注册到runloop");
    [self.sources addObject:sourceContext];
}
-(void)removeSource:(RunloopContext *)sourceContext{
    id objToRemove = nil;
    
    for (RunloopContext *context in self.sources)
    {
        if ([context isEqual:sourceContext])
        {
            objToRemove = context;
            break;
        }
    }
    
    if (objToRemove)
        [self.sources removeObject:objToRemove];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
