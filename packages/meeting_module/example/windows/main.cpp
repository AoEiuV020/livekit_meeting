#include <windows.h>
#include "second_window.h"

// 定义按钮的ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002

// 窗口过程函数声明
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow
) {
    const wchar_t CLASS_NAME[] = L"Simple Window Class";
    
    WNDCLASSW wc = {};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hbrBackground = (HBRUSH)COLOR_WINDOW;

    RegisterClassW(&wc);

    // 创建主窗口
    HWND hwnd = CreateWindowExW(
        0,
        CLASS_NAME,
        L"Main Window",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
        NULL,
        NULL,
        hInstance,
        NULL
    );

    if (hwnd == NULL) {
        return 0;
    }

    // 创建按钮
    CreateWindowW(
        L"BUTTON",
        L"打开新窗口",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        300, 280, 100, 30,
        hwnd,
        (HMENU)ID_BUTTON,
        hInstance,
        NULL
    );

    // 创建发送消息按钮
    CreateWindowW(
        L"BUTTON",
        L"发送消息",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        420, 280, 100, 30,
        hwnd,
        (HMENU)ID_SEND_MSG_BUTTON,
        hInstance,
        NULL
    );

    ShowWindow(hwnd, nCmdShow);

    MSG msg = {};
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

// 主窗口的过程函数
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    static WCHAR receivedText[256] = L"等待消息...";  // 存储接收到的消息

    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // 在按钮上方显示接收到的消息
            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            TextOutW(hdc, 300, 240, receivedText, lstrlenW(receivedText));

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_BUTTON) {
                HWND secondWindow = GetSecondWindowHandle();
                if (!secondWindow) {
                    CreateSecondWindow((HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE));
                } else {
                    SetFocus(secondWindow);
                }
            }
            else if (LOWORD(wParam) == ID_SEND_MSG_BUTTON) {
                HWND secondWindow = GetSecondWindowHandle();
                if (secondWindow) {
                    // 发送消息到第二个窗口
                    PostMessageW(secondWindow, WM_CUSTOM_MESSAGE1, 0, 0);
                }
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE2: {
            // 接收来自第二个窗口的消息
            lstrcpyW(receivedText, L"收到来自第二窗口的消息！");
            // 强制重绘窗口以更新文本
            InvalidateRect(hwnd, NULL, TRUE);
            return 0;
        }

        case WM_DESTROY: {
            PostQuitMessage(0);
            return 0;
        }

        return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
} 