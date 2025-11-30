import {
  BaseJSBridgeService,
  H5BridgeCode,
  H5CallbackEntity,
  H5CallEntity,
  JSBridgeMethod,
  JSBridgeService
} from "@dims/jsbridge"


@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService extends BaseJSBridgeService {
  public aboutToAppear(): void {
    console.log('aboutToAppear JSBridgeUserService')
  }

  public aboutToDisappear(): void {
    console.log('aboutToDisappear JSBridgeUserService')
  }

  @JSBridgeMethod()
  fun1(entity: H5CallEntity): H5CallbackEntity {
    return {
      code: H5BridgeCode.SUCCESS,
      data: '来自鸿蒙的返回数据'
    }
  }

  @JSBridgeMethod()
  fun2(entity: H5CallEntity): H5CallbackEntity {
    return {
      code: H5BridgeCode.SUCCESS,
      methodNameListForJsProxy: ['testFun'],
      testFun: (str: string) => {
        console.log('执行鸿蒙侧提供的回调函数，参数：' + str)
      },
      other: {
        name: '其他任意非函数的对象'
      }
    }
  }

  @JSBridgeMethod()
  fun3(entity: H5CallEntity): H5CallbackEntity {
    entity.args('来自鸿蒙侧的参数')
    return {
      code: H5BridgeCode.SUCCESS,
      data: '来自鸿蒙的返回数据'
    }
  }

  @JSBridgeMethod()
  async asyncfun1(entity: H5CallEntity): Promise<H5CallbackEntity> {
    return new Promise((r, e) => {
      r({
        code: H5BridgeCode.SUCCESS,
        data: '来自鸿蒙的返回数据'
      })
    })
  }

  @JSBridgeMethod()
  asyncfun2(entity: H5CallEntity): Promise<H5CallbackEntity> {
    return new Promise((r, e) => {
      r({
        code: H5BridgeCode.SUCCESS,
        data: '来自鸿蒙的返回数据',
        methodNameListForJsProxy: ['testFun'],
        testFun: (str: string) => {
          console.log('执行鸿蒙侧提供的回调函数,参数：' + str)
        },
        other: {
          name: '其他任意非函数的对象'
        }
      })
    })
  }

}