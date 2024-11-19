import { JsonRpcIframe } from "json-rpc-iframe";

class MeetExternalAPI {
  private readonly domain: string;
  private readonly options: LivekitDemoOptions;
  private rpc!: JsonRpcIframe;
  private listeners: Map<string, Set<(params?: any) => void>> = new Map();

  constructor(domain: string, options: LivekitDemoOptions) {
    this.domain = domain;
    this.options = options;
  }

  getIframeUrl(): string {
    const { serverUrl, room, name } = this.options;
    return `${this.domain}/?autoConnect&serverUrl=${serverUrl}&room=${room}&name=${name}`;
  }
  bindIframe(iframeWindow: Window) {
    this.rpc = new JsonRpcIframe(iframeWindow);
  }
  destroy() {
    this.rpc.destroy();
  }
  hangup() {
    this.rpc.sendRequest("hangup");
  }
  setAudioMute(muted: boolean) {
    this.rpc.sendRequest("setAudioMute", { muted });
  }
  setVideoMute(muted: boolean) {
    this.rpc.sendRequest("setVideoMute", { muted });
  }

  interceptHangup(listener: () => boolean | Promise<boolean>) {
    this.rpc.sendRequest("setInterceptHangupEnabled", { enabled: true });
    this.rpc.registerMethod("interceptHangup", listener);
  }

  // 封装 addListener 方法
  addListener(event: string, listener: (params?: any) => void): void {
    // 获取当前 event 对应的监听器集合
    if (!this.listeners.has(event)) {
      this.listeners.set(event, new Set());
    }

    const eventListeners = this.listeners.get(event);
    if (eventListeners) {
      eventListeners.add(listener);

      // 只有第一次添加监听器时，才调用 registerMethod 来注册
      if (eventListeners.size === 1) {
        this.rpc.registerMethod(event, this.createHandler(event));
      }
    }
  }

  // 封装 removeListener 方法
  removeListener(event: string, listener: (params?: any) => void): void {
    const eventListeners = this.listeners.get(event);
    if (eventListeners) {
      eventListeners.delete(listener);

      // 如果没有监听器了，注销该事件
      if (eventListeners.size === 0) {
        this.rpc.unregisterMethod(event);
      }
    }
  }

  // 内部方法，负责调用所有注册的监听器
  private createHandler(event: string): (params?: any) => void {
    return (params?: any): void => {
      const eventListeners = this.listeners.get(event);
      if (eventListeners) {
        // 执行所有注册的监听器
        eventListeners.forEach((listener) => listener(params));
      }
    };
  }
}
class LivekitDemoOptions {
  serverUrl?: string;
  room?: string;
  name?: string;

  constructor(serverUrl?: string, room?: string, name?: string) {
    this.serverUrl = serverUrl;
    this.room = room;
    this.name = name;
  }
}

module.exports = MeetExternalAPI;
