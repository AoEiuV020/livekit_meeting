package main

import (
	"encoding/json"
	"log"

	"fyne.io/fyne/v2"
	"fyne.io/fyne/v2/app"
	"fyne.io/fyne/v2/container"
	"fyne.io/fyne/v2/widget"
)

// 定义消息结构体
type Message struct {
	Content string `json:"content"`
}

func main() {
	// 创建应用
	a := app.New()
	// 创建主窗口
	w := a.NewWindow("主窗口")
	w.Resize(fyne.NewSize(400, 300)) // 窗口做大一些

	// 创建两个channel用于消息传递
	mainToRemote := make(chan string)
	remoteToMain := make(chan string)

	// 创建远程窗口
	remoteWindow := a.NewWindow("远程窗口")
	remoteWindow.Resize(fyne.NewSize(400, 300)) // 窗口做大一些
	remoteLabel := widget.NewLabel("等待消息...")
	remoteWindow.SetContent(container.NewVBox(
		remoteLabel,
		widget.NewButton("发送消息到主窗口", func() {
			msg := Message{Content: "来自远程的消息"}
			data, err := json.Marshal(msg)
			if err != nil {
				log.Println("JSON编码错误:", err)
				return
			}
			log.Println("发送消息到主窗口:", string(data))
			remoteToMain <- string(data) // 发送消息到主窗口
		}),
	))

	// 主窗口内容
	mainLabel := widget.NewLabel("等待消息...")
	w.SetContent(container.NewVBox(
		container.NewHBox( // 按钮放在同一行
			widget.NewButton("打开远程窗口", func() {
				remoteWindow.Show()
				log.Println("远程窗口已打开")
			}),
			widget.NewButton("发送消息到远程窗口", func() {
				msg := Message{Content: "来自主窗口的消息"}
				data, err := json.Marshal(msg)
				if err != nil {
					log.Println("JSON编码错误:", err)
					return
				}
				log.Println("发送消息到远程窗口:", string(data))
				mainToRemote <- string(data) // 发送消息到远程窗口
			}),
		),
		mainLabel,
	))

	// 监听远程窗口的消息
	go func() {
		for {
			select {
			case msg := <-mainToRemote:
				var message Message
				if err := json.Unmarshal([]byte(msg), &message); err != nil {
					log.Println("JSON解码错误:", err)
					continue
				}
				remoteLabel.SetText(message.Content)
				log.Println("接收到来自主窗口的消息:", msg)
			}
		}
	}()

	// 监听主窗口的消息
	go func() {
		for {
			select {
			case msg := <-remoteToMain:
				var message Message
				if err := json.Unmarshal([]byte(msg), &message); err != nil {
					log.Println("JSON解码错误:", err)
					continue
				}
				mainLabel.SetText(message.Content)
				log.Println("接收到来自远程窗口的消息:", msg)
			}
		}
	}()

	// 显示主窗口并运行应用
	w.ShowAndRun()
}
