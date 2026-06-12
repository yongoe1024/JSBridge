# @dims/jsbridge

面向 HarmonyOS ArkWeb（WebView）的轻量级 JSBridge。基于装饰器声明服务与方法，实现 H5 与鸿蒙原生之间的双向调用。

- 包名：`@dims/jsbridge`
- 许可证：Apache-2.0
- 更新记录：[CHANGELOG.md](./CHANGELOG.md)

## 特性

- **装饰器映射**：`@JSBridgeService` / `@JSBridgeMethod` 声明服务与方法，无需手写注册表
- **同步调用**：H5 直接获得 `H5Result`
- **异步调用**：原生方法返回 `Promise`，H5 通过 `.then` / `.catch` 处理
- **函数代理**：原生返回包含函数的对象，H5 可直接调用其中的函数
- **函数透传**：原生主动执行 H5 通过 `args` 传入的回调函数
- **内置错误码**：区分服务不存在、方法不存在、执行失败等场景
- **重复注册保护**：同一管理器内禁止注册同名服务

## 安装

```bash
ohpm i @dims/jsbridge
```

ohpm 环境配置参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)。

## 快速开始

### 1. 定义桥接服务

用 `@JSBridgeService` 标记服务类，用 `@JSBridgeMethod` 暴露可供 H5 调用的方法。

```ts
import { H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService } from '@dims/jsbridge'

@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService {
  @JSBridgeMethod()
  fun1(entity: H5Params): H5Result {
    return { code: H5Code.SUCCESS, data: '来自鸿蒙侧的返回结果' }
  }
}
```

### 2. 注册并注入到 WebView

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

- `App` 为注入到 H5 的对象名，可自定义；`callNative` 为统一调用入口，不可更改。
- `registerJSBridge` 返回 `boolean`：成功为 `true`；缺少元数据（漏写 `@JSBridgeService`）或服务名重复时为 `false`。

### 3. H5 调用原生方法

```js
var result = App.callNative({
  service: 'JSBridgeUserService',
  method: 'fun1',
  args: 'hello from web'
});
console.log(result);
```

## 进阶用法

### 自定义 H5 方法名

`@JSBridgeMethod('getUserInfo')` 可为方法指定 H5 调用名；不传参时默认使用原方法名。

```ts
@JSBridgeMethod('getUserInfo')
fun2(entity: H5Params): H5Result {
  return { code: H5Code.SUCCESS, data: { name: 'Tom' } }
}
```

```js
App.callNative({ service: 'JSBridgeUserService', method: 'getUserInfo' });
```

### 异步调用

原生方法返回 `Promise<H5Result>`，H5 通过 `.then` / `.catch` 处理。

```ts
@JSBridgeMethod()
async asyncFun1(entity: H5Params): Promise<H5Result> {
  return { code: H5Code.SUCCESS, data: '来自鸿蒙异步函数的返回结果' }
}
```

```js
App.callNative({ service: 'JSBridgeUserService', method: 'asyncFun1' })
  .then(function (result) { console.log(result); })
  .catch(function (error) { console.log(error); });
```

### 函数透传：原生调用 H5 传入的函数

H5 把函数作为 `args` 传入，原生侧直接调用该函数即可回调 H5。

```ts
@JSBridgeMethod()
fun3(entity: H5Params): H5Result {
  entity.args('鸿蒙侧回调 H5 的数据')
  return { code: H5Code.SUCCESS }
}
```

```js
App.callNative({
  service: 'JSBridgeUserService',
  method: 'fun3',
  args: function (value) { console.log('原生回调:', value); }
});
```

### 函数代理：原生返回函数给 H5

返回对象中包含函数时，需在 `methodNameListForJsProxy` 中声明这些函数字段，H5 才能调用。

> `methodNameListForJsProxy` 是 ArkWeb 的保留字段：运行时依据该列表把对应成员暴露为 H5 可调用的函数代理。字段名由平台约定，**不可更改**，否则返回函数能力将失效。

```ts
@JSBridgeMethod()
fun2(entity: H5Params): H5Result {
  return {
    code: H5Code.SUCCESS,
    methodNameListForJsProxy: ['testFun'],
    testFun: () => '来自原生 testFun 的返回结果'
  }
}
```

```js
var result = App.callNative({ service: 'JSBridgeUserService', method: 'fun2' });
if (result && typeof result.testFun === 'function') {
  console.log(result.testFun('来自 H5 的入参'));
}
```

## 错误码

```ts
enum H5Code {
  SUCCESS = 200,          // 成功
  FAIL = 500,             // 失败
  NOT_EXIST_SERVICE = -1, // 服务不存在
  NOT_EXIST_METHOD = -2,  // 方法不存在
}
```

| code | 含义 | 触发场景 |
| --- | --- | --- |
| `200` | 成功 | 业务方法正常返回 |
| `500` | 失败 | 业务主动返回失败，或同步方法内部抛异常被框架捕获 |
| `-1` | 服务不存在 | `service` 未注册 |
| `-2` | 方法不存在 | 服务存在，但 `method` 未通过 `@JSBridgeMethod` 暴露 |

同步与异步的错误处理路径不同：

- 同步方法内部抛出异常 → 被框架 `try/catch` 捕获 → 返回 `{ code: 500, msg: '执行失败' }`。
- 异步方法返回的 `Promise` 若 `reject` → 错误对象直达 H5 的 `.catch()`，不经过框架的 `try/catch`。

## API

### JSBridgeManager

| 成员 | 签名 | 说明 |
| --- | --- | --- |
| `registerJSBridge` | `(service: JSBridgeClass) => boolean` | 注册桥接服务，返回是否注册成功 |
| `callNative` | `(entity: H5Params) => H5Result \| Promise<H5Result>` | H5 统一调用入口，注入到 Web |

### 类型

```ts
interface H5Params {
  service: string          // 服务名，对应 @JSBridgeService 入参
  method: string           // 方法名，对应 @JSBridgeMethod 暴露的调用名
  args?: ESObject          // 调用参数，或供原生回调执行的函数
}

interface H5Result {
  code: H5Code             // 返回码
  msg?: string             // 返回信息（多用于错误描述）
  data?: ESObject          // 业务数据
  methodNameListForJsProxy?: string[] // 声明返回对象中的函数字段（ArkWeb 保留字段）
  [property: string]: ESObject        // 允许携带任意附加字段
}
```

### 装饰器

- `@JSBridgeService(serviceName: string)` — 标记桥接服务；`serviceName` 即 H5 调用时的 `service`。
- `@JSBridgeMethod(methodName?: string)` — 暴露方法；`methodName` 为 H5 调用名，省略时使用原方法名。

## 许可证

[Apache-2.0](./LICENSE)

## 反馈与支持

- 提交问题：[GitHub Issues](https://github.com/yongoe1024/JSBridge/issues)
- 邮箱：121887765@qq.com
