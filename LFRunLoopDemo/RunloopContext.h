//
//  RunloopContext.h
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LFRunloopSource;
NS_ASSUME_NONNULL_BEGIN

@interface RunloopContext:NSObject{
    CFRunLoopRef _runLoop;
    LFRunloopSource *_source;
}
@property(readonly)CFRunLoopRef runLoop;
@property(readonly)LFRunloopSource *source;
-(id)initWithSource:(LFRunloopSource *)src andRunLoop:(CFRunLoopRef)runLoop;

@end

NS_ASSUME_NONNULL_END
