# JSBridge

轻量级 JSBridge，使用装饰器完成映射，操作简单。  
联系邮箱 121887765@qq.com

## 特性

- 基于 `@JSBridgeService` 和 `@JSBridgeMethod` 装饰器完成服务与方法映射
- 支持 Web 调用鸿蒙侧同步方法
- 支持 Web 调用鸿蒙侧异步方法
- 支持鸿蒙侧返回普通对象、回调函数
- 支持鸿蒙侧主动执行 H5 传入的回调函数
- 内置基础错误码，便于区分服务不存在、方法不存在、执行失败等场景
- 禁止重复注册同名服务，避免运行时映射冲突

## 下载安装

1. 安装最新版 `ohpm i @dims/jsbridge`
2. 升级版本 `ohpm update @dims/jsbridge`，建议使用最新版避免bug

OpenHarmony ohpm
环境配置等更多内容，请参考[如何安装 OpenHarmony ohpm 包](https://ohpm.openharmony.cn/#/cn/help/downloadandinstall)

[工程版本升级教程](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-integrated-project-migration)

## 完整流程

### 1. 定义桥接服务

使用 `@JSBridgeService` 标记一个桥接服务，使用 `@JSBridgeMethod` 暴露 H5 可调用的方法。

```ts
import {
  H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService
} from '@dims/jsbridge'

@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService {
  @JSBridgeMethod()
  fun1(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      data: '来自鸿蒙侧返回结果'
    }
  }

  @JSBridgeMethod('getUserInfo')
  fun2(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      data: {
        name: 'Tom'
      }
    }
  }

  @JSBridgeMethod()
  async asyncFun1(entity: H5Params): Promise<H5Result> {
    return {
      code: H5Code.SUCCESS,
      data: '来自鸿蒙异步函数返回结果'
    }
  }
}
```

说明：

- `@JSBridgeService('JSBridgeUserService')` 中的名称，就是 H5 调用时的 `service`
- `@JSBridgeMethod('getUserInfo')` 可以给 H5 暴露一个自定义方法名
- 如果 `@JSBridgeMethod()` 不传参，则默认使用真实函数名作为 H5 调用名

### 2. 注册到 WebView

在页面中创建 `JSBridgeManager`，注册服务，再通过 `registerJavaScriptProxy` 注入到 Web。

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

说明：

- `App` 是注入到 H5 的对象名，可按需替换
- `callNative` 是暴露给 H5 的统一调用入口，不可修改
- 同一个 `JSBridgeManager` 中不允许重复注册同名服务

### 3. H5 调用鸿蒙方法

#### 同步调用

```js
var result = App.callNative({
    service: 'JSBridgeUserService',
    method: 'fun1',
    args: '我是 js 入参'
});

console.log(result);
```

#### 异步调用

```js
App.callNative({
    service: 'JSBridgeUserService',
    method: 'asyncFun1',
    args: '我是 js 入参'
}).then(function (result) {
    console.log(result);
}).catch(function (error) {
    console.log(error);
});
```

#### 调用自定义方法名

当鸿蒙侧使用了 `@JSBridgeMethod('getUserInfo')` 时，H5 需要按映射名调用：

```js
var result = App.callNative({
    service: 'JSBridgeUserService',
    method: 'getUserInfo'
});
```

### 4. 鸿蒙侧调用 H5 传入函数

```ts
@JSBridgeMethod()
fun3(entity: H5Params): H5Result {
  entity.args('鸿蒙侧成功执行 h5 传入函数')
  return {
    code: H5Code.SUCCESS,
    data: '来自鸿蒙的返回数据'
  }
}
```

```js
App.callNative({
    service: 'JSBridgeUserService',
    method: 'fun3',
    args: function (value) {
        console.log('鸿蒙侧回调 js:', value);
    }
});
```

### 5. 鸿蒙侧返回函数给 H5

如果返回对象中包含函数，需要通过 `methodNameListForJsProxy` 声明哪些字段是函数代理。

```ts
@JSBridgeMethod()
fun2(entity: H5Params): H5Result {
  return {
    code: H5Code.SUCCESS,
    methodNameListForJsProxy: ['testFun'],
    testFun: () => {
      return '来自鸿蒙侧 testFun 回调返回结果'
    },
    other: {
      name: '其他普通对象'
    }
  }
}
```

```js
var result = App.callNative({
    service: 'JSBridgeUserService',
    method: 'fun2'
});

if (result && typeof result.testFun === 'function') {
    console.log(result.testFun('来自 js 的入参'));
}
```

### 6. 错误码说明

`H5Code` 当前定义如下：

```ts
export enum H5Code {
  NOT_EXIST_METHOD = -2,
  NOT_EXIST_SERVICE = -1,
  SUCCESS = 0,
  FAIL = 1,
}
```

常见返回示例：

```json
{
  "code": -1,
  "msg": "服务不存在"
}
```

```json
{
  "code": -2,
  "msg": "方法不存在"
}
```

同步执行过程中如果方法内部直接抛出异常，框架会返回：

```json
{
  "code": 1,
  "msg": "执行失败"
}
```

异步方法返回 `Promise` 时，如果业务侧主动 `reject`，错误对象会直接进入 H5 的 `.catch()`，例如：

```js
App.callNative({
    service: 'JSBridgeUserService',
    method: 'asyncFun1Err'
}).then(function (result) {
    console.log(result);
}).catch(function (error) {
    console.log(error);
    // 例如:
    // {
    //   code: 1,
    //   data: '来自鸿蒙的异步函数，返回数据 Err'
    // }
});
```

## 最小示例

### 鸿蒙侧

```ts
import {
  H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService
} from '@dims/jsbridge'

@JSBridgeService('DemoService')
export class DemoService {
  @JSBridgeMethod()
  hello(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      data: 'hello from harmony'
    }
  }
}
```

### 页面注册

```ts
import { JSBridgeManager } from '@dims/jsbridge'
import { webview } from '@kit.ArkWeb'
import { DemoService } from '../JSBridge/DemoService'

@Entry
@Component
struct Index {
  controller: webview.WebviewController = new webview.WebviewController()
  jsBridgeManager = new JSBridgeManager()

  aboutToAppear(): void {
    this.jsBridgeManager.registerJSBridge(DemoService)
  }

  build() {
    Web({ src: $rawfile('index.html'), controller: this.controller })
      .javaScriptAccess(true)
      .onControllerAttached(() => {
        this.controller.registerJavaScriptProxy(this.jsBridgeManager, 'App', ['callNative'])
      })
  }
}
```

### H5 侧

```html

<script>
    var result = App.callNative({
      service: 'DemoService',
      method: 'hello',
      args: 'hello from web'
    });
  
    console.log(result);
</script>
```
 
