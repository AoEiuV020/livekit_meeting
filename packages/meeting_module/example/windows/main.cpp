#include <windows.h>
#include "second_window.h"

// ���尴ť��ID
#define ID_BUTTON 1001

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
        350, 280, 100, 30,
        hwnd,
        (HMENU)ID_BUTTON,
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
    switch (uMsg) {
        case WM_COMMAND: {
            // ����ť���
            if (LOWORD(wParam) == ID_BUTTON) {
                HWND secondWindow = GetSecondWindowHandle();
                if (!secondWindow) {  // ����ڶ������ڲ�����
                    CreateSecondWindow((HINSTANCE)GetWindowLongPtr(hwnd, GWLP_HINSTANCE));
                } else {
                    SetFocus(secondWindow);  // ����Ѵ��ڣ����������õ��ڶ�������
                }
            }
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