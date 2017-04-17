
目的

解耦
可插拔
统一调用方式





URLRoute所需要的功能

1. 打开页面
1.1 打开方式 push & present & addSubview (Android均为转场动画)
1.2 传递参数 基本类型 & 对象
1.3 from & fromId & mobilePage
1.4 登录检查
1.5 回调
1.6 失败处理：降级为wap or 无响应 or 返回首页

2. 跳转tab

3. 使用功能服务
3.1 关闭当前界面
3.2 跟单
3.3 弹窗
3.4 查看剪贴板
3.5 修改title
3.6 分享
3.7 登录

4. 注册和管理支持的页面列表

5. 跳转前弹出 确认窗 或 登录界面



仿HTTP，Request & Response

URL规范

scheme://host/path/id?params=encode({json})&sign=md5({json}+key)

scheme————协议，指明app
host————域名，h5域名
path————路径，要打开的页面或服务
id————页面标识
params————参数列表，百分号编码的json字符串
sign————验签，确保参数的完整性和安全性



仿 CNginx，重写，对旧版兼容

读取配置文件；
openUrl:
将URL转成对象（重写结果）



