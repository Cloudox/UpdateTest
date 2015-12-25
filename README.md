# UpdateTest
学习自动检查更新版本——与app store上的对比

## 介绍
我们常常需要提示用户更新应用，那么如何获取有新版本的信息呢？有两种方式：
* 向自己服务器请求并对比版本号
* 向App Store请求并对比版本信息  

向自己的服务器请求版本号和请求别的信息没有什么区别，让后台配合一下就好了，这里只介绍向App Store请求的方法。  
向App Store请求，实时性是很好的，而且在请求版本信息时，去往App Store下载的链接也会一并返回，可以直接使用，非常方便。但向苹果的服务器请求数据据说会比较慢，想象起来还是没有向自己的服务器请求的靠谱。

## 方法
### 向app store请求版本信息
```Objective-C
// 请求url  
NSString *versionUrl = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%@", appID];  
NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:versionUrl]];  
```
其中，AppID：当我们在自己的开发者中心创建一个应用后，就会得到一个应用的专属AppID，这个AppID不是我们创建证书时创建的那个Identifier，而是自动生成的一串唯一的数字，在开发者中心创建应用后，进入应用的网页后，网址最后面的那串数字就是我们应用的AppID，我们就是凭借这个AppID告诉app store我们要查询的是哪个应用的版本信息。  
查到自己的AppID后就可以进行版本信息的请求了，url是固定的，改变的只有最后的AppID，同时我们也把当下的版本获取到，这里简单地写一个，真是应用的话，应该长久保存在本地。

### 处理返回的数据
app store 返回的数据是一个多层嵌套的json数据，这里直接给出如何解析获得我们需要的版本号及下载链接。其实获取的还有其他的信息，具体想了解的话可以输出查看一下。
```Objective-C
// 收到的回复  
NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];  
  
// 转换成键值对形式  
NSError *error;  
NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];  
if (error) {  
    NSLog(@"error: %@", [error description]);  
    return;  
}  
NSLog(@"%@", appInfoDic);// 可输出查看回复的详细信息  
  
// 查看具体内容中内容数是否为空  
NSArray *resultsArray = [appInfoDic objectForKey:@"results"];  
if (![resultsArray count]) {  
    NSLog(@"error: resultsArray == nil");  
    return;  
}  
// 获取具体需要的信息  
NSDictionary *infoDic = [resultsArray objectAtIndex:0];  
self.latestVersion = [infoDic objectForKey:@"version"];// 版本号  
self.trackViewUrl = [infoDic objectForKey:@"trackViewUrl"];// 更新的url地址  
```
这里在第一次转换成Dictionary格式后，可以输出看看都获取了一些什么信息，之后就是具体提出我们需要的版本号来进行对比，以及去往app store更新的url地址。

### 提示用户更新
获取到app store上最新的版本号后，就可以和本地存储的版本号进行对比了，如果有新的版本，就弹出提示框提示用户有新版本。
```Objective-C
// 弹出提示框  
if (![currentVersion isEqualToString:self.latestVersion]) {  
    NSString *messageStr = [NSString stringWithFormat:@"发现新版本：%@，是否前往更新？", self.latestVersion];  
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:messageStr delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"更新", nil nil];  
    alert.tag = 10000;// 给提示框加上标签告知是更新的提示框  
    [alert show];  
}   
```

详细说明见[我的博客](http://blog.csdn.net/cloudox_/article/details/47724357)
