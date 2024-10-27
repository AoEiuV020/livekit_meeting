#import "MyObjectiveCViewController.h"
#import <Flutter/Flutter.h> // 导入 Flutter 相关头文件
#import "GeneratedPluginRegistrant.h" // 导入生成的插件注册文件
#import "meetingmoduleexample-Swift.h"

@implementation MyObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化文本框和按钮
    [self setupUI];
    // 加载已保存的输入内容
    [self loadSavedInputs];
}

- (void)setupUI {
    // 设置 serverUrl 输入框
    self.serverUrlTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 100, self.view.frame.size.width - 40, 40)];
    self.serverUrlTextField.placeholder = @"Enter Server URL";
    self.serverUrlTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.serverUrlTextField];
    
    // 设置 room 输入框
    self.roomTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 160, self.view.frame.size.width - 40, 40)];
    self.roomTextField.placeholder = @"Enter Room";
    self.roomTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.roomTextField];
    
    // 设置 name 输入框
    self.nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 220, self.view.frame.size.width - 40, 40)];
    self.nameTextField.placeholder = @"Enter Name";
    self.nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.nameTextField];
    
    // 设置 connect 按钮
    self.connectButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.connectButton.frame = CGRectMake(20, 280, self.view.frame.size.width - 40, 50);
    [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
    [self.connectButton addTarget:self action:@selector(connectButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.connectButton.backgroundColor = [UIColor blueColor];
    [self.connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.connectButton.layer.cornerRadius = 8;
    [self.view addSubview:self.connectButton];
}

- (void)loadSavedInputs {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 读取已保存的内容并填充输入框
    self.serverUrlTextField.text = [defaults stringForKey:@"serverUrl"] ?: @"https://meet.livekit.io";
    self.roomTextField.text = [defaults stringForKey:@"room"] ?: @"123456";
    self.nameTextField.text = [defaults stringForKey:@"name"] ?: @"iosOc";
}

- (void)connectButtonTapped {
    // 获取输入的文本
    NSString *serverUrl = self.serverUrlTextField.text ?: @"";
    NSString *room = self.roomTextField.text ?: @"";
    NSString *name = self.nameTextField.text ?: @"";
    
    // 将输入内容保存到 NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:serverUrl forKey:@"serverUrl"];
    [defaults setObject:room forKey:@"room"];
    [defaults setObject:name forKey:@"name"];
    [defaults synchronize];

    // 创建 FlutterViewController
    LivekitDemoViewController *vc = [[LivekitDemoViewController alloc] initWithServerUrl:serverUrl room:room name:name];

    vc.modalPresentationStyle = UIModalPresentationFullScreen; // 设置全屏展示
    [self presentViewController:vc animated:YES completion:nil]; // 打开 Flutter 页面
}

@end
