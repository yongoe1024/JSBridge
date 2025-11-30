import { JSBridgeClass } from "../model/TypeOptions";
import { H5BridgeCode, H5CallbackEntity } from "../model/H5CallbackEntity";
import { BaseJSBridgeService } from "../service/BaseJSBridgeService";
import { H5CallEntity } from "../model/H5CallEntity";
import { LogUtil } from "../log/LogUtil";

export class JSBridgeManager {
  /**
   * 全部服务
   */
  private serviceFactoryMap = new Map<string, () => BaseJSBridgeService>();
  /**
   * 实例化的服务
   */
  private serviceMap = new Map<string, BaseJSBridgeService>()

  constructor() {
  }

  /**
   * 注册函数
   */
  public registerJSBridge(service: JSBridgeClass): void {
    const prototype: ESObject = service.prototype
    if (prototype['__meta__']?.serviceName && prototype['__meta__']?.methodNames) {
      this.serviceFactoryMap.set(prototype['__meta__'].serviceName, () => new service());
      LogUtil.debug('注册服务成功: %{public}s', service.name)
    } else {
      LogUtil.debug('缺少装饰器,注册服务失败: %{public}s', service.name)
    }
  }

  /**
   * H5调用Native方法入口
   */
  public callNative(entity: H5CallEntity): H5CallbackEntity {
    let service: BaseJSBridgeService | undefined = this.getService(entity.service)
    if (!service) {
      return {
        code: H5BridgeCode.NOT_EXIST_SERVICE,
        msg: '服务不存在'
      }
    }
    // 注册成功服务，一定会有元数据
    let proto: ESObject = service.constructor.prototype
    // 判断数组是否存在函数
    let arr = proto['__meta__'].methodNames as string[]
    if (arr.indexOf(entity.method) < 0) {
      return {
        code: H5BridgeCode.NOT_EXIST_METHOD,
        msg: '方法不存在'
      }
    }
    try {
      return service[entity.method](entity)
    } catch (e) {
      return {
        code: H5BridgeCode.FAIL,
        msg: '执行失败',
      }
    }
  }

  /**
   * 获取Service服务
   */
  private getService(name: string): BaseJSBridgeService | undefined {
    let service: BaseJSBridgeService | undefined = this.serviceMap.get(name)
    if (!service) {
      let factory = this.serviceFactoryMap.get(name)
      if (factory) {
        service = factory();
        try {
          service.aboutToAppear();
          LogUtil.debug('%{public}s 执行aboutToAppear success', name)
        } catch (e) {
          LogUtil.debug('%{public}s 执行aboutToAppear error', name)
        }
        this.serviceMap.set(name, service);
      }
    }
    return service;
  }

  /**
   * 处理资源回收处理
   */
  public clear(): void {
    this.serviceMap.forEach((service, _) => {
      try {
        service.aboutToDisappear();
        LogUtil.debug('%{public}s 执行aboutToDisappear success', _)
      } catch (e) {
        LogUtil.debug('%{public}s 执行aboutToDisappear error', _)
      }
    });
  }
}