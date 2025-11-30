import { JSBridgeManager } from "@dims/jsbridge";
import { webview } from "@kit.ArkWeb";
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
        .onControllerAttached(() => {
          this.controller.registerJavaScriptProxy(this.jsBridgeManager, 'App', ['callNative'])
          // this.controller.registerJavaScriptProxy(new TestClass(), "testObjName", ["test"]);
        })
        .onAlert((event) => {
          if (event) {
            this.getUIContext().showAlertDialog({
              title: "来自" + event.url,
              message: event.message,
              confirm: {
                value: "确认",
                action: () => {
                  event.result.handleConfirm();
                }
              },
              cancel: () => {
                event.result.handleCancel();
              }
            })
          }
          return true;
        })
    }
    .width('100%')
    .height('100%')
  }
}
