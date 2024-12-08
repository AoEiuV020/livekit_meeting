package main

import (
	"encoding/json"
	"example/common/ipc"
	"fmt"
)

func main() {
	ipcInstance := ipc.NewClient()

	// 发送JSON数据
	jsonData := map[string]interface{}{
		"message": "Hello, IPC!",
		"number":  42,
	}
	data, err := json.Marshal(jsonData)
	if err != nil {
		fmt.Println("编码JSON时出错:", err)
		return
	}

	err = ipcInstance.Send(data)
	if err != nil {
		fmt.Println("发送数据时出错:", err)
		return
	}

	fmt.Println("数据发送成功")
}
