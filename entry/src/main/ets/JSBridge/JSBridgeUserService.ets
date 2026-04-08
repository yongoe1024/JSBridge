import {
  H5Code, H5Params, H5Result, JSBridgeMethod, JSBridgeService
} from "@dims/jsbridge"


@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService {
  @JSBridgeMethod()
  fun1(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      data: '来自：鸿蒙侧返回结果'
    }
  }

  @JSBridgeMethod()
  fun1Err(entity: H5Params): H5Result {
    return {
      code: H5Code.FAIL,
      data: '来自：鸿蒙侧返回结果 error'
    }
  }

  @JSBridgeMethod()
  fun2(entity: H5Params): H5Result {
    return {
      code: H5Code.SUCCESS,
      methodNameListForJsProxy: ['testFun'],
      testFun: () => {
        return '来自：鸿蒙侧 testFun 回调返回结果'
      },
      other: {
        name: '其他任意非函数对象'
      }
    }
  }

  @JSBridgeMethod()
  fun3(entity: H5Params): H5Result {
    entity.args('鸿蒙侧成功执行h5传入函数')
    return {
      code: H5Code.SUCCESS,
      data: '来自鸿蒙的返回数据'
    }
  }

  @JSBridgeMethod()
  async asyncFun1(entity: H5Params): Promise<H5Result> {
    return new Promise((r, e) => {
      r({
        code: H5Code.SUCCESS,
        data: '来自鸿蒙的异步函数，返回数据'
      })
    })
  }

  @JSBridgeMethod()
  async asyncFun1Err(entity: H5Params): Promise<H5Result> {
    return new Promise((r, e) => {
      e({
        code: H5Code.FAIL,
        data: '来自鸿蒙的异步函数，返回数据 Err'
      })
    })
  }

  @JSBridgeMethod()
  asyncFun2(entity: H5Params): Promise<H5Result> {
    return new Promise((r, e) => {
      r({
        code: H5Code.SUCCESS,
        data: '来自鸿蒙的返回数据',
        methodNameListForJsProxy: ['testFun'],
        testFun: () => {
          return '来自鸿蒙的异步函数回调，返回数据'
        },
        other: {
          name: '其他任意非函数的对象'
        }
      })
    })
  }
}
