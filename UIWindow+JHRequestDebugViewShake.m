//
//  UIWindow+JHRequestDebugViewShake.m
//  JHKit
//
//  Created by HaoCold on 2017/11/22.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import "UIWindow+JHRequestDebugViewShake.h"

@implementation UIWindow (JHRequestDebugViewShake)

- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJHRequestDebugViewNotification" object:nil];
}

@end
