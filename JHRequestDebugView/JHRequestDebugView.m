//
//  JHRequestDebugView.m
//  JHKit
//
//  Created by HaoCold on 2017/10/23.
//  Copyright © 2017年 HaoCold. All rights reserved.
//
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

#import "JHRequestDebugView.h"
#import "JHRequestHistoryView.h"

#define kTitleBackgroundColor [UIColor colorWithRed:0 green:199/255.0 blue:140/255.0 alpha:1]
#define kTitleColor [UIColor colorWithRed:0 green:199/255.0 blue:140/255.0 alpha:0.5]

NSString *const kJHRequestDebugViewNotification = @"kJHRequestDebugViewNotification";

@interface JHRequestDebugView()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
/// request url.
@property (copy,    nonatomic) NSString *url;
/// request method.
@property (copy,    nonatomic) NSString *method;
/// request parameter.
@property (strong,  nonatomic) NSDictionary *dic;
///
@property (strong,  nonatomic) UITableView *tableView;
///
@property (strong,  nonatomic) UIWebView *debugWebView;
///
@property (strong,  nonatomic) UIButton *jsonFormatButton;
///
@property (strong,  nonatomic) UIButton *historyButton;
///
@property (strong,  nonatomic) UIButton *closeButton;
///
@property (assign,  nonatomic,  getter=isShow) BOOL  show;
///
@property (copy,    nonatomic) NSString *response;
///
@property (strong,  nonatomic) NSMutableArray *urlArray;
///
@property (assign,  nonatomic) NSInteger currentUrlIndex;
///
@property (nonatomic,  strong) NSMutableArray *historyArray;
///
@property (nonatomic,  strong) JHRequestHistoryView *historyView;

@end

@implementation JHRequestDebugView

#if 0 //the below code is not necessary.
+ (void)load{
    //delay load
    /**< iOS 11 CRASH!
     *** Assertion failure in -[UIGestureGraphEdge initWithLabel:sourceNode:targetNode:directed:], /BuildRoot/Library/Caches/com.apple.xbs/Sources/UIKit/UIKit-3698.21.8/Source/GestureGraph/UIGestureGraphEdge.m:25
     2017-11-22 16:19:57.847231+0800 PalmGraspDollMachine[23073:3850447] *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Invalid parameter not satisfying: targetNode'
     
     solution:
     https://huang.sh/2016/09/wkwebview%E5%9C%A8ios-10%E4%B8%8Acrash-invalid-parameter-not-satisfying-targetnode/
     
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [JHRequestDebugView defaultDebugView];
    });
}
#endif

+ (instancetype)defaultDebugView{
    static JHRequestDebugView *debugView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        debugView = [[JHRequestDebugView alloc] initWithFrame:CGRectZero];
    });
    return debugView;
}

+ (instancetype)new{
    return [JHRequestDebugView defaultDebugView];
}

- (instancetype)initWithFrame:(CGRect)frame{
    frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        [self jhSetupViews];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xx_begin_debug) name:kJHRequestDebugViewNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xx_layout_subviews) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private
- (void)jhSetupViews{
    //mask view
    UIView *maskView = [[UIView alloc] init];
    maskView.frame = [UIScreen mainScreen].bounds;
    maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:maskView];
    
    _urlArray = @[].mutableCopy;
    _historyArray = @[].mutableCopy;
    
    [self addSubview:self.tableView];
    [self addSubview:self.debugWebView];
    [self addSubview:self.historyView];
    [self addSubview:self.jsonFormatButton];
    [self addSubview:self.historyButton];
    [self addSubview:self.closeButton];
}

- (UIButton *)jhSetupButton:(CGRect)frame title:(NSString *)title selector:(SEL)selector{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = kTitleBackgroundColor.CGColor;
    button.backgroundColor = kTitleBackgroundColor;//[UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:title forState:0];
    [button setTitleColor:[UIColor whiteColor] forState:0];
    [button addTarget:self action:selector forControlEvents:1<<6];
    return button;
}

- (void)xx_close{
    _show = NO;
    _response = @"";
    _debugWebView.hidden = YES;
    [UIPasteboard generalPasteboard].string = @"";
    [self removeFromSuperview];
}

- (void)xx_begin_debug{
    
    if (_show == YES || _url.length == 0 || _method.length == 0) {
        return;
    }
    
    NSDictionary *dic = _urlArray[_currentUrlIndex];
    
    NSMutableURLRequest *request = dic[@"request"];
    if (!request) {
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
        request.HTTPMethod = _method;
        request.timeoutInterval = 10;
        NSMutableArray *httpBodys = @[].mutableCopy;
        for (NSString *key in _dic.allKeys) {
            NSString *value = _dic[key];
            [httpBodys addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        }
        NSString *bodyString = [httpBodys componentsJoinedByString:@"&"];
        
        if ([_method isEqualToString:@"GET"]) {
            NSString *URL = _url;
            if (bodyString.length > 0) {
                URL = [NSString stringWithFormat:@"%@?%@",_url,bodyString];
            }
            URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            request.URL = [NSURL URLWithString:URL];
        }else if ([_method isEqualToString:@"POST"]){
            request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
        }
        
#warning "You should set token or cookie in HTTPHeaderField if needed (in version 1.0.0)."
#if 0
        // cookie
        NSArray *array = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"request"]];
        NSDictionary *cookdict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
        NSString *cookie = cookdict[@"Cookie"];
        if (cookie.length > 0) {
            [request setValue:cookie forHTTPHeaderField:@"Cookie"];
        }
        // token
        NSString *token = @"token"
        if (token) {
            [request setValue:token forHTTPHeaderField:@"Authorization"];
        }
#endif
    }
    
    // request
    [_debugWebView loadRequest:request];
    // reload
    [_tableView reloadData];
    // show
    _show = YES;
    
    //add to window
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows)
    {
        if (window.windowLevel == UIWindowLevelNormal)
        {
            [window addSubview:self];
            [window bringSubviewToFront:self];
            break;
        }
    }
}

- (void)xx_layout_subviews{
    self.frame = [UIScreen mainScreen].bounds;
    [_tableView reloadData];
}

- (void)xx_json_format{
    if (!_debugWebView.hidden) {
        _debugWebView.hidden = YES;
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSONFormat.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    [_debugWebView loadRequest:[NSURLRequest requestWithURL:url]];
    _debugWebView.frame = _tableView.frame;
    _debugWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _debugWebView.hidden = NO;
}

- (void)xx_history{
    _historyView.hidden = !_historyView.hidden;
    if (!_historyView.hidden) {
        [_historyView reloadData];
    }
}

- (void)xx_see_history:(NSDictionary *)dic{
    _historyView.hidden = !_historyView.hidden;
    
    _url = dic[@"url"];
    _dic = dic[@"parameter"];
    _response = ({
        NSString *JSON;
        NSDictionary *dict;
        @try{
            dict = [NSJSONSerialization JSONObjectWithData:dic[@"response"] options:kNilOptions error:nil];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:NULL];
            JSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
        @catch (NSException *exception) {
            NSLog(@"exception:%@",exception);
            JSON = exception.description;
        }
        @finally {
            if (JSON.length == 0) {
                JSON = [NSString stringWithFormat:@"%@",dic[@"response"]];
            }
        }
        JSON;
    });
    
    NSString *result = [NSString stringWithFormat:@"url:\n%@\n\nparam:\n%@\n\nresponse:\n%@\n\n",_url,_dic,_response];
    [UIPasteboard generalPasteboard].string = result;
    [_tableView reloadData];
}

- (void)xx_choose:(UIButton *)button{
    
    NSInteger count = _urlArray.count;
    
    if (button.tag == 100) { //left
        _currentUrlIndex--;
        if (_currentUrlIndex < 0) {
            _currentUrlIndex = 0;
            return;
        }
    }else{ //right
        _currentUrlIndex++;
        if (_currentUrlIndex >= count) {
            _currentUrlIndex = count - 1;
            return;
        }
    }
    
    if (_currentUrlIndex >= 0 && _currentUrlIndex < count) {

        NSDictionary *dic = _urlArray[_currentUrlIndex];
        NSURLRequest *request = dic[@"request"];
        if (request) {
            _url = request.URL.absoluteString;
        }else{
            _url = dic[@"url"];
        }
        _dic    = dic[@"dic"];
        _method = dic[@"method"];

        _show = NO;
        
        [self xx_begin_debug];
    }
}

- (void)xx_save_url:(NSURLSessionDataTask *)task{
    
    NSMutableDictionary *urlDic = @{}.mutableCopy;
    if (task) {
        [urlDic setValue:task.originalRequest forKey:@"request"];
    }else{
        [urlDic setValue:_url forKey:@"url"];
    }
    [urlDic setValue:_dic forKey:@"dic"];
    [urlDic setValue:_method forKey:@"method"];
    
    @synchronized(self) {
        [_urlArray addObject:urlDic];
        
        while (_urlArray.count > 5) {
            [_urlArray removeObjectAtIndex:0];
        }
        
        _currentUrlIndex = _urlArray.count - 1;
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"view_id"];
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"view_id"];
        view.frame = CGRectMake(0, 0, CGRectGetWidth(_tableView.frame), 15);
        view.tintColor = kTitleColor;
    }
    if (0 == section) {
        view.textLabel.text = @"url:";
    }else if (1 == section){
        view.textLabel.text = @"paramter:";
    }else if (2 == section){
        view.textLabel.text = @"response:";
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"resueID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 0;
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = _url;
    }else if (indexPath.section == 1){
        NSDictionary *dic = _dic;
        cell.textLabel.text = dic.description;
    }else{
        cell.textLabel.text = _response;
    }
    return cell;
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //本地html
    if (!webView.hidden) {
        //设置textarea 内容
        NSString *js = [NSString stringWithFormat:@"document.getElementById(\"RawJson\").value = '%@';",_response];
        [webView stringByEvaluatingJavaScriptFromString:js];
        
        //模拟点击 着色 按钮
        js = @"var clickEvent=document.createEvent('MouseEvent');" // 1.创建一个鼠标事件类型
              "clickEvent.initMouseEvent('click',false,false,window,0,0,0,0,0,false,false,false,false,0,null);" // 2.初始化一个click事件
              "document.getElementById('ZSbutton').dispatchEvent(clickEvent);"; // 3.派发(触发)
        [webView stringByEvaluatingJavaScriptFromString:js];
        
        //
        //_response = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('Canvas').innerText"];
        //[_tableView reloadData];
        return;
    }
    
    //请求数据
    NSString *innerText = @"document.body.innerText";
    innerText = [webView stringByEvaluatingJavaScriptFromString:innerText];
    NSData *data = [innerText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (dic) {
        _response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }else{
        _response = innerText;
    }
    NSString *result = [NSString stringWithFormat:@"url:\n%@\n\nparam:\n%@\n\nresponse:\n%@\n\n",_url,_dic,_response];
    [UIPasteboard generalPasteboard].string = result;
    [_tableView reloadData];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    _response = error.localizedDescription;
    NSString *result = [NSString stringWithFormat:@"url:\n%@\n\nparam:\n%@\n\nresponse:\n%@\n\n",_url,_dic,_response];
    [UIPasteboard generalPasteboard].string = result;
    [_tableView reloadData];
}

#pragma mark - public

- (void)jh_set_GET_task:(NSURLSessionDataTask *)task parameter:(NSDictionary *)dic{
    _url = task.originalRequest.URL.absoluteString; _dic = dic; _method = @"GET";
    [self xx_save_url:task];
}

- (void)jh_set_POST_task:(NSURLSessionDataTask *)task parameter:(NSDictionary *)dic{
    _url = task.originalRequest.URL.absoluteString; _dic = dic; _method = @"POST";
    [self xx_save_url:task];
}

- (void)jh_set_GET_URL:(NSString *)url parameter:(NSDictionary *)dic{
    _url = url; _dic = dic; _method = @"GET";
    [self xx_save_url:nil];
}

- (void)jh_set_POST_URL:(NSString *)url parameter:(NSDictionary *)dic{
    _url = url; _dic = dic; _method = @"POST";
    [self xx_save_url:nil];
}

- (void)jh_store_history:(NSString *)url parameter:(NSDictionary *)dic response:(NSDictionary *)response{
    NSMutableDictionary *mdic = @{}.mutableCopy;
    [mdic setValue:url forKey:@"url"];
    [mdic setValue:dic forKey:@"parameter"];
    [mdic setValue:response forKey:@"response"];
    
    @synchronized(self) {
        [_historyArray insertObject:mdic atIndex:0];
        while (_historyArray.count > 100) {
            [_historyArray removeLastObject];
        }
    }
}

#pragma mark - setter & getter
- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat W = [UIScreen mainScreen].bounds.size.width - 30;
        CGFloat H = [UIScreen mainScreen].bounds.size.height - 100;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 40, W, H) style:0];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.layer.cornerRadius = 5;
        tableView.clipsToBounds = YES;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.sectionHeaderHeight = 25;
        tableView.tableFooterView = [[UIView alloc] init];
        tableView.showsVerticalScrollIndicator = NO;
        tableView.tableHeaderView = ({
            UILabel *title = [[UILabel alloc] init];
            title.frame = CGRectMake(0, 0, W, 40);
            title.text = @"JHRequestDebugView";
            title.textColor = [UIColor whiteColor];
            title.font = [UIFont boldSystemFontOfSize:18];
            title.textAlignment = NSTextAlignmentCenter;
            title.backgroundColor = kTitleBackgroundColor;
            title.userInteractionEnabled = YES;
            
            CGFloat w = CGRectGetHeight(title.frame);
            //left button
            UIButton *leftButton = [self jhSetupButton:CGRectMake(0,0,w,w) title:@"<<" selector:@selector(xx_choose:)];
            leftButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            leftButton.tag = 100;
            
            //right button
            UIButton *rightButton = [self jhSetupButton:CGRectMake(W-w,0,w,w) title:@">>" selector:@selector(xx_choose:)];
            rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            rightButton.tag = 200;
            
            [title addSubview:leftButton];
            [title addSubview:rightButton];
            
            title;
        });
        _tableView = tableView;
    }
    return _tableView;
}

- (UIWebView *)debugWebView{
    if (!_debugWebView) {
        UIWebView *webView = [[UIWebView alloc] init];
        webView.delegate = self;
        webView.hidden = YES;
        webView.layer.cornerRadius = 5;
        webView.clipsToBounds = YES;
        webView.scrollView.showsVerticalScrollIndicator = NO;
        webView.scrollView.showsHorizontalScrollIndicator = NO;
        _debugWebView = webView;
    }
    return _debugWebView;
}

- (JHRequestHistoryView *)historyView{
    if (!_historyView) {
        _historyView = [[JHRequestHistoryView alloc] initWithFrame:_tableView.frame];
        _historyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _historyView.hidden = YES;
        _historyView.dataArray = _historyArray;
        
        __weak typeof(self) ws = self;
        _historyView.clickBlock = ^(NSDictionary *dic) {
            [ws xx_see_history:dic];
        };
    }
    return _historyView;
}

- (UIButton *)jsonFormatButton{
    if (!_jsonFormatButton) {
        CGRect frame = CGRectMake(CGRectGetMinX(_tableView.frame), CGRectGetMaxY(_tableView.frame) + 10 , (CGRectGetWidth(_tableView.frame) - 20)/3, 40);
        UIButton *button = [self jhSetupButton:frame title:@"JSON Format" selector:@selector(xx_json_format)];
        button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _jsonFormatButton = button;
    }
    return _jsonFormatButton;
}

- (UIButton *)historyButton{
    if (!_historyButton) {
        CGRect frame = CGRectMake(CGRectGetMaxX(_jsonFormatButton.frame)+10, CGRectGetMinY(_jsonFormatButton.frame), CGRectGetWidth(_jsonFormatButton.frame), CGRectGetHeight(_jsonFormatButton.frame));
        UIButton *button = [self jhSetupButton:frame title:@"History" selector:@selector(xx_history)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin| UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _historyButton = button;
    }
    return _historyButton;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        CGRect frame = CGRectMake(CGRectGetMaxX(_historyButton.frame)+10,CGRectGetMinY(_jsonFormatButton.frame), CGRectGetWidth(_jsonFormatButton.frame), CGRectGetHeight(_jsonFormatButton.frame));
        UIButton *button = [self jhSetupButton:frame title:@"Close it" selector:@selector(xx_close)];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _closeButton = button;
    }
    return _closeButton;
}

@end
