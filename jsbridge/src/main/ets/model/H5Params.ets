/**
 * H5 调用 native 的请求参数类型。
 */
export interface H5Params {
  /** 服务名，对应 @JSBridgeService 的入参 */
  service: string,

  /** 方法名，对应 @JSBridgeMethod 暴露的 H5 调用名 */
  method: string,

  /** 调用参数（可选）：既可是普通入参，也可是 H5 传入、供鸿蒙侧回调执行的函数 */
  args?: ESObject
}
