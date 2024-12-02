#include "second_window.h"
#include <stdio.h>
// ���尴ťID
#define ID_SEND_BACK_BUTTON 2001

// ����ڶ������ڵľ��
static HWND g_hwndSecond = NULL;
static WCHAR g_receivedText[256] = L"�ȴ���Ϣ...";  // �洢���յ�����Ϣ

// �ڶ������ڵĹ��̺�������
LRESULT CALLBACK SecondWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

HWND GetSecondWindowHandle() {
    return g_hwndSecond;
}

void CreateSecondWindow(HINSTANCE hInstance, HWND parentWindow) {
    // ע��ڶ���������
    const wchar_t SECOND_CLASS_NAME[] = L"Second Window Class";
    
    WNDCLASSW wc = {};
    wc.lpfnWndProc = SecondWindowProc;
    wc.hInstance = hInstance;
    wc.lpszClassName = SECOND_CLASS_NAME;
    wc.hbrBackground = (HBRUSH)COLOR_WINDOW;

    RegisterClassW(&wc);

    // �����ڶ�������
    g_hwndSecond = CreateWindowExW(
        0,                    // ����������ʽ
        SECOND_CLASS_NAME,
        L"Second Window",
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 400, 300,
        NULL,                 // ����������ΪNULL
        NULL,
        hInstance,
        NULL
    );

    if (g_hwndSecond) {
        // ���ô���������
        SetWindowLongPtr(g_hwndSecond, GWLP_HWNDPARENT, (LONG_PTR)parentWindow);

        // ����������Ϣ��ť
        CreateWindowW(
            L"BUTTON",
            L"���ͻ�������",
            WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON,
            20, 20, 100, 30,  // �Ƶ����Ͻ�
            g_hwndSecond,
            (HMENU)ID_SEND_BACK_BUTTON,
            hInstance,
            NULL
        );

        ShowWindow(g_hwndSecond, SW_SHOW);
        UpdateWindow(g_hwndSecond);
    }
}

// �ڶ������ڵĹ��̺���
LRESULT CALLBACK SecondWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            
            // �����Ͻ���ʾ��Ϣ��ʹ�� DrawText ֧���Զ�����
            RECT rect = { 20, 60, 360, 180 };  // �����ı�����
            DrawTextW(hdc, g_receivedText, -1, &rect, DT_WORDBREAK | DT_LEFT);

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_SEND_BACK_BUTTON) {
                HWND mainWindow = (HWND)GetWindowLongPtr(hwnd, GWLP_HWNDPARENT);
                if (mainWindow) {
                    // ��ȡ��ǰʱ��
                    SYSTEMTIME st;
                    GetLocalTime(&st);
                    wchar_t timeStr[30];
                    swprintf(timeStr, 30, L"%04d-%02d-%02d %02d:%02d:%02d",
                        st.wYear, st.wMonth, st.wDay,
                        st.wHour, st.wMinute, st.wSecond);

                    // ����JSON��Ϣ
                    wchar_t* jsonMsg = (wchar_t*)GlobalAlloc(GPTR, 256 * sizeof(wchar_t));
                    if (jsonMsg) {
                        swprintf(jsonMsg, 256, L"{\"greeting\":\"��ã��������Եڶ����ڵ���Ϣ\",\"time\":\"%s\"}", timeStr);
                        
                        lstrcpyW(g_receivedText, L"�ѷ�����Ϣ");
                        InvalidateRect(hwnd, NULL, TRUE);
                        PostMessageW(mainWindow, WM_CUSTOM_MESSAGE2, 0, (LPARAM)jsonMsg);
                    }
                }
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE1: {
            // �������������ڵ���Ϣ
            wchar_t* jsonMsg = (wchar_t*)lParam;
            if (jsonMsg) {
                lstrcpyW(g_receivedText, jsonMsg);
                GlobalFree(jsonMsg);  // �ͷ�ȫ���ڴ�
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