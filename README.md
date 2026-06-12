# JSBridge

面向 HarmonyOS ArkWeb（WebView）的轻量级 JSBridge：基于装饰器声明服务与方法，实现 H5 与鸿蒙原生之间的双向调用。

![version](https://img.shields.io/badge/version-2.0.0-green)
![license](https://img.shields.io/badge/license-Apache--2.0-lightgrey)

## 简介

鸿蒙侧通过 `@JSBridgeService` / `@JSBridgeMethod` 声明桥接服务，H5 侧通过注入对象的统一入口 `callNative({ service, method, args })` 发起调用，支持同步、异步与双向回调三类交互。

本仓库同时包含库源码与一个可运行的演示 App。

## 仓库结构

| 目录 | 说明 |
| --- | --- |
| [`jsbridge/`](./jsbridge) | 库源码，发布为 `@dims/jsbridge`；完整用法与 API 见 [jsbridge/README.md](./jsbridge/README.md) |
| [`entry/`](./entry) | 演示 App，通过本地依赖（`file:../jsbridge`）引用该库，演示同步 / 异步 / 回调交互 |

## 特性

- 装饰器声明服务与方法映射，无需手写注册表
- H5 调用原生同步 / 异步方法
- 函数代理（原生返回函数）与函数透传（原生回调 H5 函数）
- 内置错误码与同名服务重复注册保护

## 安装

```bash
ohpm i @dims/jsbridge
```

## 快速开始

定义桥接服务（鸿蒙侧）：

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

注册并注入到 WebView（鸿蒙侧）：

```ts
this.jsBridgeManager.registerJSBridge(JSBridgeUserService)
// onControllerAttached 中：
this.controller.registerJavaScriptProxy(this.jsBridgeManager, 'App', ['callNative'])
```

H5 调用（Web 侧）：

```js
var result = App.callNative({ service: 'JSBridgeUserService', method: 'fun1', args: 'hi' });
console.log(result);
```

> 完整用法（自定义方法名、异步调用、函数代理、函数透传、错误码等）见 [jsbridge/README.md](./jsbridge/README.md)。

## 运行演示 App

1. 用 DevEco Studio 打开本仓库根目录工程。
2. 等待 ohpm 依赖同步完成（`entry` 通过 `file:../jsbridge` 引用本地库源码，改动库即时生效）。
3. 选择 `entry` 模块，连接真机或启动模拟器后运行。
4. 首页进入 Web 演示页，可分别验证三类交互：
   - 同步调用：普通调用、失败态，以及方法 / 服务不存在的异常兜底；
   - 回调交互：执行原生返回对象中的函数，以及原生主动回调 JS 函数；
   - 异步调用：`Promise` 基本调用、`reject` 失败链路、异步回调对象。

## 文档

- 库完整用法与 API：[jsbridge/README.md](./jsbridge/README.md)
- 更新记录：[jsbridge/CHANGELOG.md](./jsbridge/CHANGELOG.md)
- 工程版本升级：[HarmonyOS 工程迁移指南](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/ide-integrated-project-migration)

## 许可证

[Apache-2.0](./LICENSE)

## 反馈与支持

- 提交问题：[GitHub Issues](https://github.com/yongoe1024/JSBridge/issues)
- 邮箱：121887765@qq.com
