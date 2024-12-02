#include "second_window.h"
#include <stdio.h>
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
            20, 20, 100, 30,  // 移到左上角
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
            
            // 在左上角显示消息，使用 DrawText 支持自动换行
            RECT rect = { 20, 60, 360, 180 };  // 限制文本区域
            DrawTextW(hdc, g_receivedText, -1, &rect, DT_WORDBREAK | DT_LEFT);

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_SEND_BACK_BUTTON) {
                HWND mainWindow = (HWND)GetWindowLongPtr(hwnd, GWLP_HWNDPARENT);
                if (mainWindow) {
                    // 获取当前时间
                    SYSTEMTIME st;
                    GetLocalTime(&st);
                    wchar_t timeStr[30];
                    swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                        st.wYear, st.wMonth, st.wDay,
                        st.wHour, st.wMinute, st.wSecond);

                    // 构造JSON消息
                    wchar_t* jsonMsg = (wchar_t*)GlobalAlloc(GPTR, 256 * sizeof(wchar_t));
                    if (jsonMsg) {
                        swprintf(jsonMsg, 256, L"{\"greeting\":\"你好，这是来自第二窗口的消息\",\"time\":\"%s\"}", timeStr);
                        
                        lstrcpyW(g_receivedText, L"已发送消息");
                        InvalidateRect(hwnd, NULL, TRUE);
                        PostMessageW(mainWindow, WM_CUSTOM_MESSAGE2, 0, (LPARAM)jsonMsg);
                    }
                }
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE1: {
            // 接收来自主窗口的消息
            wchar_t* jsonMsg = (wchar_t*)lParam;
            if (jsonMsg) {
                lstrcpyW(g_receivedText, jsonMsg);
                GlobalFree(jsonMsg);  // 释放全局内存
                InvalidateRect(hwnd, NULL, TRUE);
            }
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