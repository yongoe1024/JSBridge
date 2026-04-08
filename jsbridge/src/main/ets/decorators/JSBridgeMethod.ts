import { MetaData } from "../model/MetaData";

export const JSBridgeMethod = (methodName?: string) => {
  return function (target: ESObject, propertyKey: string, descriptor: PropertyDescriptor) {
    //target是原型
    if (!target.__meta__) {
      target.__meta__ = new MetaData()
    }
    const originalMethod = descriptor.value;
    descriptor.value = function (...args: any[]) {
      return originalMethod.apply(this, args);
    };
    target.__meta__.h5NameToMethodName[methodName ?? propertyKey] = propertyKey
  }
}
