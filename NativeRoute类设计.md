###@class NativeNgnix 
#####// 负责将原始url转成客户端可以识别的样式，或转成已有h5页面的url。

	+ (void)checkAndUpdateConfigurationFile:(NSURL *)filePath; // 检查并更新配置文件，
	+ (void)loadConfigurationFile:(NSURL *)filePath; // 加载配置文件，读取转换规则
	+ (NSInteger)matchRules:(NSString *)url; // 匹配规则，得到
	+ (void)parseUrl:(NSStirng *)url;  // 解析url



###@class NativeRoute 
######// 负责路由，页面跳转

	+ (BOOL)canOpenUrl; // 检查是否支持该跳转或服务
	+ (BOOL)openUrl:(NSString *)url;
	+ (void)openUrl:(NSString *)url completionHandler:(void (^)(RouteResponse* response, NSData* data, NSError* error))handler;
	+ (BOOL)openRequest:(RouteRequest *)request;
	+ (void)openRequest:(RouteRequest *)request completionHandler:(void (^)(RouteResponse* response, NSData* data, NSError* error)) handler;




###@class RouteRequest 
#####// 路由请求

	@property (readonly) NSString *url; // 路由的初始url
	@property (readonly) NSString *routeType; // 路由类型，跳转 & 服务
	@property (readonly) NSString *transformType; // 转场动画，PUSH & PRESENT & SHOW
	@property (readonly) NSString *alias; // 目标别名
	@property (readonly) NSString *action; // 服务别名
	@property NSDictionary *params； // 跳转或服务携带的参数
	@property (weak) UIViewController *source; // 跳转的来源界面

	- (instancetype) initWithUrl:(NSString *)url;
	- (instancetype) initWithRouteTransform:(NSString *)transformType alias:(NSString *)alias params:(NSDictionary *)params source:(UIViewController *)source;
	- (instancetype) initWithRouteService:(NSString *)action params:(NSDictionary *)params source:(UIViewController *)source;


###@class RouteResponse 
#####// 路由响应
	
	@property (readonly) NSString *url; // 路由的初始url
	@property (readonly) NSInteger statusCode; // 路由结果状态码
	@property (weak) UIViewController *source; // 跳转的来源界面
	@property (readonly) UIViewController *target; // 跳转到的目标界面

	- (instancetype) initWithUrl:(NSString *)url statusCode:(NSInteger)statusCode source:(UIViewController *)source target:(NSString *)target;
