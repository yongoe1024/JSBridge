# 版本记录

## 2.0.0

- 集中管理桥接元数据（`MetaData.read` / `MetaData.ensure`），消除装饰器与 Manager 中三处重复的 `__meta__` 硬编码，降低耦合
- 元数据采用 `Object.prototype.hasOwnProperty` 安全读取，修复服务类被继承时子类沿原型链篡改父类元数据的潜在问题
- 移除 `@JSBridgeMethod` 中无实际作用的方法包装，减少调用开销
- `registerJSBridge` 返回 `boolean` 表示注册结果；`callNative` 保持成员调用 `service[method](entity)`，正确支持同步返回值与异步 `Promise`
- 修正 `callNative` 返回类型为 `H5Result | Promise<H5Result>`，与「同步返回值 / 异步 Promise」的实际行为一致（此前仅声明为 `H5Result`）
- 合并服务工厂表与实例缓存表为单一注册表，注册时即缓存元数据，`callNative` 不再经实例的 `constructor.prototype` 二次反查元数据
- 移除 `JSBridgeManager` 上从未被使用的泛型参数 `T`，精简类型签名（`new JSBridgeManager()` 用法不变）
- `H5Params.args` 改为可选（`args?`），与「调用可不带参数」的实际用法一致
- 完善核心注释，明确「同步抛错」与「异步 reject」的不同处理路径；修正日志格式与误导性注释
- `H5Result` 新增显式 `data` 字段；`H5Code` 重排声明顺序（取值不变）
- 扩展 README：新增实现原理 / 架构、错误处理与错误码细化等章节

## 1.0.0 初版
