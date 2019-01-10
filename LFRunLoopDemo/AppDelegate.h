//
//  AppDelegate.h
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/8.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RunloopContext;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong,readonly)NSMutableArray *sources;
+(AppDelegate *)sharedAppDelegate;
- (void)fireSource;
- (void)registerSource:(RunloopContext*)sourceContext;
- (void)removeSource:(RunloopContext*)sourceContext;
@end

