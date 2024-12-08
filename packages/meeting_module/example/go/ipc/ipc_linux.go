// +build linux

// ipc/ipc_linux.go
package ipc

type IpcImpl struct{}

func (l *IpcImpl) Send(data []byte) error {
    // TODO: 实现 Linux IPC 发送
    return nil
}

func (l *IpcImpl) Receive() ([]byte, error) {
    // TODO: 实现 Linux IPC 接收
    return nil, nil
}