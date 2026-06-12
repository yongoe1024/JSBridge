import { MetaData } from "../model/MetaData";

/**
 * 方法装饰器：把一个实例方法暴露给 H5 调用。
 * @param methodName H5 调用名；省略时默认使用真实方法名
 */
export const JSBridgeMethod = (methodName?: string) => {
  // target 是原型；原 descriptor.value 透传包装无实际作用，已移除
  return function (target: ESObject, propertyKey: string) {
    MetaData.ensure(target).registerMethod(methodName ?? propertyKey, propertyKey)
  };
}
