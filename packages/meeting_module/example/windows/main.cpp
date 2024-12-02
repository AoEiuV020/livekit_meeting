#include <windows.h>
#include "second_window.h"
#include <stdio.h>
#include <shlwapi.h> // 用于路径操作
#include <direct.h>  // 用于获取当前工作目录
#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <time.h>
#pragma comment(lib, "shlwapi.lib")

// 定义按钮的ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002
#define ID_LAUNCH_EXE 1003
#define ID_LAUNCH_SELF 1004

// 窗口过程函数声明
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

// 修改管道相关定义
#define PIPE_PARENT_TO_CHILD L"\\\\.\\pipe\\ParentToChild"
#define PIPE_CHILD_TO_PARENT L"\\\\.\\pipe\\ChildToParent"

static HANDLE g_hReadPipe = NULL;  // 用于读取的管道
static HANDLE g_hWritePipe = NULL; // 用于写入的管道
static bool g_isChild = false;
static HANDLE g_hReadThread = NULL;

// 修改日志函数
void WriteLog(const char *format, ...)
{
    // 缓冲区用于存储格式化后的日志信息
    char logBuffer[1024];

    // 获取可变参数列表
    va_list args;
    va_start(args, format);

    // 格式化日志信息
    vsprintf_s(logBuffer, sizeof(logBuffer), format, args);

    va_end(args);

    // 获取当前时间，用于日志时间戳
    time_t now;
    struct tm timeinfo;
    char timeBuffer[20];
    time(&now);
    localtime_s(&timeinfo, &now);
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    // 打开日志文件
    HANDLE hFile = CreateFileA(
        "app.log",             // 日志文件路径
        GENERIC_WRITE,         // 写入权限
        FILE_SHARE_READ,       // 允许其他程序读取文件
        NULL,                  // 默认安全属性
        OPEN_ALWAYS,           // 如果文件不存在，则创建文件
        FILE_ATTRIBUTE_NORMAL, // 文件属性
        NULL);                 // 不需要模板文件

    if (hFile == INVALID_HANDLE_VALUE)
    {
        printf("Failed to open log file\n");
        return;
    }

    // 将文件指针移到末尾
    SetFilePointer(hFile, 0, NULL, FILE_END);

    // 将时间戳和日志信息写入日志文件
    char logEntry[2048];
    sprintf_s(logEntry, sizeof(logEntry), "[%s][PID:%d] %s\n",
              timeBuffer, GetCurrentProcessId(), logBuffer);

    // 写入日志
    DWORD written;
    WriteFile(hFile, logEntry, strlen(logEntry), &written, NULL);

    // 关闭文件
    CloseHandle(hFile);

    // 同时打印到控制台
    printf("%s", logEntry);
}
// 读取线程函数
DWORD WINAPI PipeReadThread(LPVOID param)
{
    WriteLog("读取线程启动，管道句柄: %p", g_hReadPipe);
    HWND hwnd = (HWND)param;

    // 如果是父进程，需要等待客户端连接
    if (!g_isChild)
    {
        WriteLog("父进程等待客户端连接到管道...");
        if (!ConnectNamedPipe(g_hReadPipe, NULL))
        {
            DWORD error = GetLastError();
            if (error != ERROR_PIPE_CONNECTED)
            {
                WriteLog("ConnectNamedPipe 失败，错误码：%d", error);
                return 1;
            }
        }
        WriteLog("客户端已连接到读取管道");
    }

    wchar_t buffer[512];
    DWORD bytesRead;

    while (true)
    {
        WriteLog("等待读取管道数据...");
        if (ReadFile(g_hReadPipe, buffer, sizeof(buffer), &bytesRead, NULL))
        {
            if (bytesRead > 0)
            {
                WriteLog("成功读取管道数据，长度：%d", bytesRead);

                // 为日志转换成char
                char logMsg[512];
                WideCharToMultiByte(CP_UTF8, 0, buffer, -1, logMsg, sizeof(logMsg), NULL, NULL);
                WriteLog("接收到的数据: %s", logMsg);

                // 发送宽字符消息
                wchar_t *msgCopy = _wcsdup(buffer); // 使用宽字符版本的strdup
                PostMessageW(hwnd, WM_APP + 1, 0, (LPARAM)msgCopy);
            }
            else
            {
                WriteLog("读取到0字节数据");
            }
        }
        else
        {
            DWORD error = GetLastError();
            WriteLog("读取管道失败，错误码：%d", error);
            // 获取错误信息
            char errorMsg[256];
            FormatMessageA(
                FORMAT_MESSAGE_FROM_SYSTEM,
                NULL,
                error,
                0,
                errorMsg,
                sizeof(errorMsg),
                NULL);
            WriteLog("错误信息: %s", errorMsg);

            if (error == ERROR_BROKEN_PIPE)
            {
                WriteLog("管道已断开，退出读取线程");
                break;
            }
        }
    }
    WriteLog("读取线程结束");
    return 0;
}

int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow)
{
    WriteLog("程序启动");

    // 尝试连接父进程的管道，如果能连接说明是子进程
    WriteLog("尝试连接管道");
    g_hReadPipe = CreateFileW(
        PIPE_PARENT_TO_CHILD, // 子进程从这里读取
        GENERIC_READ,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);

    if (g_hReadPipe != INVALID_HANDLE_VALUE)
    {
        // 是子进程
        g_isChild = true;
        WriteLog("成功连接到读取管道，这是子进程");

        // 连接写入管道
        g_hWritePipe = CreateFileW(
            PIPE_CHILD_TO_PARENT, // 子进程往这里写
            GENERIC_WRITE,
            0,
            NULL,
            OPEN_EXISTING,
            0,
            NULL);

        if (g_hWritePipe == INVALID_HANDLE_VALUE)
        {
            WriteLog("子进程连接写入管道失败，错误码：%d", GetLastError());
        }
        else
        {
            WriteLog("子进程成功连接写入管道");
        }
    }
    else
    {
        // 是父进程，创建两个管道
        WriteLog("这是父进程，开始创建管道");

        // 创建父->子管道
        g_hWritePipe = CreateNamedPipeW(
            PIPE_PARENT_TO_CHILD,
            PIPE_ACCESS_OUTBOUND,
            PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
            1,
            512,
            512,
            0,
            NULL);

        if (g_hWritePipe == INVALID_HANDLE_VALUE)
        {
            WriteLog("父进程创建写入管道失败，错误码：%d", GetLastError());
        }
        else
        {
            WriteLog("父进程创建写入管道成功");
        }

        // 创建子->父管道
        g_hReadPipe = CreateNamedPipeW(
            PIPE_CHILD_TO_PARENT,
            PIPE_ACCESS_INBOUND,
            PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
            1,
            512,
            512,
            0,
            NULL);

        if (g_hReadPipe == INVALID_HANDLE_VALUE)
        {
            WriteLog("父进程创建读取管道失败，错误码：%d", GetLastError());
        }
        else
        {
            WriteLog("父进程创建读取管道成功");
        }
    }

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
        g_isChild ? L"Child Window" : L"Main Window",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
        NULL,
        NULL,
        hInstance,
        NULL);

    if (hwnd == NULL)
    {
        return 0;
    }

    // 创建读取线程
    if (g_isChild && g_hReadPipe != INVALID_HANDLE_VALUE)
    {
        WriteLog("准备创建读取线程");
        g_hReadThread = CreateThread(NULL, 0, PipeReadThread, hwnd, 0, NULL);
        if (g_hReadThread)
        {
            WriteLog("读取线程创建成功，句柄: %p", g_hReadThread);
        }
        else
        {
            WriteLog("读取线程创建失败，错误码: %d", GetLastError());
        }
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
        NULL);

    // 创建发送消息按钮
    CreateWindowW(
        L"BUTTON",
        L"发送消息",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        140, 20, 100, 30,
        hwnd,
        (HMENU)ID_SEND_MSG_BUTTON,
        hInstance,
        NULL);

    // 创建启动EXE按钮
    CreateWindowW(
        L"BUTTON",
        L"启动Flutter程序",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        260, 20, 100, 30, // 放在第二个按钮右边
        hwnd,
        (HMENU)ID_LAUNCH_EXE,
        hInstance,
        NULL);

    // 创建启动自身副本的按钮
    CreateWindowW(
        L"BUTTON",
        L"启动副本",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        380, 20, 100, 30, // 放在第三个按钮右边
        hwnd,
        (HMENU)ID_LAUNCH_SELF,
        hInstance,
        NULL);

    ShowWindow(hwnd, nCmdShow);

    MSG msg = {};
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

// 主窗口的过程函数
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    static WCHAR receivedText[256] = L"等待消息..."; // 存储接收到的消息

    switch (uMsg)
    {
    case WM_PAINT:
    {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hwnd, &ps);

        // 在左上角显示消息，使用 DrawText 支持自动换行
        SetTextColor(hdc, RGB(0, 0, 0));
        SetBkMode(hdc, TRANSPARENT);

        RECT rect = {20, 60, 760, 180}; // 限制文本区域，但给足够宽度显示
        DrawTextW(hdc, receivedText, -1, &rect, DT_WORDBREAK | DT_LEFT);

        EndPaint(hwnd, &ps);
        return 0;
    }

    case WM_COMMAND:
    {
        if (LOWORD(wParam) == ID_BUTTON)
        {
            HWND secondWindow = GetSecondWindowHandle();
            if (!secondWindow)
            {
                CreateSecondWindow((HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE), hwnd);
            }
            else
            {
                SetFocus(secondWindow);
            }
        }
        else if (LOWORD(wParam) == ID_SEND_MSG_BUTTON)
        {
            HWND secondWindow = GetSecondWindowHandle();
            if (secondWindow)
            {
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
                SendMessageW(secondWindow, WM_CUSTOM_MESSAGE1, 0, (LPARAM)jsonMsg);
            }
            else if (g_hWritePipe != NULL && g_hWritePipe != INVALID_HANDLE_VALUE)
            {
                WriteLog("准备发送消息，写入管道句柄: %p", g_hWritePipe);

                // 获取当前时间
                SYSTEMTIME st;
                GetLocalTime(&st);
                wchar_t timeStr[30];
                swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                         st.wYear, st.wMonth, st.wDay,
                         st.wHour, st.wMinute, st.wSecond);

                // 构造消息
                wchar_t message[256];
                swprintf(message, 256, L"{\"greeting\":\"你好，这是来自%s的消息\",\"time\":\"%s\"}",
                         g_isChild ? L"子进程" : L"父进程",
                         timeStr);

                // 为日志转换成char
                char logMsg[512];
                WideCharToMultiByte(CP_UTF8, 0, message, -1, logMsg, sizeof(logMsg), NULL, NULL);
                WriteLog("准备发送的消息: %s", logMsg);

                // 写入管道（写入宽字符）
                DWORD bytesWritten;
                if (WriteFile(g_hWritePipe, message, (wcslen(message) + 1) * sizeof(wchar_t), &bytesWritten, NULL))
                {
                    WriteLog("消息发送成功，写入字节数: %d", bytesWritten);
                    lstrcpyW(receivedText, L"已发送消息");
                }
                else
                {
                    DWORD error = GetLastError();
                    WriteLog("消息发送失败，错误码: %d", error);
                    // 获取错误信息
                    char errorMsg[256];
                    FormatMessageA(
                        FORMAT_MESSAGE_FROM_SYSTEM,
                        NULL,
                        error,
                        0,
                        errorMsg,
                        sizeof(errorMsg),
                        NULL);
                    WriteLog("错误信息: %s", errorMsg);
                }
                InvalidateRect(hwnd, NULL, TRUE);
            }
        }
        else if (LOWORD(wParam) == ID_LAUNCH_EXE)
        {
            // 获取当前程序的路径
            wchar_t currentPath[MAX_PATH];
            GetModuleFileNameW(NULL, currentPath, MAX_PATH);
            PathRemoveFileSpecW(currentPath); // 移除文件名，只保留路径

            // 构造目标EXE的相对路径
            wchar_t targetPath[MAX_PATH];
            wcscpy_s(targetPath, currentPath);
            PathAppendW(targetPath, L"..\\..\\..\\..\\..\\..\\..\\example\\build\\windows\\x64\\runner\\Debug\\meeting_flutter_example.exe");

            // 打印绝对路径到日志
            FILE *file = NULL;
            fopen_s(&file, "launch_log.txt", "a");
            if (file)
            {
                fwprintf(file, L"Attempting to launch: %s\n", targetPath);
                fclose(file);
            }

            // 启动进程
            STARTUPINFOW si = {sizeof(si)};
            PROCESS_INFORMATION pi;

            if (CreateProcessW(
                    targetPath, // 应用程序路径
                    NULL,       // 命令行参数
                    NULL,       // 进程安全属性
                    NULL,       // 线程安全属性
                    FALSE,      // 不继承句柄
                    0,          // 创建标志
                    NULL,       // 使用父进程的环境
                    NULL,       // 使用父进程的工作目录
                    &si,        // 启动信息
                    &pi         // 进程信息
                    ))
            {
                // 关闭进程和线程句柄
                CloseHandle(pi.hProcess);
                CloseHandle(pi.hThread);

                lstrcpyW(receivedText, L"Flutter程序启动成功");
            }
            else
            {
                // 获取错误信息
                wchar_t errorMsg[256];
                swprintf(errorMsg, 256, L"启动失败，错误码: %d", GetLastError());
                lstrcpyW(receivedText, errorMsg);
            }
            InvalidateRect(hwnd, NULL, TRUE);
        }
        else if (LOWORD(wParam) == ID_LAUNCH_SELF)
        {
            WriteLog("开始启动子进程");
            wchar_t exePath[MAX_PATH];
            GetModuleFileNameW(NULL, exePath, MAX_PATH);
            WriteLog("当前程序路径: %s", exePath);

            STARTUPINFOW si = {sizeof(si)};
            PROCESS_INFORMATION pi;

            if (CreateProcessW(
                    exePath,
                    NULL,
                    NULL,
                    NULL,
                    FALSE,
                    0, // 移除了 CREATE_UNICODE_ENVIRONMENT
                    NULL,
                    NULL,
                    &si,
                    &pi))
            {
                WriteLog("子进程创建成功，PID: %d", pi.dwProcessId);
                CloseHandle(pi.hProcess);
                CloseHandle(pi.hThread);
                lstrcpyW(receivedText, L"副本程序启动成功");

                // 创建读取线程
                if (g_hReadPipe != INVALID_HANDLE_VALUE)
                {
                    WriteLog("准备创建读取线程");
                    g_hReadThread = CreateThread(NULL, 0, PipeReadThread, hwnd, 0, NULL);
                    if (g_hReadThread)
                    {
                        WriteLog("读取线程创建成功，句柄: %p", g_hReadThread);
                    }
                    else
                    {
                        WriteLog("读取线程创建失败，错误码: %d", GetLastError());
                    }
                }
            }
            else
            {
                WriteLog("子进程创建失败，错误码：%d", GetLastError());
            }
            InvalidateRect(hwnd, NULL, TRUE);
        }
        return 0;
    }

    case WM_CUSTOM_MESSAGE2:
    {
        // 接收来自第二个窗口的消息
        const wchar_t *jsonMsg = (const wchar_t *)lParam;
        lstrcpyW(receivedText, jsonMsg);

        // 强制重绘窗口以更新文本
        InvalidateRect(hwnd, NULL, TRUE);
        return 0;
    }

    case WM_APP + 1:
    { // 自定义消息，用于接收管道数据
        wchar_t *message = (wchar_t *)lParam;
        if (message)
        {
            lstrcpyW(receivedText, message);
            InvalidateRect(hwnd, NULL, TRUE);
            free(message); // 释放在读取线程中分配的内存
        }
        return 0;
    }

    case WM_DESTROY:
    {
        // 清理管道和线程资源
        if (g_hReadThread)
        {
            TerminateThread(g_hReadThread, 0);
            CloseHandle(g_hReadThread);
        }
        if (g_hReadPipe)
            CloseHandle(g_hReadPipe);
        if (g_hWritePipe)
            CloseHandle(g_hWritePipe);
        PostQuitMessage(0);
        return 0;
    }

        return 0;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}