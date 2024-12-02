#include <windows.h>

// 窗口过程函数的前向声明
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam);

int WINAPI WinMain(
    HINSTANCE hInstance,      // 当前应用程序实例句柄
    HINSTANCE hPrevInstance,  // 始终为NULL，保留参数
    LPSTR lpCmdLine,         // 命令行参数
    int nCmdShow             // 窗口显示方式
) {
    // 注册窗口类
    const wchar_t CLASS_NAME[] = L"Simple Window Class";
    
    WNDCLASSW wc = {};
    wc.lpfnWndProc = WindowProc;        // 设置窗口过程函数
    wc.hInstance = hInstance;            // 应用程序实例句柄
    wc.lpszClassName = CLASS_NAME;       // 窗口类名
    wc.hbrBackground = (HBRUSH)COLOR_WINDOW; // 窗口背景色

    RegisterClassW(&wc);

    // 创建窗口
    HWND hwnd = CreateWindowExW(
        0,                    // 扩展窗口样式
        CLASS_NAME,           // 窗口类名
        L"Hello Window",      // 窗口标题
        WS_OVERLAPPEDWINDOW, // 窗口样式
        
        // 位置和大小
        CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,

        NULL,       // 父窗口句柄
        NULL,       // 菜单句柄
        hInstance,  // 应用程序实例句柄
        NULL        // 额外参数
    );

    if (hwnd == NULL) {
        return 0;
    }

    // 显示窗口
    ShowWindow(hwnd, nCmdShow);

    // 消息循环
    MSG msg = {};
    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}

// 窗口过程函数 - 处理窗口消息
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
    switch (uMsg) {
        case WM_PAINT: {
            PAINTSTRUCT ps;
            HDC hdc = BeginPaint(hwnd, &ps);

            // 设置文本颜色和背景模式
            SetTextColor(hdc, RGB(0, 0, 0));
            SetBkMode(hdc, TRANSPARENT);

            // 使用 TextOutW 来支持宽字符
            TextOutW(hdc, 350, 280, L"Hello", 5);

            EndPaint(hwnd, &ps);
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