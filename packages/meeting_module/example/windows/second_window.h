#pragma once
#include <windows.h>

// �Զ�����Ϣ����
#define WM_CUSTOM_MESSAGE1 (WM_USER + 1)  // �����ڷ��͵��ڶ����ڵ���Ϣ
#define WM_CUSTOM_MESSAGE2 (WM_USER + 2)  // �ڶ����ڷ��͵������ڵ���Ϣ

// �����ڶ������ڵĺ�������
void CreateSecondWindow(HINSTANCE hInstance);

// ��ȡ�ڶ������ھ��
HWND GetSecondWindowHandle(); 