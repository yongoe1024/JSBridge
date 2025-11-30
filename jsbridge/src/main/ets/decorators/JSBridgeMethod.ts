export const JSBridgeMethod = (methodName?: string) => {
  return function (target: ESObject, propertyKey: string, descriptor: PropertyDescriptor) {
    //target是原型
    if (!target.__meta__) {
      target.__meta__ = {}
    }
    const originalMethod = descriptor.value;
    descriptor.value = function (...args: any[]) {
      return originalMethod.apply(this, args);
    };
    if (!target.__meta__.methodNames) {
      target.__meta__.methodNames = []
    }
    target.__meta__.methodNames.push(methodName ?? propertyKey);
  }
}
