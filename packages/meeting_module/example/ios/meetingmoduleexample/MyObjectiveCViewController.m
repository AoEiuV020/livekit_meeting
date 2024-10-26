#import "MyObjectiveCViewController.h"
#import <Flutter/Flutter.h> // 导入 Flutter 相关头文件

@implementation MyObjectiveCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor]; // 设置背景颜色为白色

    // 创建按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Open Flutter Page" forState:UIControlStateNormal];
    button.frame = CGRectMake(100, 100, 200, 50); // 设置按钮位置和大小
    [button addTarget:self action:@selector(openFlutterPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:button]; // 将按钮添加到视图中
}

- (void)openFlutterPage:(UIButton *)sender {
    // 直接创建 FlutterViewController
    FlutterViewController *flutterViewController = [[FlutterViewController alloc] init];

    flutterViewController.modalPresentationStyle = UIModalPresentationFullScreen; // 设置全屏展示
    [self presentViewController:flutterViewController animated:YES completion:nil]; // 打开 Flutter 页面
}

@end
