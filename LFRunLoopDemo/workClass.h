//
//  workClass.h
//  LFRunLoopDemo
//
//  Created by 王鹭飞 on 2019/1/9.
//  Copyright © 2019 王鹭飞. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface workClass : NSObject
-(void)launchThreadWithPort:(NSPort *)port;
@end

NS_ASSUME_NONNULL_END
