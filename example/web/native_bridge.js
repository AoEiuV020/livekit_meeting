/**
 * WebView桥接器
 * 抹平鸿蒙/Android/iOS平台差异，提供统一的字符串收发接口
 * 
 * 命名说明：
 * - WebViewHostBridge: 原生宿主注入的对象（鸿蒙/Android/iOS注入）
 * - WebViewClientBridge: JS暴露的统一API（供Web端使用）
 * 
 * 消息流向：
 * - Web发送到外部: WebViewClientBridge.send(msg) -> 原生宿主/iframe父窗口
 * - 外部发送到Web: 原生宿主调用onHostMessage(msg) -> 触发messageListeners
 * 
 * 【浏览器控制台测试示例】
 * 
 * // 1. 添加消息监听器（接收外部发来的消息）
 * WebViewClientBridge.addMessageListener(function(msg) {
 *   console.log('收到外部消息:', msg);
 * });
 * 
 * // 2. 覆盖send函数拦截Web发出的消息（测试Flutter发送）
 * var originalSend = WebViewClientBridge.send;
 * WebViewClientBridge.send = function(msg) {
 *   console.log('拦截Web发送:', msg);
 *   originalSend(msg);
 * };
 * 
 * // 3. 模拟外部发送消息到Web（测试监听器）
 * WebViewClientBridge.onHostMessage('{"jsonrpc":"2.0","method":"hangUp","id":1}');
 * 
 * // 4. 检查桥接是否可用
 * console.log('桥接可用:', WebViewClientBridge.isAvailable());
 */
(function() {
  'use strict';

  // 原生宿主注入的对象名称（鸿蒙/Android/iOS使用相同名称）
  var HOST_BRIDGE_NAME = 'WebViewHostBridge';
  
  // 消息监听器列表（用于接收外部发来的消息）
  var messageListeners = [];

  /**
   * 检测是否在iframe中运行
   */
  function isInIframe() {
    try {
      return window.self !== window.top;
    } catch (e) {
      return true;
    }
  }

  /**
   * 检测原生宿主注入对象是否存在（鸿蒙/Android）
   */
  function hasHostInjectedObject() {
    return typeof window[HOST_BRIDGE_NAME] !== 'undefined' && 
           typeof window[HOST_BRIDGE_NAME].postMessage === 'function';
  }

  /**
   * 检测iOS WebKit消息处理器是否存在
   */
  function hasIOSMessageHandler() {
    return typeof window.webkit !== 'undefined' && 
           typeof window.webkit.messageHandlers !== 'undefined' &&
           typeof window.webkit.messageHandlers[HOST_BRIDGE_NAME] !== 'undefined';
  }

  /**
   * 发送消息到原生宿主
   * @param {string} message 要发送的字符串消息
   */
  function sendToHost(message) {
    if (hasHostInjectedObject()) {
      // 鸿蒙/Android：使用注入对象
      window[HOST_BRIDGE_NAME].postMessage(message);
    } else if (hasIOSMessageHandler()) {
      // iOS：使用WebKit消息处理器
      window.webkit.messageHandlers[HOST_BRIDGE_NAME].postMessage(message);
    } else if (isInIframe()) {
      // iframe中：向父窗口发送消息
      window.parent.postMessage(message, '*');
    } else {
      console.warn('[WebViewClientBridge] 未找到宿主桥接，消息未发送:', message);
    }
  }

  /**
   * 添加消息监听器（接收外部发来的消息）
   * @param {function} listener 监听器函数，接收消息字符串
   */
  function addMessageListener(listener) {
    if (typeof listener === 'function') {
      messageListeners.push(listener);
    }
  }

  /**
   * 移除消息监听器
   * @param {function} listener 要移除的监听器函数
   */
  function removeMessageListener(listener) {
    var index = messageListeners.indexOf(listener);
    if (index > -1) {
      messageListeners.splice(index, 1);
    }
  }

  /**
   * 分发消息给所有监听器
   * @param {string} message 收到的消息
   */
  function dispatchMessage(message) {
    messageListeners.forEach(function(listener) {
      try {
        listener(message);
      } catch (e) {
        console.error('[WebViewClientBridge] 监听器执行出错:', e);
      }
    });
  }

  /**
   * base64解码并转换为UTF-8字符串
   * @param {string} base64 base64编码的字符串
   * @returns {string} 解码后的UTF-8字符串
   */
  function decodeBase64(base64) {
    var binaryString = atob(base64);
    var bytes = new Uint8Array(binaryString.length);
    for (var i = 0; i < binaryString.length; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    return new TextDecoder('utf-8').decode(bytes);
  }

  /**
   * 原生宿主调用此方法向Web发送消息（base64编码版本，用于安全传输）
   * @param {string} base64Message base64编码的消息字符串
   */
  function onHostMessageBase64(base64Message) {
    var message = decodeBase64(base64Message);
    dispatchMessage(message);
  }

  /**
   * 原生宿主调用此方法向Web发送消息（原始字符串版本）
   * @param {string} message 消息字符串
   */
  function onHostMessage(message) {
    dispatchMessage(message);
  }

  // 监听iframe父窗口消息
  window.addEventListener('message', function(event) {
    if (typeof event.data === 'string') {
      dispatchMessage(event.data);
    }
  });

  // 暴露全局API供Web端使用
  window.WebViewClientBridge = {
    send: sendToHost,
    addMessageListener: addMessageListener,
    removeMessageListener: removeMessageListener,
    onHostMessage: onHostMessage,
    onHostMessageBase64: onHostMessageBase64,
    isAvailable: function() {
      return hasHostInjectedObject() || hasIOSMessageHandler() || isInIframe();
    }
  };

  console.log('[WebViewClientBridge] 初始化完成');
})();
