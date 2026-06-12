import {
  H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService
} from "@dims/jsbridge"
import { promptAction } from "@kit.ArkUI"

function toast(text: string) {
  promptAction.showToast({
    message: text
  })
}

@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService {
  // 同步调用：直接返回成功结果
  @JSBridgeMethod()
  fun1(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      msg: `鸿蒙侧返回数据：abcde`,
      data: 'abcde'
    }
  }

  // 同步调用：演示错误返回
  @JSBridgeMethod()
  fun1Err(entity: H5Params): H5Result {
    return {
      code: H5Code.FAIL,
      msg: `鸿蒙侧执行失败`,
    }
  }

  // 同步调用：返回包含函数的对象
  // 重要： 使用methodNameListForJsProxy，对象将只保留声明的函数，其他参数被清空
  @JSBridgeMethod()
  fun2(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      msg: '鸿蒙侧返回一个回调函数',
      methodNameListForJsProxy: ['testFun'],
      testFun: (text: string) => {
        toast("执行原生toast：" + text)
      },
    }
  }

  // 同步调用：鸿蒙侧主动执行 H5 通过 args 传入的回调函数（函数透传）
  @JSBridgeMethod()
  fun3(entity: H5Params): H5Result {
    entity.args('鸿蒙传入的数据')
    return {
      code: H5Code.SUCCESS,
      msg: '鸿蒙侧主动执行H5函数',
    }
  }

  // 异步调用：返回 resolve 的 Promise，H5 在 .then() 拿到结果
  @JSBridgeMethod()
  async asyncFun1(entity: H5Params): Promise<H5Result> {
    return Promise.resolve<H5Result>({
      code: H5Code.SUCCESS,
      data: 'abcde'
    })
  }

  // 异步调用：返回 reject 的 Promise，错误直达 H5 的 .catch()
  @JSBridgeMethod()
  async asyncFun1Err(entity: H5Params): Promise<H5Result> {
    return Promise.reject({
      code: H5Code.FAIL,
      msg: '鸿蒙侧执行失败',
    })
  }

  // 异步调用：Promise 返回包含函数的对象，H5 在 .then() 后调用 testFun
  @JSBridgeMethod()
  async asyncFun2(entity: H5Params): Promise<H5Result> {
    return Promise.resolve<H5Result>({
      code: H5Code.SUCCESS,
      methodNameListForJsProxy: ['testFun'],
      testFun: (text: string) => {
        toast("执行原生toast：" + text)
        return "回调函数返回值：" + text
      },
    })
  }
}
