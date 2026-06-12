import { MetaData } from "../model/MetaData";

/**
 * 类装饰器：把一个类标记为可被 H5 调用的桥接服务。
 * @param serviceName H5 调用时使用的 service 名称
 */
export const JSBridgeService = (serviceName: string) => {
  return function (target: ESObject) {
    // target 是构造函数，元数据挂在其原型上
    MetaData.ensure(target.prototype).serviceName = serviceName
  };
}
