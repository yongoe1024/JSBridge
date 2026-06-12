/**
 * H5 调用 native 的返回结果类型。
 */
export interface H5Result {
  /** 返回码，见 H5Code */
  code: H5Code
  /** 返回信息（多用于错误描述） */
  msg?: string
  /**
   * 当返回对象中包含「需要被 H5 调用的函数」时，在此列出这些函数的字段名。
   * 这是 ArkWeb 运行时的保留字段：ArkWeb 在跨 JS 代理序列化返回值时，依据该列表
   * 把对应成员暴露为 H5 可调用的函数代理。故此字段名由平台约定，不可随意更改。
   */
  methodNameListForJsProxy?: string[]
  /** 业务返回数据（常用字段；也可经下方索引签名返回任意其它字段） */
  data?: ESObject

  // 返回数据或返回函数：允许携带任意附加字段
  [property: string]: ESObject
}

export enum H5Code {
  SUCCESS = 200, // 成功
  FAIL = 500, // 失败
  NOT_EXIST_SERVICE = -1, // 服务不存在
  NOT_EXIST_METHOD = -2, // 方法不存在
}
