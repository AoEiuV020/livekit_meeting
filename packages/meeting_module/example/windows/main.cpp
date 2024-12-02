#include <windows.h>
#include "second_window.h"
#include <stdio.h>
#include <shlwapi.h>  // 用于路径操作
#pragma comment(lib, "shlwapi.lib")

// 定义按钮的ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002
#define ID_LAUNCH_EXE 1003  // 新按钮ID

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
        20, 20, 100, 30,
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
        140, 20, 100, 30,
        hwnd,
        (HMENU)ID_SEND_MSG_BUTTON,
        hInstance,
        NULL
    );

    // 创建启动EXE按钮
    CreateWindowW(
        L"BUTTON",
        L"启动Flutter程序",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        260, 20, 100, 30,  // 放在第二个按钮右边
        hwnd,
        (HMENU)ID_LAUNCH_EXE,
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

            // 在左上角显示消息，使用 DrawText 支持自动换行
            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            
            RECT rect = { 20, 60, 760, 180 };  // 限制文本区域，但给足够宽度显示
            DrawTextW(hdc, receivedText, -1, &rect, DT_WORDBREAK | DT_LEFT);

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_BUTTON) {
                HWND secondWindow = GetSecondWindowHandle();
                if (!secondWindow) {
                    CreateSecondWindow((HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE), hwnd);
                } else {
                    SetFocus(secondWindow);
                }
            }
            else if (LOWORD(wParam) == ID_SEND_MSG_BUTTON) {
                HWND secondWindow = GetSecondWindowHandle();
                if (secondWindow) {
                    // 获取当前时间
                    SYSTEMTIME st;
                    GetLocalTime(&st);
                    wchar_t timeStr[30];
                    swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                        st.wYear, st.wMonth, st.wDay,
                        st.wHour, st.wMinute, st.wSecond);

                    // 构造JSON消息
                    wchar_t jsonMsg[256];
                    swprintf(jsonMsg, 256, L"{\"greeting\":\"你好，这是来自主窗口的消息\",\"time\":\"%s\"}", timeStr);

                    lstrcpyW(receivedText, L"已发送消息");
                    InvalidateRect(hwnd, NULL, TRUE);
                    PostMessageW(secondWindow, WM_CUSTOM_MESSAGE1, 0, (LPARAM)jsonMsg);
                }
            }
            else if (LOWORD(wParam) == ID_LAUNCH_EXE) {
                // 获取当前程序的路径
                wchar_t currentPath[MAX_PATH];
                GetModuleFileNameW(NULL, currentPath, MAX_PATH);
                PathRemoveFileSpecW(currentPath);  // 移除文件名，只保留路径

                // 构造目标EXE的相对路径
                wchar_t targetPath[MAX_PATH];
                wcscpy_s(targetPath, currentPath);
                PathAppendW(targetPath, L"..\\..\\..\\..\\..\\..\\..\\example\\build\\windows\\x64\\runner\\Debug\\meeting_flutter_example.exe");

                // 打印绝对路径到日志
                FILE* file = NULL;
                fopen_s(&file, "launch_log.txt", "a");
                if (file) {
                    fwprintf(file, L"Attempting to launch: %s\n", targetPath);
                    fclose(file);
                }

                // 启动进程
                STARTUPINFOW si = { sizeof(si) };
                PROCESS_INFORMATION pi;
                
                if (CreateProcessW(
                    targetPath,     // 应用程序路径
                    NULL,           // 命令行参数
                    NULL,           // 进程安全属性
                    NULL,           // 线程安全属性
                    FALSE,          // 不继承句柄
                    0,              // 创建标志
                    NULL,           // 使用父进程的环境
                    NULL,           // 使用父进程的工作目录
                    &si,            // 启动信息
                    &pi             // 进程信息
                )) {
                    // 关闭进程和线程句柄
                    CloseHandle(pi.hProcess);
                    CloseHandle(pi.hThread);
                    
                    lstrcpyW(receivedText, L"Flutter程序启动成功");
                } else {
                    // 获取错误信息
                    wchar_t errorMsg[256];
                    swprintf(errorMsg, 256, L"启动失败，错误码: %d", GetLastError());
                    lstrcpyW(receivedText, errorMsg);
                }
                InvalidateRect(hwnd, NULL, TRUE);
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE2: {
            // 接收来自第二个窗口的消息
            const wchar_t* jsonMsg = (const wchar_t*)lParam;
            lstrcpyW(receivedText, jsonMsg);  // 直接显示接收到的JSON消息
            
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