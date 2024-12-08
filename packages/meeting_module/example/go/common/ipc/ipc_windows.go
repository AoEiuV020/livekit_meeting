package ipc

import (
	"errors"
	"syscall"
	"unsafe"
)

type IpcImpl struct {
	isServer bool
	pipe     syscall.Handle
}

const (
	PIPE_ACCESS_DUPLEX    = 0x3
	PIPE_TYPE_MESSAGE     = 0x4
	PIPE_READMODE_MESSAGE = 0x2
	PIPE_WAIT             = 0x0
)

func NewServer() IPC {
	return &IpcImpl{isServer: true}
}

func NewClient() IPC {
	return &IpcImpl{isServer: false}
}

func (w *IpcImpl) Initialize() error {
	if w.isServer {
		return w.initializeServer()
	}
	return nil // 客户端不需要初始化
}

func (w *IpcImpl) initializeServer() error {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	createNamedPipe := kernel32.NewProc("CreateNamedPipeW")

	pipeNamePtr, err := syscall.UTF16PtrFromString("\\\\.\\pipe\\mynamedpipe")
	if err != nil {
		return errors.New("无法转换管道名称")
	}

	h, _, err := createNamedPipe.Call(
		uintptr(unsafe.Pointer(pipeNamePtr)),
		uintptr(PIPE_ACCESS_DUPLEX),
		uintptr(PIPE_TYPE_MESSAGE|PIPE_READMODE_MESSAGE|PIPE_WAIT),
		1,    // 最大实例数
		4096, // 输出缓冲区大小
		4096, // 输入缓冲区大小
		0,    // 默认超时
		0,    // 默认安全属性
	)

	handle := syscall.Handle(h)
	if handle == syscall.InvalidHandle {
		return errors.New("创建命名管道失败: " + err.Error())
	}

	w.pipe = syscall.Handle(h)
	return nil
}
func (w *IpcImpl) Send(data []byte) error {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	writeFile := kernel32.NewProc("WriteFile")

	var h syscall.Handle

	if w.isServer {
		h = w.pipe
	} else {
		pipeNamePtr, err := syscall.UTF16PtrFromString("\\\\.\\pipe\\mynamedpipe")
		if err != nil {
			return errors.New("无法转换管道名称")
		}

		var err2 error // 使用新的变量名避免遮蔽
		h, err2 = syscall.CreateFile(pipeNamePtr, syscall.GENERIC_WRITE, 0, nil, syscall.OPEN_EXISTING, 0, 0)
		if err2 != nil {
			return errors.New("无法打开命名管道: " + err2.Error())
		}
		defer syscall.CloseHandle(h)
	}

	var bytesWritten uint32
	r1, _, errNo := writeFile.Call(uintptr(h), uintptr(unsafe.Pointer(&data[0])), uintptr(len(data)), uintptr(unsafe.Pointer(&bytesWritten)), 0)
	if r1 == 0 {
		return errors.New("写入数据失败: " + errNo.Error())
	}

	return nil
}

func (w *IpcImpl) Receive() ([]byte, error) {
	kernel32 := syscall.NewLazyDLL("kernel32.dll")
	readFile := kernel32.NewProc("ReadFile")
	connectNamedPipe := kernel32.NewProc("ConnectNamedPipe")

	if w.isServer {
		r1, _, errNo := connectNamedPipe.Call(uintptr(w.pipe), 0)
		if r1 == 0 {
			return nil, errors.New("等待客户端连接失败: " + errNo.Error())
		}
	}

	var h syscall.Handle
	if w.isServer {
		h = w.pipe
	} else {
		pipeNamePtr, err := syscall.UTF16PtrFromString("\\\\.\\pipe\\mynamedpipe")
		if err != nil {
			return nil, errors.New("无法转换管道名称")
		}

		var err2 error // 使用新的变量名避免遮蔽
		h, err2 = syscall.CreateFile(pipeNamePtr, syscall.GENERIC_READ, 0, nil, syscall.OPEN_EXISTING, 0, 0)
		if err2 != nil {
			return nil, errors.New("无法打开命名管道: " + err2.Error())
		}
		defer syscall.CloseHandle(h)
	}

	buffer := make([]byte, 4096)
	var bytesRead uint32
	r1, _, errNo := readFile.Call(uintptr(h), uintptr(unsafe.Pointer(&buffer[0])), uintptr(len(buffer)), uintptr(unsafe.Pointer(&bytesRead)), 0)
	if r1 == 0 {
		return nil, errors.New("读取数据失败: " + errNo.Error())
	}

	return buffer[:bytesRead], nil
}
