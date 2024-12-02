#include <windows.h>
#include "second_window.h"
#include <stdio.h>
#include <shlwapi.h> // ����·������
#include <direct.h>  // ���ڻ�ȡ��ǰ����Ŀ¼
#include <stdio.h>
#include <stdarg.h>
#include <wchar.h>
#include <time.h>
#pragma comment(lib, "shlwapi.lib")

// ���尴ť��ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002
#define ID_LAUNCH_EXE 1003
#define ID_LAUNCH_SELF 1004

// ���ڹ��̺�������
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

// �޸Ĺܵ���ض���
#define PIPE_PARENT_TO_CHILD L"\\\\.\\pipe\\ParentToChild"
#define PIPE_CHILD_TO_PARENT L"\\\\.\\pipe\\ChildToParent"

static HANDLE g_hReadPipe = NULL;  // ���ڶ�ȡ�Ĺܵ�
static HANDLE g_hWritePipe = NULL; // ����д��Ĺܵ�
static bool g_isChild = false;
static HANDLE g_hReadThread = NULL;

// �޸���־����
void WriteLog(const char *format, ...)
{
    // ���������ڴ洢��ʽ�������־��Ϣ
    char logBuffer[1024];

    // ��ȡ�ɱ�����б�
    va_list args;
    va_start(args, format);

    // ��ʽ����־��Ϣ
    vsprintf_s(logBuffer, sizeof(logBuffer), format, args);

    va_end(args);

    // ��ȡ��ǰʱ�䣬������־ʱ���
    time_t now;
    struct tm timeinfo;
    char timeBuffer[20];
    time(&now);
    localtime_s(&timeinfo, &now);
    strftime(timeBuffer, sizeof(timeBuffer), "%Y-%m-%d %H:%M:%S", &timeinfo);

    // ����־�ļ�
    HANDLE hFile = CreateFileA(
        "app.log",             // ��־�ļ�·��
        GENERIC_WRITE,         // д��Ȩ��
        FILE_SHARE_READ,       // �������������ȡ�ļ�
        NULL,                  // Ĭ�ϰ�ȫ����
        OPEN_ALWAYS,           // ����ļ������ڣ��򴴽��ļ�
        FILE_ATTRIBUTE_NORMAL, // �ļ�����
        NULL);                 // ����Ҫģ���ļ�

    if (hFile == INVALID_HANDLE_VALUE)
    {
        printf("Failed to open log file\n");
        return;
    }

    // ���ļ�ָ���Ƶ�ĩβ
    SetFilePointer(hFile, 0, NULL, FILE_END);

    // ��ʱ�������־��Ϣд����־�ļ�
    char logEntry[2048];
    sprintf_s(logEntry, sizeof(logEntry), "[%s][PID:%d] %s\n",
              timeBuffer, GetCurrentProcessId(), logBuffer);

    // д����־
    DWORD written;
    WriteFile(hFile, logEntry, strlen(logEntry), &written, NULL);

    // �ر��ļ�
    CloseHandle(hFile);

    // ͬʱ��ӡ������̨
    printf("%s", logEntry);
}
// ��ȡ�̺߳���
DWORD WINAPI PipeReadThread(LPVOID param)
{
    WriteLog("��ȡ�߳��������ܵ����: %p", g_hReadPipe);
    HWND hwnd = (HWND)param;

    // ����Ǹ����̣���Ҫ�ȴ��ͻ�������
    if (!g_isChild)
    {
        WriteLog("�����̵ȴ��ͻ������ӵ��ܵ�...");
        if (!ConnectNamedPipe(g_hReadPipe, NULL))
        {
            DWORD error = GetLastError();
            if (error != ERROR_PIPE_CONNECTED)
            {
                WriteLog("ConnectNamedPipe ʧ�ܣ������룺%d", error);
                return 1;
            }
        }
        WriteLog("�ͻ��������ӵ���ȡ�ܵ�");
    }

    wchar_t buffer[512];
    DWORD bytesRead;

    while (true)
    {
        WriteLog("�ȴ���ȡ�ܵ�����...");
        if (ReadFile(g_hReadPipe, buffer, sizeof(buffer), &bytesRead, NULL))
        {
            if (bytesRead > 0)
            {
                WriteLog("�ɹ���ȡ�ܵ����ݣ����ȣ�%d", bytesRead);

                // Ϊ��־ת����char
                char logMsg[512];
                WideCharToMultiByte(CP_UTF8, 0, buffer, -1, logMsg, sizeof(logMsg), NULL, NULL);
                WriteLog("���յ�������: %s", logMsg);

                // ���Ϳ��ַ���Ϣ
                wchar_t *msgCopy = _wcsdup(buffer); // ʹ�ÿ��ַ��汾��strdup
                PostMessageW(hwnd, WM_APP + 1, 0, (LPARAM)msgCopy);
            }
            else
            {
                WriteLog("��ȡ��0�ֽ�����");
            }
        }
        else
        {
            DWORD error = GetLastError();
            WriteLog("��ȡ�ܵ�ʧ�ܣ������룺%d", error);
            // ��ȡ������Ϣ
            char errorMsg[256];
            FormatMessageA(
                FORMAT_MESSAGE_FROM_SYSTEM,
                NULL,
                error,
                0,
                errorMsg,
                sizeof(errorMsg),
                NULL);
            WriteLog("������Ϣ: %s", errorMsg);

            if (error == ERROR_BROKEN_PIPE)
            {
                WriteLog("�ܵ��ѶϿ����˳���ȡ�߳�");
                break;
            }
        }
    }
    WriteLog("��ȡ�߳̽���");
    return 0;
}

int WINAPI WinMain(
    HINSTANCE hInstance,
    HINSTANCE hPrevInstance,
    LPSTR lpCmdLine,
    int nCmdShow)
{
    WriteLog("��������");

    // �������Ӹ����̵Ĺܵ������������˵�����ӽ���
    WriteLog("�������ӹܵ�");
    g_hReadPipe = CreateFileW(
        PIPE_PARENT_TO_CHILD, // �ӽ��̴������ȡ
        GENERIC_READ,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);

    if (g_hReadPipe != INVALID_HANDLE_VALUE)
    {
        // ���ӽ���
        g_isChild = true;
        WriteLog("�ɹ����ӵ���ȡ�ܵ��������ӽ���");

        // ����д��ܵ�
        g_hWritePipe = CreateFileW(
            PIPE_CHILD_TO_PARENT, // �ӽ���������д
            GENERIC_WRITE,
            0,
            NULL,
            OPEN_EXISTING,
            0,
            NULL);

        if (g_hWritePipe == INVALID_HANDLE_VALUE)
        {
            WriteLog("�ӽ�������д��ܵ�ʧ�ܣ������룺%d", GetLastError());
        }
        else
        {
            WriteLog("�ӽ��̳ɹ�����д��ܵ�");
        }
    }
    else
    {
        // �Ǹ����̣����������ܵ�
        WriteLog("���Ǹ����̣���ʼ�����ܵ�");

        // ������->�ӹܵ�
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
            WriteLog("�����̴���д��ܵ�ʧ�ܣ������룺%d", GetLastError());
        }
        else
        {
            WriteLog("�����̴���д��ܵ��ɹ�");
        }

        // ������->���ܵ�
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
            WriteLog("�����̴�����ȡ�ܵ�ʧ�ܣ������룺%d", GetLastError());
        }
        else
        {
            WriteLog("�����̴�����ȡ�ܵ��ɹ�");
        }
    }

    const wchar_t CLASS_NAME[] = L"Simple Window Class";

    WNDCLASSW wc = {};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = CLASS_NAME;
    wc.hbrBackground = (HBRUSH)COLOR_WINDOW;

    RegisterClassW(&wc);

    // ����������
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

    // ������ȡ�߳�
    if (g_isChild && g_hReadPipe != INVALID_HANDLE_VALUE)
    {
        WriteLog("׼��������ȡ�߳�");
        g_hReadThread = CreateThread(NULL, 0, PipeReadThread, hwnd, 0, NULL);
        if (g_hReadThread)
        {
            WriteLog("��ȡ�̴߳����ɹ������: %p", g_hReadThread);
        }
        else
        {
            WriteLog("��ȡ�̴߳���ʧ�ܣ�������: %d", GetLastError());
        }
    }

    // ������ť
    CreateWindowW(
        L"BUTTON",
        L"���´���",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        20, 20, 100, 30,
        hwnd,
        (HMENU)ID_BUTTON,
        hInstance,
        NULL);

    // ����������Ϣ��ť
    CreateWindowW(
        L"BUTTON",
        L"������Ϣ",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        140, 20, 100, 30,
        hwnd,
        (HMENU)ID_SEND_MSG_BUTTON,
        hInstance,
        NULL);

    // ��������EXE��ť
    CreateWindowW(
        L"BUTTON",
        L"����Flutter����",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        260, 20, 100, 30, // ���ڵڶ�����ť�ұ�
        hwnd,
        (HMENU)ID_LAUNCH_EXE,
        hInstance,
        NULL);

    // ���������������İ�ť
    CreateWindowW(
        L"BUTTON",
        L"��������",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        380, 20, 100, 30, // ���ڵ�������ť�ұ�
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

// �����ڵĹ��̺���
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    static WCHAR receivedText[256] = L"�ȴ���Ϣ..."; // �洢���յ�����Ϣ

    switch (uMsg)
    {
    case WM_PAINT:
    {
        PAINTSTRUCT ps;
        HDC hdc = BeginPaint(hwnd, &ps);

        // �����Ͻ���ʾ��Ϣ��ʹ�� DrawText ֧���Զ�����
        SetTextColor(hdc, RGB(0, 0, 0));
        SetBkMode(hdc, TRANSPARENT);

        RECT rect = {20, 60, 760, 180}; // �����ı����򣬵����㹻�����ʾ
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
                // ��ȡ��ǰʱ��
                SYSTEMTIME st;
                GetLocalTime(&st);
                wchar_t timeStr[30];
                swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                         st.wYear, st.wMonth, st.wDay,
                         st.wHour, st.wMinute, st.wSecond);

                // ����JSON��Ϣ
                wchar_t jsonMsg[256];
                swprintf(jsonMsg, 256, L"{\"greeting\":\"��ã��������������ڵ���Ϣ\",\"time\":\"%s\"}", timeStr);

                lstrcpyW(receivedText, L"�ѷ�����Ϣ");
                InvalidateRect(hwnd, NULL, TRUE);
                SendMessageW(secondWindow, WM_CUSTOM_MESSAGE1, 0, (LPARAM)jsonMsg);
            }
            else if (g_hWritePipe != NULL && g_hWritePipe != INVALID_HANDLE_VALUE)
            {
                WriteLog("׼��������Ϣ��д��ܵ����: %p", g_hWritePipe);

                // ��ȡ��ǰʱ��
                SYSTEMTIME st;
                GetLocalTime(&st);
                wchar_t timeStr[30];
                swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                         st.wYear, st.wMonth, st.wDay,
                         st.wHour, st.wMinute, st.wSecond);

                // ������Ϣ
                wchar_t message[256];
                swprintf(message, 256, L"{\"greeting\":\"��ã���������%s����Ϣ\",\"time\":\"%s\"}",
                         g_isChild ? L"�ӽ���" : L"������",
                         timeStr);

                // Ϊ��־ת����char
                char logMsg[512];
                WideCharToMultiByte(CP_UTF8, 0, message, -1, logMsg, sizeof(logMsg), NULL, NULL);
                WriteLog("׼�����͵���Ϣ: %s", logMsg);

                // д��ܵ���д����ַ���
                DWORD bytesWritten;
                if (WriteFile(g_hWritePipe, message, (wcslen(message) + 1) * sizeof(wchar_t), &bytesWritten, NULL))
                {
                    WriteLog("��Ϣ���ͳɹ���д���ֽ���: %d", bytesWritten);
                    lstrcpyW(receivedText, L"�ѷ�����Ϣ");
                }
                else
                {
                    DWORD error = GetLastError();
                    WriteLog("��Ϣ����ʧ�ܣ�������: %d", error);
                    // ��ȡ������Ϣ
                    char errorMsg[256];
                    FormatMessageA(
                        FORMAT_MESSAGE_FROM_SYSTEM,
                        NULL,
                        error,
                        0,
                        errorMsg,
                        sizeof(errorMsg),
                        NULL);
                    WriteLog("������Ϣ: %s", errorMsg);
                }
                InvalidateRect(hwnd, NULL, TRUE);
            }
        }
        else if (LOWORD(wParam) == ID_LAUNCH_EXE)
        {
            // ��ȡ��ǰ�����·��
            wchar_t currentPath[MAX_PATH];
            GetModuleFileNameW(NULL, currentPath, MAX_PATH);
            PathRemoveFileSpecW(currentPath); // �Ƴ��ļ�����ֻ����·��

            // ����Ŀ��EXE�����·��
            wchar_t targetPath[MAX_PATH];
            wcscpy_s(targetPath, currentPath);
            PathAppendW(targetPath, L"..\\..\\..\\..\\..\\..\\..\\example\\build\\windows\\x64\\runner\\Debug\\meeting_flutter_example.exe");

            // ��ӡ����·������־
            FILE *file = NULL;
            fopen_s(&file, "launch_log.txt", "a");
            if (file)
            {
                fwprintf(file, L"Attempting to launch: %s\n", targetPath);
                fclose(file);
            }

            // ��������
            STARTUPINFOW si = {sizeof(si)};
            PROCESS_INFORMATION pi;

            if (CreateProcessW(
                    targetPath, // Ӧ�ó���·��
                    NULL,       // �����в���
                    NULL,       // ���̰�ȫ����
                    NULL,       // �̰߳�ȫ����
                    FALSE,      // ���̳о��
                    0,          // ������־
                    NULL,       // ʹ�ø����̵Ļ���
                    NULL,       // ʹ�ø����̵Ĺ���Ŀ¼
                    &si,        // ������Ϣ
                    &pi         // ������Ϣ
                    ))
            {
                // �رս��̺��߳̾��
                CloseHandle(pi.hProcess);
                CloseHandle(pi.hThread);

                lstrcpyW(receivedText, L"Flutter���������ɹ�");
            }
            else
            {
                // ��ȡ������Ϣ
                wchar_t errorMsg[256];
                swprintf(errorMsg, 256, L"����ʧ�ܣ�������: %d", GetLastError());
                lstrcpyW(receivedText, errorMsg);
            }
            InvalidateRect(hwnd, NULL, TRUE);
        }
        else if (LOWORD(wParam) == ID_LAUNCH_SELF)
        {
            WriteLog("��ʼ�����ӽ���");
            wchar_t exePath[MAX_PATH];
            GetModuleFileNameW(NULL, exePath, MAX_PATH);
            WriteLog("��ǰ����·��: %s", exePath);

            STARTUPINFOW si = {sizeof(si)};
            PROCESS_INFORMATION pi;

            if (CreateProcessW(
                    exePath,
                    NULL,
                    NULL,
                    NULL,
                    FALSE,
                    0, // �Ƴ��� CREATE_UNICODE_ENVIRONMENT
                    NULL,
                    NULL,
                    &si,
                    &pi))
            {
                WriteLog("�ӽ��̴����ɹ���PID: %d", pi.dwProcessId);
                CloseHandle(pi.hProcess);
                CloseHandle(pi.hThread);
                lstrcpyW(receivedText, L"�������������ɹ�");

                // ������ȡ�߳�
                if (g_hReadPipe != INVALID_HANDLE_VALUE)
                {
                    WriteLog("׼��������ȡ�߳�");
                    g_hReadThread = CreateThread(NULL, 0, PipeReadThread, hwnd, 0, NULL);
                    if (g_hReadThread)
                    {
                        WriteLog("��ȡ�̴߳����ɹ������: %p", g_hReadThread);
                    }
                    else
                    {
                        WriteLog("��ȡ�̴߳���ʧ�ܣ�������: %d", GetLastError());
                    }
                }
            }
            else
            {
                WriteLog("�ӽ��̴���ʧ�ܣ������룺%d", GetLastError());
            }
            InvalidateRect(hwnd, NULL, TRUE);
        }
        return 0;
    }

    case WM_CUSTOM_MESSAGE2:
    {
        // �������Եڶ������ڵ���Ϣ
        const wchar_t *jsonMsg = (const wchar_t *)lParam;
        lstrcpyW(receivedText, jsonMsg);

        // ǿ���ػ洰���Ը����ı�
        InvalidateRect(hwnd, NULL, TRUE);
        return 0;
    }

    case WM_APP + 1:
    { // �Զ�����Ϣ�����ڽ��չܵ�����
        wchar_t *message = (wchar_t *)lParam;
        if (message)
        {
            lstrcpyW(receivedText, message);
            InvalidateRect(hwnd, NULL, TRUE);
            free(message); // �ͷ��ڶ�ȡ�߳��з�����ڴ�
        }
        return 0;
    }

    case WM_DESTROY:
    {
        // ����ܵ����߳���Դ
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