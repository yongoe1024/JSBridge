import { JSBridgeManager } from "@dims/jsbridge";
import { webview } from "@kit.ArkWeb";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { JSBridgeUserService } from "../JSBridge/JSBridgeUserService";

// 注入到 Web 的代理对象名与暴露方法：注册(registerJavaScriptProxy)与
// 注销(deleteJavaScriptRegister)共用，避免魔法字符串重复。
const PROXY_NAME: string = 'App'
const PROXY_METHODS: string[] = ['callNative']

@Entry
@Component
struct WebView {
  url: Resource = $rawfile('index.html')
  controller: webview.WebviewController = new webview.WebviewController();
  jsBridgeManager = new JSBridgeManager()

  aboutToAppear(): void {
    // registerJSBridge 返回是否注册成功（缺少元数据或同名服务已存在时为 false）
    const registered = this.jsBridgeManager.registerJSBridge(JSBridgeUserService)
    hilog.info(0x0000, 'WebView', `JSBridge 服务注册结果:${registered}`)
  }

  aboutToDisappear(): void {
    this.controller.deleteJavaScriptRegister(PROXY_NAME)
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
        .onControllerAttached(() => {
          this.controller.registerJavaScriptProxy(this.jsBridgeManager, PROXY_NAME, PROXY_METHODS)
        })
    }
    .width('100%')
    .height('100%')
  }
}
