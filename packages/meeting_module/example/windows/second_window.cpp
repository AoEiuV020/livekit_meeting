#include "second_window.h"

// 定义按钮ID
#define ID_SEND_BACK_BUTTON 2001

// 保存第二个窗口的句柄
static HWND g_hwndSecond = NULL;
static WCHAR g_receivedText[256] = L"等待消息...";  // 存储接收到的消息

// 第二个窗口的过程函数声明
LRESULT CALLBACK SecondWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

HWND GetSecondWindowHandle() {
    return g_hwndSecond;
}

void CreateSecondWindow(HINSTANCE hInstance, HWND parentWindow) {
    // 注册第二个窗口类
    const wchar_t SECOND_CLASS_NAME[] = L"Second Window Class";
    
    WNDCLASSW wc = {};
    wc.lpfnWndProc = SecondWindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = SECOND_CLASS_NAME;
    wc.hbrBackground = (HBRUSH)COLOR_WINDOW;

    RegisterClassW(&wc);

    // 创建第二个窗口
    g_hwndSecond = CreateWindowExW(
        0,                    // 基本窗口样式
        SECOND_CLASS_NAME,
        L"Second Window",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 400, 300,
        NULL,                 // 父窗口先设为NULL
        NULL,
        hInstance,
        NULL
    );

    if (g_hwndSecond) {
        // 设置窗口所有者
        SetWindowLongPtr(g_hwndSecond, GWLP_HWNDPARENT, (LONG_PTR)parentWindow);

        // 创建发送消息按钮
        CreateWindowW(
            L"BUTTON",
            L"发送回主窗口",
            WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
            150, 200, 100, 30,
            g_hwndSecond,
            (HMENU)ID_SEND_BACK_BUTTON,
            hInstance,
            NULL
        );

        ShowWindow(g_hwndSecond, SW_SHOW);
        UpdateWindow(g_hwndSecond);
    }
}

// 第二个窗口的过程函数
LRESULT CALLBACK SecondWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            
            // 显示接收到的消息
            TextOutW(hdc, 150, 120, g_receivedText, lstrlenW(g_receivedText));

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_SEND_BACK_BUTTON) {
                // 使用 GWLP_HWNDPARENT 获取所有者窗口句柄
                HWND mainWindow = (HWND)GetWindowLongPtr(hwnd, GWLP_HWNDPARENT);
                if (mainWindow) {
                    PostMessageW(mainWindow, WM_CUSTOM_MESSAGE2, 0, 0);
                }
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE1: {
            // 接收来自主窗口的消息
            lstrcpyW(g_receivedText, L"收到来自主窗口的消息！");
            // 强制重绘窗口以更新文本
            InvalidateRect(hwnd, NULL, TRUE);
            return 0;
        }

        case WM_DESTROY: {
            g_hwndSecond = NULL;
            return 0;
        }

        return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
} 