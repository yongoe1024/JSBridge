import { JSBridgeClass } from "../model/TypeOptions";
import { H5Code, H5Result } from "../model/H5Result";
import { H5Params } from "../model/H5Params";
import { MetaData } from "../model/MetaData";
import { hilog } from "@kit.PerformanceAnalysisKit";

const DOMAIN: number = 0x0000;
const TAG: string = 'JSBridgeManager'

export class JSBridgeManager<T extends object> {
  /**
   * 全部服务
   */
  private serviceFactoryMap = new Map<string, () => T>();
  /**
   * 实例化的服务
   */
  private serviceMap = new Map<string, T>()

  constructor() {
  }

  /**
   * 注册函数
   */
  public registerJSBridge(service: JSBridgeClass<T>): void {
    const prototype: ESObject = service.prototype
    if (prototype['__meta__']) {
      const meta: MetaData = prototype['__meta__']
      if (this.serviceFactoryMap.has(meta.serviceName)) {
        hilog.error(DOMAIN, TAG, `禁止重复注册同名服务:${service.name}`);
        return
      }
      this.serviceFactoryMap.set(meta.serviceName, () => new service());
      hilog.debug(DOMAIN, TAG, `注册服务成功:${service.name}`);
    } else {
      hilog.error(DOMAIN, TAG, `注册服务失败:${service.name}`);
    }
  }

  /**
   * H5调用Native方法入口
   */
  public callNative(entity: H5Params): H5Result {
    let service: T | undefined = this.getService(entity.service)
    if (!service) {
      hilog.debug(DOMAIN, TAG, `调用服务不存在:${entity.service}:${entity.method}`);
      return {
        code: H5Code.NOT_EXIST_SERVICE,
        msg: '服务不存在'
      }
    }
    // 注册成功服务，一定会有元数据
    let meta: MetaData = service.constructor.prototype['__meta__']
    // 判断数组是否存在函数
    let map = meta.h5NameToMethodName
    if (!map[entity.method]) {
      hilog.debug(DOMAIN, TAG, `调用方法不存在:${entity.service}:${entity.method}`);
      return {
        code: H5Code.NOT_EXIST_METHOD,
        msg: '方法不存在'
      }
    }
    try {
      hilog.debug(DOMAIN, TAG, `调用函数:${entity.service}:${entity.method}`);
      return service[map[entity.method]](entity)
    } catch (e) {
      hilog.error(DOMAIN, TAG, `执行失败:${entity.service}:${entity.method}，${e.code + e.message}}`);
      return {
        code: H5Code.FAIL,
        msg: '执行失败',
      }
    }
  }

  /**
   * 获取Service服务
   */
  private getService(name: string): T | undefined {
    let service: T | undefined = this.serviceMap.get(name)
    if (!service) {
      let factory = this.serviceFactoryMap.get(name)
      if (factory) {
        service = factory();
        this.serviceMap.set(name, service);
      }
    }
    return service;
  }
}