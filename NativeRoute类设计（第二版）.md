###@class NativeNginx 
#####// 负责将原始url转成客户端可以识别的样式，或转成已有h5页面的url。

	+ (instancetype)shared; // 共享Nginx
	- (BOOL)loadConfigFile:(NSURL *)filePath; // 加载配置文件，读取转换规则，文件路径不可为空
	- (instancetype)initWithConfigFile:(NSURL *)filePath; // 可以直接通过ConfigFile初始化Nginx，调用该方法之后，shared方法取得的是最近一次初始化方法生成的对象，旧有的对象会释放
	- (BOOL)rewriteUrl:(NSStirng *)url toReplacement:(NSSting **)replacement andRule:(NSString **)ruleType;  // 重写url，返回
	- (void)checkAndUpdateConfigurationFile:(NSURL *)filePath; // 检查并更新配置文件

	@property (copy, nonatomic) NSString *configFile;// 默认为空

###@class NativeRouter 
######// 负责路由，页面跳转

	+ (instancetype)shared;
	- (void)startNginx;//启动Nginx服务
	- (BOOL)openRequest:(RouteRequest *)request;
	- (void)openRequest:(RouteRequest *)request completionHandler:(void (^)(RouteResponse* response, NSData* data, NSError* error)) handler;
	@private
	@property (copy, nonatomic) NSString *nginxConfigFile; // nginx的配置文件路径，暂时不支持外部配置
	@property (copy, nonatomic) NSString *routeConfigFile; // 路由表


###@class RouteRequest 
#####// 路由请求

	@property (readonly, copy) NSString *url; // 路由的初始url
	@property (readonly, copy) NSString *ruleType; // url使用的规则类型
	@property (readonly, copy) NSString *replacement; // 将url通过nginx转换的结果
	@property (copy, nonatomic) NSString *routeMethod; // 路由请求的方法，GET/POST等
	@property (strong, nonatomic) NSData *postData； // 主要用于传递非基本类型的数据（基本类型一般转成了replacement）
	@property (weak, nonatomic) UIViewController *sourceVC; // 路由请求的来源界面，Android为sourceActivity

	- (instancetype) initWithUrl:(NSString *)url; // 通过url初始化路由请求，url会被nginx替换成ruleType和replacement
	- (instancetype) initWithRule:(NSString *)ruleType andReplacement:(NSString *)replacement; // 通过ruleType和replacement初始化路由请求，通过这种方法初始化时不会调用nginx方法
	- (void)setSourceVC:(UIViewController *)sourceVC; //设置来源界面，若未设置或设置为nil，NativeRoute会尽力获取到当前最上层的VC以保证成功路由

###@class RouteResponse 
#####// 路由响应
	
	@property (readonly) NSString *url; // 路由的初始url
	@property (readonly) NSInteger statusCode; // 路由结果状态码
	@property (weak, readonly) UIViewController *source; // 跳转的来源界面
	
	- (instancetype) initWithUrl:(NSString *)url statusCode:(NSInteger)statusCode source:(UIViewController *)source;



--
**用法说明：**

1. **NativeRouter**通过*shared*方法内部实现初始化，所以对初始化启动路由服务的时机没有强制要求，但建议尽早通过*startNginx*方法启动**NativeNginx**服务。

		[[NativeRouter shared] startNginx];

2. **NativeRouter**同样通过*shared*方法内部实现初始化，在初始化之后可以调用*loadConfigFile:*加载Nginx的配置文件；也可以直接通过配置文件初始化*initWithConfigFile:*，但要注意调用初始化方法之后，*shared*方法取到的总是最后一个初始化的对象。

3. 在**NativeRouter**的*startNginx*方法中会初始化**NativeNginx**。

		[[NativeNginx shared] loadConfigFile:self. nginxConfigFile];

4. 当调用方使用路由服务时，需要先通过url初始化一个**RouteRequest**，初始化时Nginx会根据配置表重写url为*replacement*和*ruleType*。

		RouteRequest *request = [[RouteRequest alloc] initWithUrl:aUrl];

	或者可以直接通过已知的*replacement*和*ruleType*初始化Request，这样初始化时将不会调用Nginx服务。
	
		RouteRequest *request = [[RouteRequest alloc] initWithRule:ruleType andReplacement:aString];
	
5. 如果需要传递非基本类型的参数，可以通过*postData*传递，只需要将*routeMethod*设置成**POST**即可，就像HTTP请求一样。

		NSData *imageData = UIImagePNGRepresentation(image);
		request.postData = imageData;
		request.routeMethod = @"POST";

6. 最后建议将当前的界面告诉**NativeRouter**，虽然即使不传，路由模块也会尽量保证完成交给的任务，但是总没有亲自交代的那么靠谱，并且提供*sourceVC*的信息对于统计也是有帮助的。

		[request setSourceVC:aViewController];
		
7. 当一切准备好了，向**NativeRouter**发出请求就可以享受路由服务了。

		BOOL routeResult = [[NativeRouter shared] openRequest:routeRequest];
		
	或
	
		[[NativeRouter shared] openRequest:routeRequest completionHandler:(void (^)(RouteResponse* response, NSData* data, NSError* error)) {
			if (response != nil && response.statusCode == 200) {
				......
			}
		}];
		
	这两种方式所做的工作完全相同，唯一的区别只在于你是否需要回调。
	
8. **NativeRouter**在收到请求时，会根据request的*ruleType*选择调用旧系统中有的逻辑，还是使用新的逻辑。这可以很好的帮助过渡到新的路由框架下，并且在未来也可以利用这套机制实现迭代。

9. 在新逻辑下，**NativeRouter**读取本地配置的路由表*routeConfigFile*判断是否可以完成这次跳转或操作。

	* 对于跳转请求，如果在路由表中找到对应的界面类名，则相应的完成路由；否则，降级为H5，将原始*request.url*的**scheme**替换成**http://**，由webview打开。
	
	* 对于操作请求，如果在路由表中找到对应的功能方法名，则调用**NativeApi**的对应方法，去完成该操作。功能完成后，通过**block**将结果回调给请求方。