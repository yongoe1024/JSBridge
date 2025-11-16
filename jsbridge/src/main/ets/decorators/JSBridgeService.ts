export const JSBridgeService = (serviceName: string) => {
  return function (target: ESObject) {
    //获取构造函数中的类原型
    target = target.prototype
    if (!target.__meta__) {
      target.__meta__ = {}
    }
    target.__meta__.serviceName = serviceName;
  };
}