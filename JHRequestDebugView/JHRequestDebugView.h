//
//  JHRequestDebugView.h
//  JHKit
//
//  Created by HaoCold on 2017/10/23.
//  Copyright © 2017年 HaoCold. All rights reserved.
//  请求调试窗口
//  MIT License
//
//  Copyright (c) 2017 xjh093
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kJHRequestDebugViewNotification;

@interface JHRequestDebugView : UIView

+ (instancetype)defaultDebugView;

#pragma mark - v1.2.0
/// for GET
- (void)jh_set_GET_task:(NSURLSessionDataTask *)task parameter:(NSDictionary *)dic;

/// for POST
- (void)jh_set_POST_task:(NSURLSessionDataTask *)task parameter:(NSDictionary *)dic;

#pragma mark - v1.1.0
/// store request data for debug
- (void)jh_store_history:(NSString *)url parameter:(NSDictionary *)dic response:(NSDictionary *)response;

#pragma mark - v1.0.0
/*
 You should set token or cookie in HTTPHeaderField if needed for two methods below.
 */

/// for GET
- (void)jh_set_GET_URL:(NSString *)url parameter:(NSDictionary *)dic;
/// for POST
- (void)jh_set_POST_URL:(NSString *)url parameter:(NSDictionary *)dic;

@end

/**< Example:
 
 ---------------------- version 1.2.0 ---------------------------
 
 GET request :
 
 NSURLSessionDataTask *task = [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     // other code
 
 #if DEBUG
    // save for debug.
    [[JHRequestDebugView defaultDebugView] jh_store_history:url parameter:dic response:responseObject];
 #endif
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     // other code
 }];
 
 [[JHRequestDebugView defaultDebugView] jh_set_GET_task:task parameter:dic];
 
 
 ---------------------- version 1.0.0 ---------------------------
 
 You should set token or cookie in HTTPHeaderField if needed (in version 1.0.0).
 
 GET request :
 
 [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     // other code
 
 #if DEBUG
    // save for debug.
    [[JHRequestDebugView defaultDebugView] jh_store_history:URL parameter:dic response:responseObject];
 #endif
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     // other code
 }];
 
 [[JHRequestDebugView defaultDebugView] jh_set_GET_URL:url parameter:dic];
 
 */
