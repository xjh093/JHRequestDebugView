# JHRequestDebugView
请求调试窗口

---

# Files:
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

# Version
Latest version: 1.2.5

# Logs
- 2.添加新方法(add method).(2018-9-29) -> version:1.2.0
- 1.添加历史记录(add history).(2018-9-28) -> version:1.1.0
- 0.upload.

---

# Example:
 
 ---------------------- version 1.2.0 ---------------------------
 
 GET request :
 ```
 NSURLSessionDataTask *task = [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     // other code
 
 #if DEBUG
    [[JHRequestDebugView defaultDebugView] jh_set_GET_task:task parameter:dic];
    [[JHRequestDebugView defaultDebugView] jh_store_history:url parameter:dic response:responseObject];
 #endif
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     // other code
 }];
 ```
 
 ---------------------- version 1.0.0 ---------------------------
 
 You should set token or cookie in HTTPHeaderField if needed (in version 1.0.0).
 
 GET request :
 ```
 [manager GET:url parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     // other code
 
 #if DEBUG
    [[JHRequestDebugView defaultDebugView] jh_set_GET_URL:task.originalRequest.URL.absoluteString parameter:dic];
    [[JHRequestDebugView defaultDebugView] jh_store_history:URL parameter:dic response:responseObject];
 #endif
 
 } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
     // other code
 }];
```
 
## just shake your phone to call it out.
 
 ---
 
 # images:
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Images/01.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Images/02.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Images/03.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Images/04.png)
 ![image](https://github.com/xjh093/JHRequestDebugView/blob/master/Images/05.png)
 

