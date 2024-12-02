#include <windows.h>
#include "second_window.h"
#include <stdio.h>
// ���尴ť��ID
#define ID_BUTTON 1001
#define ID_SEND_MSG_BUTTON 1002

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