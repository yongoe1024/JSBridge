# JSBridge

> 轻量级 HarmonyOS WebView JSBridge，基于装饰器完成「服务 / 方法」映射，让 H5 像调用本地函数一样调用鸿蒙原生能力。

[![ohpm](https://img.shields.io/badge/ohpm-%40dims%2Fjsbridge-blue)](https://ohpm.openharmony.cn/#/cn/detail/@dims%2Fjsbridge)
![version](https://img.shields.io/badge/version-2.0.0-green)
![license](https://img.shields.io/badge/license-Apache--2.0-lightgrey)

- 包名：`@dims/jsbridge`
- 当前版本：**2.0.0**（更新记录见 [`jsbridge/CHANGELOG.md`](./jsbridge/CHANGELOG.md)）
- 联系邮箱：121887765@qq.com

## 这是什么

`@dims/jsbridge` 是一套面向 ArkWeb（HarmonyOS WebView）的双向通信桥。鸿蒙侧用
`@JSBridgeService` / `@JSBridgeMethod` 把类和方法声明为「桥接服务」，H5 侧通过一个注入对象
（默认名 `App`）的统一入口 `callNative({ service, method, args })` 调用，支持：

- ✅ H5 调用鸿蒙**同步**方法，直接拿到 `H5Result`
- ✅ H5 调用鸿蒙**异步**方法，通过 `Promise` 的 `.then` / `.catch` 拿结果
- ✅ 鸿蒙返回**包含函数**的对象，H5 调用其中的函数（函数代理）
- ✅ 鸿蒙**主动执行** H5 通过 `args` 传入的回调函数（函数透传）
- ✅ 内置错误码，区分「服务不存在 / 方法不存在 / 执行失败」
- ✅ 禁止重复注册同名服务，避免运行时映射冲突

## 仓库结构

这是一个 DevEco Studio 工程，包含一个发布库和一个演示 App：

| 目录 | 说明 |
| --- | --- |
| [`jsbridge/`](./jsbridge) | **库源码**，即发布到 ohpm 的 `@dims/jsbridge`。完整 API 与用法见 [`jsbridge/README.md`](./jsbridge/README.md) |
| [`entry/`](./entry) | **演示 App**，通过 `file:../jsbridge` 本地依赖该库，演示同步 / 异步 / 回调三类交互 |
| `entry/.../JSBridge/JSBridgeUserService.ets` | 示例桥接服务（`fun1` / `fun2` / `fun3` / `asyncFun1` …） |
| `entry/.../pages/WebView.ets` | 在页面中注册服务并 `registerJavaScriptProxy` 注入到 Web |
| `entry/.../resources/rawfile/` | 演示用 H5 页面（`index` / `sync` / `callback` / `async`）与共享脚本 `assets/bridge.js` |

## 安装

```bash
ohpm i @dims/jsbridge
```

升级到最新版（建议保持最新以规避已知问题）：

```bash
ohpm update @dims/jsbridge
```

ohpm 环境配置参考 [如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)。

## 快速开始

> 完整教程（自定义方法名、函数代理、函数透传、错误处理等）见 **[`jsbridge/README.md`](./jsbridge/README.md)**。

**1. 定义桥接服务**（鸿蒙侧）

```ts
import { H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService } from '@dims/jsbridge'

@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService {
  @JSBridgeMethod()
  fun1(entity: H5Params): H5Result {
    return { code: H5Code.SUCCESS, data: '来自鸿蒙侧的返回结果' }
  }

  @JSBridgeMethod()
  async asyncFun1(entity: H5Params): Promise<H5Result> {
    return { code: H5Code.SUCCESS, data: '来自鸿蒙异步函数的返回结果' }
  }
}
```

**2. 注册并注入到 WebView**（鸿蒙侧）

```ts
import { JSBridgeManager } from '@dims/jsbridge'
import { webview } from '@kit.ArkWeb'
import { JSBridgeUserService } from '../JSBridge/JSBridgeUserService'

@Entry
@Component
struct WebViewPage {
  controller: webview.WebviewController = new webview.WebviewController()
  jsBridgeManager = new JSBridgeManager()

  aboutToAppear(): void {
    this.jsBridgeManager.registerJSBridge(JSBridgeUserService)
  }

  aboutToDisappear(): void {
    this.controller.deleteJavaScriptRegister('App')
  }

  build() {
    Web({ src: $rawfile('index.html'), controller: this.controller })
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .onControllerAttached(() => {
        this.controller.registerJavaScriptProxy(this.jsBridgeManager, 'App', ['callNative'])
      })
  }
}
```

**3. H5 调用鸿蒙方法**（Web 侧）

```js
// 同步
var result = App.callNative({ service: 'JSBridgeUserService', method: 'fun1', args: 'hi' })
console.log(result)

// 异步
App.callNative({ service: 'JSBridgeUserService', method: 'asyncFun1' })
   .then(function (res) { console.log(res) })
   .catch(function (err) { console.log(err) })
```

> `App` 是注入到 H5 的对象名，可按需替换；`callNative` 是统一调用入口，**不可修改**。

## 运行演示 App

1. 用 **DevEco Studio** 打开本工程（根目录）。
2. 等待 `ohpm` 依赖同步完成（`entry` 通过 `file:../jsbridge` 引用本地库源码，改库即时生效）。
3. 选择 `entry` 模块，连接真机或启动模拟器后运行。
4. 首页点击「打开 Web 演示页」进入 H5，再按需进入三个子页验证：
   - **同步调用**：普通调用、失败态，以及方法 / 服务不存在的异常兜底；
   - **回调交互**：执行鸿蒙返回对象中的函数，以及鸿蒙主动执行 JS 回调；
   - **异步调用**：`Promise` 基本调用、`reject` 失败链路、异步回调对象。

每个子页都会把调用结果写入页面底部的结果面板（新结果在最上方），便于连续调试与对比。

## 实现原理（简述）

一套「基于装饰器的轻量 RPC」：

1. **声明期**：装饰器把元数据（服务名 + 「H5 方法名 → 真实方法名」映射）写入服务类原型的 `__meta__`。
2. **注册期**：`registerJSBridge` 读取元数据，以服务名为键登记一个**懒加载工厂**，并拒绝重复注册。
3. **调用期**：H5 调用 `callNative`，先取（或懒创建）服务实例，再解析真实方法名，最后以**成员调用**执行，从而正确保留 `this`。
4. **返回**：同步返回 `H5Result`，异步返回 `Promise<H5Result>`，均由 ArkWeb 代理给 H5；返回对象中的函数通过 `methodNameListForJsProxy` 声明后暴露为 H5 可调用的函数代理。

详细数据流与设计说明见 [`jsbridge/README.md`](./jsbridge/README.md)。

## 错误码

| code | 含义 | 触发场景 |
| --- | --- | --- |
| `200` SUCCESS | 成功 | 业务方法正常返回 |
| `500` FAIL | 失败 | 业务主动返回失败，或同步方法内部抛异常被框架捕获 |
| `-1` NOT_EXIST_SERVICE | 服务不存在 | `service` 未注册 |
| `-2` NOT_EXIST_METHOD | 方法不存在 | 服务存在，但 `method` 未通过 `@JSBridgeMethod` 暴露 |

> 注意：**同步**方法内部抛异常会被框架捕获并返回 `{ code: 500, msg: '执行失败' }`；
> **异步**方法 `reject` 的错误对象会**直达 H5 的 `.catch()`**，不经过框架的 `try/catch`。

## 文档与链接

- 📖 库完整用法与 API：[`jsbridge/README.md`](./jsbridge/README.md)
- 📝 更新记录：[`jsbridge/CHANGELOG.md`](./jsbridge/CHANGELOG.md)
- 📦 ohpm 包页面：[@dims/jsbridge](https://ohpm.openharmony.cn/#/cn/detail/@dims%2Fjsbridge)
- 🔧 [工程版本升级教程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-integrated-project-migration)

## 许可证

[Apache-2.0](./LICENSE)
