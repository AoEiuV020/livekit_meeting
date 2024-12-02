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

void CreateSecondWindow(HINSTANCE hInstance) {
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
        0,
        SECOND_CLASS_NAME,
        L"Second Window",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 400, 300,
        NULL,
        NULL,
        hInstance,
        NULL
    );

    if (g_hwndSecond) {
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
                // 获取主窗口句柄（这里假设主窗口是第二窗口的所有者）
                HWND mainWindow = GetWindow(hwnd, GW_OWNER);
                if (!mainWindow) {
                    // 如果没有所有者窗口，尝试找到主窗口
                    mainWindow = FindWindowW(L"Simple Window Class", L"Main Window");
                }
                if (mainWindow) {
                    // 发送消息到主窗口
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