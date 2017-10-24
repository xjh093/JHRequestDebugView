//
//  JHRequestDebugView.h
//  JHKit
//
//  Created by HaoCold on 2017/10/23.
//  Copyright © 2017年 HaoCold. All rights reserved.
//  请求调试窗口

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kJHRequestDebugViewNotification;

@interface JHRequestDebugView : UIView

+ (instancetype)defaultDebugView;

/// for GET
- (void)jh_set_GET_URL:(NSString *)url parameter:(NSDictionary *)dic;

/// for POST
- (void)jh_set_POST_URL:(NSString *)url parameter:(NSDictionary *)dic;

@end

/**< Steps:
 
 1.add this in AppDelegate.m
 
 - (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:kJHRequestDebugViewNotification object:nil];
 }
 
 2.invoke 
 [[JHRequestDebugView defaultDebugView] jh_set_GET_URL:url parameter:dic]; or
 [[JHRequestDebugView defaultDebugView] jh_set_POST_URL:url parameter:dic];
 before or after the following code.
 
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //...
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //...
 }];
 
 */
