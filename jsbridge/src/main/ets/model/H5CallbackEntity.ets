import { H5BridgeCode } from "../enum/H5BridgeCode";

/**
 * H5调用native请求类型
 */
export interface H5CallbackEntity {
  code: H5BridgeCode
  msg?: string,
  data?: ESObject
}
