//
//  JHRequestDebugView.m
//  JHKit
//
//  Created by HaoCold on 2017/10/23.
//  Copyright © 2017年 HaoCold. All rights reserved.
//

#import "JHRequestDebugView.h"

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
@property (strong,  nonatomic) UIButton *closeButton;
///
@property (assign,  nonatomic,  getter=isShow) BOOL  show;
///
@property (copy,    nonatomic) NSString *response;
@end

@implementation JHRequestDebugView

+ (void)load{
    [JHRequestDebugView defaultDebugView];
}

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
    [self addSubview:maskView];
    
    [self addSubview:self.tableView];
    [self addSubview:self.debugWebView];
    [self addSubview:self.jsonFormatButton];
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
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]];
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
    
    //You may need to set Cookie for the request.
#if 0
    NSArray *array = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:@"http://www.example.com"]];
    NSDictionary *cookdict = [NSHTTPCookie requestHeaderFieldsWithCookies:array];
    NSString *cookie = cookdict[@"Cookie"];
    if (cookie.length > 0) {
        [request setValue:cookie forHTTPHeaderField:@"Cookie"];
    }
#endif
    
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

- (void)xx_json_format{
    if (!_debugWebView.hidden) {
        _debugWebView.hidden = YES;
        return;
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JSONFormat.html" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    [_debugWebView loadRequest:[NSURLRequest requestWithURL:url]];
    _debugWebView.frame = _tableView.frame;
    _debugWebView.hidden = NO;
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
    NSString *result = [NSString stringWithFormat:@"url:%@\n\nparam:%@\n\nresponse:%@\n\n",_url,_dic,_response];
    [UIPasteboard generalPasteboard].string = result;
    [_tableView reloadData];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    _response = error.localizedDescription;
    NSString *result = [NSString stringWithFormat:@"url:%@\n\nparam:%@\n\nresponse:%@\n\n",_url,_dic,_response];
    [UIPasteboard generalPasteboard].string = result;
    [_tableView reloadData];
}

#pragma mark - public
- (void)jh_set_GET_URL:(NSString *)url parameter:(NSDictionary *)dic{
    _url = url; _dic = dic; _method = @"GET";
}

- (void)jh_set_POST_URL:(NSString *)url parameter:(NSDictionary *)dic{
    _url = url; _dic = dic; _method = @"POST";
}

#pragma mark - setter & getter
- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat W = [UIScreen mainScreen].bounds.size.width - 30;
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, W, W*1.25) style:0];
        tableView.layer.cornerRadius = 5;
        tableView.clipsToBounds = YES;
        tableView.center = self.center;
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

- (UIButton *)jsonFormatButton{
    if (!_jsonFormatButton) {
        CGRect frame = CGRectMake(CGRectGetMinX(_tableView.frame), CGRectGetMaxY(_tableView.frame) + 10 , CGRectGetWidth(_tableView.frame)*0.5 - 10, 40);
        UIButton *button = [self jhSetupButton:frame title:@"JSON Format" selector:@selector(xx_json_format)];
        _jsonFormatButton = button;
    }
    return _jsonFormatButton;
}

- (UIButton *)closeButton{
    if (!_closeButton) {
        CGRect frame = CGRectMake(CGRectGetMaxX(_jsonFormatButton.frame)+20, CGRectGetMaxY(_tableView.frame) + 10 , CGRectGetWidth(_tableView.frame)*0.5 - 10, 40);
        UIButton *button = [self jhSetupButton:frame title:@"Close it" selector:@selector(xx_close)];
        _closeButton = button;
    }
    return _closeButton;
}
@end
