package main

import (
	"encoding/json"
	"example/common/ipc"
	"fmt"
)

func main() {
	ipcInstance := ipc.NewServer()

	// 初始化服务端
	err := ipcInstance.Initialize()
	if err != nil {
		fmt.Println("初始化服务端失败:", err)
		return
	}

	fmt.Println("等待客户端连接...")

	// 接收数据并打印
	data, err := ipcInstance.Receive()
	if err != nil {
		fmt.Println("接收数据时出错:", err)
		return
	}

	var jsonData map[string]interface{}
	err = json.Unmarshal(data, &jsonData)
	if err != nil {
		fmt.Println("解码JSON时出错:", err)
		return
	}

	fmt.Println("接收到的JSON:", jsonData)
}
