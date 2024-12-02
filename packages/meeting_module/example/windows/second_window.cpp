#include "second_window.h"

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

// �ڶ������ڵĹ��̺���
LRESULT CALLBACK SecondWindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);
            
            // ��ʾ���յ�����Ϣ
            TextOutW(hdc, 150, 120, g_receivedText, lstrlenW(g_receivedText));

            EndPaint(hwnd, &ps);
            return 0;
        }

        case WM_COMMAND: {
            if (LOWORD(wParam) == ID_SEND_BACK_BUTTON) {
                // ʹ�� GWLP_HWNDPARENT ��ȡ�����ߴ��ھ��
                HWND mainWindow = (HWND)GetWindowLongPtr(hwnd, GWLP_HWNDPARENT);
                if (mainWindow) {
                    PostMessageW(mainWindow, WM_CUSTOM_MESSAGE2, 0, 0);
                }
            }
            return 0;
        }

        case WM_CUSTOM_MESSAGE1: {
            // �������������ڵ���Ϣ
            lstrcpyW(g_receivedText, L"�յ����������ڵ���Ϣ��");
            // ǿ���ػ洰���Ը����ı�
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