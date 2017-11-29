# JHRequestDebugView
请求调试窗口

### 3 files:
```
JHRequestDebugView.h
JHRequestDebugView.m
UIWindow+JHRequestDebugViewShake.h
UIWindow+JHRequestDebugViewShake.m
JSONFormat.html
```

### Steps: 

#### skip step 1
#### go step 2
-2017-11-29 18:32:10 

#### 1.add this in AppDelegate.m
``` 
 - (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kJHRequestDebugViewNotification" object:nil];
 }
```

#### 2.invoke 
 ```
 [[JHRequestDebugView defaultDebugView] jh_set_GET_URL:url parameter:dic];
 or
 [[JHRequestDebugView defaultDebugView] jh_set_POST_URL:url parameter:dic];
 ```
#### before or after the following code.
 ```
 AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
 [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
    //...
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //...
 }];

[[JHRequestDebugView defaultDebugView] jh_set_GET_URL:url parameter:dic];
 ```
 
 
 
 ⚠️⚠️⚠️
 When you shake your phone, and nothing happen!
 Add a category about UIWindow
 
 ```
 .h
 @interface UIWindow (JHRequestDebugViewShake)
 @end
 
 .m
 @implementation UIWindow (JHRequestDebugViewShake)
 -(BOOL)canBecomeFirstResponder{
 return YES;
 }
 
 - (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
 [[NSNotificationCenter defaultCenter] postNotificationName:@"kJHRequestDebugViewNotification" object:nil];
 }
 @end
 ```
 
#### 3.just shake your phone to call it out.
 
 ### images:
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.38.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.46.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.57.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.16.06.png)
