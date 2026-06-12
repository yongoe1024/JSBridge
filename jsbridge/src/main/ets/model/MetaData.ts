/**
 * 桥接元数据：保存服务名与「H5 方法名 -> 真实方法名」映射。
 * 由装饰器写入服务类原型（挂在 __meta__ 上），由 JSBridgeManager 读取，
 * 是连接装饰器与运行时的唯一契约。__meta__ 的键名与读写逻辑只在本文件出现。
 */
export class MetaData {
  /** 服务名，对应 @JSBridgeService 入参，即 H5 调用时的 service 字段 */
  serviceName: string = ''
  /** H5 调用名 -> 真实方法名 的映射表 */
  private h5NameToMethodName: Record<string, string> = {}

  registerMethod(h5MethodName: string, realMethodName: string): void {
    this.h5NameToMethodName[h5MethodName] = realMethodName
  }

  resolveMethod(h5MethodName: string): string | undefined {
    if (!Object.prototype.hasOwnProperty.call(this.h5NameToMethodName, h5MethodName)) {
      return undefined
    }
    return this.h5NameToMethodName[h5MethodName]
  }

  /** 读取原型上的元数据（沿原型链查找），不存在返回 undefined */
  static read(prototype: ESObject): MetaData | undefined {
    return prototype.__meta__
  }

  /**
   * 读取原型「自有」的元数据，不存在则创建并挂载。
   * 用 hasOwnProperty 而非 `!prototype.__meta__`：后者会沿原型链查找，
   * 服务类被继承时子类会误读并篡改父类元数据，前者只判断自有属性，
   * 保证每个类拥有独立的元数据。
   */
  static ensure(prototype: ESObject): MetaData {
    if (!Object.prototype.hasOwnProperty.call(prototype, '__meta__')) {
      prototype.__meta__ = new MetaData()
    }
    return prototype.__meta__
  }
}
