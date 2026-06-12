/**
 * 可被注册的服务类构造器类型：一个无参构造、返回服务实例 T 的类。
 */
export type JSBridgeClass<T = object> = new () => T;
