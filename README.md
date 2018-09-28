# JHRequestDebugView
请求调试窗口

---

### 3+2 files:
```
JSONFormat.html          // JSON格式化
JHRequestDebugView.h     // 调试窗口
JHRequestDebugView.m
JHRequestHistoryView.h   // 历史记录
JHRequestHistoryView.m
UIWindow+JHRequestDebugViewShake.h   // 摇一摇
UIWindow+JHRequestDebugViewShake.m
```
---

### Logs
1.添加历史记录(add history).(2018-9-28)

---

### Steps: 

-2017-11-29 18:32:10 

#### 1.invoke 
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
#if DEBUG
    // save for debug.
    [[JHRequestDebugView defaultDebugView] jh_store_history:URL parameter:dic response:responseObject];
#endif
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    //...
 }];

[[JHRequestDebugView defaultDebugView] jh_set_GET_URL:url parameter:dic];
 ```
#### 2.config in  `JHRequestDebugView`
in `- (void)xx_begin_debug`
set HTTPHeader info if needed.

 
#### 3.just shake your phone to call it out.
 
 ---
 
 ### images:
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.38.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.46.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.15.57.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Screen%20Shot%202017-10-24%20at%2014.16.06.png)
![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Simulator%20Screen%20Shot%20-%20iPhone%208%20-%202018-09-28%20at%2017.37.11.png)
