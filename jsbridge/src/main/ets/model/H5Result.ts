/**
 * H5调用native请求类型
 */
export interface H5Result {
  //  返回码
  code: H5Code
  // 返回信息
  msg?: string
  // 如果有函数，则添加此字段
  methodNameListForJsProxy?: string[]

  // 返回数据或返回函数
  [property: string]: ESObject
}

export enum H5Code {
  NOT_EXIST_METHOD = -2, //不存在方法
  NOT_EXIST_SERVICE = -1, //不存在模块
  SUCCESS = 0, //成功
  FAIL = 1, //失败
}

