#pragma once
#include <windows.h>

// 自定义消息定义
#define WM_CUSTOM_MESSAGE1 (WM_USER + 1)  // 主窗口发送到第二窗口的消息
#define WM_CUSTOM_MESSAGE2 (WM_USER + 2)  // 第二窗口发送到主窗口的消息

// 创建第二个窗口的函数声明
void CreateSecondWindow(HINSTANCE hInstance);

// 获取第二个窗口句柄
HWND GetSecondWindowHandle(); 