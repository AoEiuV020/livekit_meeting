//go:build darwin
// +build darwin

// ipc/ipc_darwin.go
package ipc

type IpcImpl struct{}

func (d *IpcImpl) Send(data []byte) error {
	// TODO: 实现 Darwin IPC 发送
	return nil
}

func (d *IpcImpl) Receive() ([]byte, error) {
	// TODO: 实现 Darwin IPC 接收
	return nil, nil
}
