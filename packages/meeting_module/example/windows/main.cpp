#include <windows.h>
#include "second_window.h"
#include <stdio.h>
#include <shlwapi.h>  // ����·������
#pragma comment(lib, "shlwapi.lib")

// ���尴ť��ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002
#define ID_LAUNCH_EXE 1003  // �°�ťID

// ���ڹ��̺�������
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

    // ����������
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

    // ������ť
    CreateWindowW(
        L"BUTTON",
        L"���´���",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        20, 20, 100, 30,
        hwnd,
        (HMENU)ID_BUTTON,
        hInstance,
        NULL
    );

    // ����������Ϣ��ť
    CreateWindowW(
        L"BUTTON",
        L"������Ϣ",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        140, 20, 100, 30,
        hwnd,
        (HMENU)ID_SEND_MSG_BUTTON,
        hInstance,
        NULL
    );

    // ��������EXE��ť
    CreateWindowW(
        L"BUTTON",
        L"����Flutter����",
        WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
        260, 20, 100, 30,  // ���ڵڶ�����ť�ұ�
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

// �����ڵĹ��̺���
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    static WCHAR receivedText[256] = L"�ȴ���Ϣ...";  // �洢���յ�����Ϣ

    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // �����Ͻ���ʾ��Ϣ��ʹ�� DrawText ֧���Զ�����
            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            
            RECT rect = { 20, 60, 760, 180 };  // �����ı����򣬵����㹻�����ʾ
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
                    PostMessageW(secondWindow, WM_CUSTOM_MESSAGE1, 0, (LPARAM)jsonMsg);
                }
            }
            else if (LOWORD(wParam) == ID_LAUNCH_EXE) {
                // ��ȡ��ǰ�����·��
                wchar_t currentPath[MAX_PATH];
                GetModuleFileNameW(NULL, currentPath, MAX_PATH);
                PathRemoveFileSpecW(currentPath);  // �Ƴ��ļ�����ֻ����·��

                // ����Ŀ��EXE�����·��
                wchar_t targetPath[MAX_PATH];
                wcscpy_s(targetPath, currentPath);
                PathAppendW(targetPath, L"..\\..\\..\\..\\..\\..\\..\\example\\build\\windows\\x64\\runner\\Debug\\meeting_flutter_example.exe");

                // ��ӡ����·������־
                FILE* file = NULL;
                fopen_s(&file, "launch_log.txt", "a");
                if (file) {
                    fwprintf(file, L"Attempting to launch: %s\n", targetPath);
                    fclose(file);
                }

                // ��������
                STARTUPINFOW si = { sizeof(si) };
                PROCESS_INFORMATION pi;
                
                if (CreateProcessW(
                    targetPath,     // Ӧ�ó���·��
                    NULL,           // �����в���
                    NULL,           // ���̰�ȫ����
                    NULL,           // �̰߳�ȫ����
                    FALSE,          // ���̳о��
                    0,              // ������־
                    NULL,           // ʹ�ø����̵Ļ���
                    NULL,           // ʹ�ø����̵Ĺ���Ŀ¼
                    &si,            // ������Ϣ
                    &pi             // ������Ϣ
                )) {
                    // �رս��̺��߳̾��
                    CloseHandle(pi.hProcess);
                    CloseHandle(pi.hThread);
                    
                    lstrcpyW(receivedText, L"Flutter���������ɹ�");
                } else {
                    // ��ȡ������Ϣ
                    wchar_t errorMsg[256];
                    swprintf(errorMsg, 256, L"����ʧ�ܣ�������: %d", GetLastError());
                    lstrcpyW(receivedText, errorMsg);
                }
                InvalidateRect(hwnd, NULL, TRUE);
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE2: {
            // �������Եڶ������ڵ���Ϣ
            const wchar_t* jsonMsg = (const wchar_t*)lParam;
            lstrcpyW(receivedText, jsonMsg);  // ֱ����ʾ���յ���JSON��Ϣ
            
            // ǿ���ػ洰���Ը����ı�
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