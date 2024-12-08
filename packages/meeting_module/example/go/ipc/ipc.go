package ipc

type IPC interface {
	Initialize() error
	Send(data []byte) error
	Receive() ([]byte, error)
}

// 移除原有的NewIPC，改用NewServer和NewClient