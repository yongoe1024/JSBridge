import { webview } from "@kit.ArkWeb";
import { JSBridgeManager } from "jsbridge";
import { JSBridgeUserService } from "../JSBridge/JSBridgeUserService";

@Entry
@Component
struct WebView {
  url: Resource = $rawfile('index.html')
  controller: webview.WebviewController = new webview.WebviewController();
  jsBridgeManager = new JSBridgeManager()

  aboutToAppear(): void {
    this.jsBridgeManager.registerJSBridge(JSBridgeUserService)
    // 配置Web开启调试模式
    webview.WebviewController.setWebDebuggingAccess(true);
  }

  onBack() {
    if (this.controller.accessBackward()) {
      this.controller.backward();
      return true;
    }
    return true;
  }

  aboutToDisappear(): void {
    this.controller.deleteJavaScriptRegister('App')
    this.jsBridgeManager.clear()
  }

  onBackPress(): boolean | void {
    if (this.controller.accessBackward()) {
      this.controller.backward();
      return true;
    }
    return false
  }

  build() {
    Column() {
      Web({ src: this.url, controller: this.controller })
        .javaScriptAccess(true)//允许javascript
        .domStorageAccess(true)//允许dom存放数据
        .geolocationAccess(true)//允许定位
        .cacheMode(CacheMode.Online)//设置缓存模式
        .layoutWeight(1)
        .mixedMode(MixedMode.All)
        .onControllerAttached(() => {
          this.controller.registerJavaScriptProxy(this.jsBridgeManager, 'App', ['callNative'])
        })
    }
    .width('100%')
    .height('100%')
  }
}