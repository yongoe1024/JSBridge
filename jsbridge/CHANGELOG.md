# 更新日志

本文件记录项目的重要变更。格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循[语义化版本](https://semver.org/lang/zh-CN/)。

## 2.0.0

### 新增

- `H5Result` 新增显式 `data` 字段，用于承载业务返回数据。

### 变更

- `registerJSBridge` 现返回 `boolean`，指示服务是否注册成功（缺少元数据或服务名重复时返回 `false`）。
- `H5Params.args` 改为可选参数，与「调用可不带参数」的实际用法一致。

### 修复

- 修正 `callNative` 的返回类型为 `H5Result | Promise<H5Result>`，准确反映同步返回值与异步 `Promise`（此前仅声明为 `H5Result`）。
- 修复服务类被继承时，子类会沿原型链篡改父类元数据的问题（改为仅读取自有元数据）。

### 移除

- 移除 `JSBridgeManager` 上从未使用的泛型参数 `T`，精简类型签名（`new JSBridgeManager()` 用法不变）。

### 文档

- 重写 README：补充安装、用法、错误码与 API 参考。

## 1.0.0

- 首次发布。
