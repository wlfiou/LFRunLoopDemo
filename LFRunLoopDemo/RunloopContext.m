//
//  RunloopContext.m
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import "RunloopContext.h"
#import "LFRunloopSource.h"
@implementation RunloopContext
-(id)initWithSource:(LFRunloopSource *)src andRunLoop:(CFRunLoopRef)runLoop{
    self = [super init];
    if (self) {
        _runLoop = runLoop;
        _source = src;
    }
    return self;
}
@end
