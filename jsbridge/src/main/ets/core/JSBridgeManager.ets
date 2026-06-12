import { JSBridgeClass } from "../model/TypeOptions";
import { H5Code, H5Result } from "../model/H5Result";
import { H5Params } from "../model/H5Params";
import { MetaData } from "../model/MetaData";
import { hilog } from "@kit.PerformanceAnalysisKit";

const DOMAIN: number = 0x0000;
const TAG: string = 'JSBridgeManager'
const MSG_INVALID_PARAMS: string = '参数不合法'
const MSG_NOT_EXIST_SERVICE: string = '服务不存在'
const MSG_NOT_EXIST_METHOD: string = '方法不存在'
const MSG_EXECUTE_FAIL: string = '执行失败'

interface ServiceEntry {
  factory: () => object
  meta: MetaData
  instance?: object
}

export class JSBridgeManager {
  private services: Map<string, ServiceEntry> = new Map()

  /**
   * 注册桥接服务。
   * @param service 被 @JSBridgeService 装饰的服务类
   * @returns 是否注册成功（缺少元数据或同名服务已存在时返回 false）
   */
  public registerJSBridge(service: JSBridgeClass): boolean {
    const meta: MetaData | undefined = MetaData.read(service.prototype)
    if (!meta) {
      hilog.error(DOMAIN, TAG, `注册服务失败，未找到元数据(是否遗漏 @JSBridgeService?):${service.name}`);
      return false
    }
    if (!this.isValidName(meta.serviceName)) {
      hilog.error(DOMAIN, TAG, `注册服务失败，服务名为空:${service.name}`);
      return false
    }
    if (this.services.has(meta.serviceName)) {
      hilog.error(DOMAIN, TAG, `禁止重复注册同名服务:${meta.serviceName}`);
      return false
    }
    this.services.set(meta.serviceName, { factory: () => new service(), meta });
    hilog.debug(DOMAIN, TAG, `注册服务成功:${meta.serviceName}`);
    return true
  }

  /**
   * H5 调用 Native 方法的统一入口（注入到 Web 的 callNative）。
   * @param entity H5 请求参数（service / method / args）
   * @returns 同步方法返回 H5Result；异步方法返回 Promise<H5Result>
   */
  public callNative(entity: H5Params): H5Result | Promise<H5Result> {
    if (!entity || !this.isValidName(entity.service) || !this.isValidName(entity.method)) {
      hilog.debug(DOMAIN, TAG, `调用参数不合法`);
      return this.createResult(H5Code.FAIL, MSG_INVALID_PARAMS)
    }

    const entry: ServiceEntry | undefined = this.services.get(entity.service)
    if (!entry) {
      hilog.debug(DOMAIN, TAG, `调用服务不存在:${entity.service}:${entity.method}`);
      return this.createResult(H5Code.NOT_EXIST_SERVICE, MSG_NOT_EXIST_SERVICE)
    }

    const realMethodName: string | undefined = entry.meta.resolveMethod(entity.method)
    if (!realMethodName) {
      hilog.debug(DOMAIN, TAG, `调用方法不存在:${entity.service}:${entity.method}`);
      return this.createResult(H5Code.NOT_EXIST_METHOD, MSG_NOT_EXIST_METHOD)
    }

    try {
      hilog.debug(DOMAIN, TAG, `调用函数:${entity.service}:${entity.method}`);
      const service: ESObject = this.getInstance(entry)
      // 成员调用形式，保证 this 绑定到 service 实例。
      // 同步方法直接返回 H5Result；异步方法返回 Promise<H5Result>，由 ArkWeb
      // 代理成 H5 可用的 thenable。故这一行即可覆盖同步 / 异步两种情况。
      // 注意：下方 try/catch 只能捕获同步抛出的异常；异步方法返回的 Promise 若
      // reject，会直接透传到 H5 的 .catch()，不会进入此 catch 分支。
      return service[realMethodName](entity)
    } catch (e) {
      hilog.error(DOMAIN, TAG, `执行失败:${entity.service}:${entity.method}，${this.formatError(e)}`);
      return this.createResult(H5Code.FAIL, MSG_EXECUTE_FAIL)
    }
  }

  /**
   * 获取服务实例：优先取缓存，未实例化则经工厂创建并缓存（懒加载）。
   */
  private getInstance(entry: ServiceEntry): object {
    if (!entry.instance) {
      entry.instance = entry.factory();
    }
    return entry.instance;
  }

  private createResult(code: H5Code, msg: string): H5Result {
    return {
      code,
      msg
    }
  }

  private isValidName(value: string): boolean {
    return typeof value === 'string' && value.length > 0
  }

  private formatError(error: ESObject): string {
    if (error && error.message) {
      return `${error.message}`
    }
    return `${error}`
  }
}
