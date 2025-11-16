import {
  BaseJSBridgeService,
  H5BridgeCode,
  H5CallbackEntity,
  H5CallEntity,
  JSBridgeMethod,
  JSBridgeService
} from "jsbridge"

@JSBridgeService('JSBridgeUserService')
export class JSBridgeUserService extends BaseJSBridgeService {
  public aboutToAppear(): void {
    console.log('首次加载')
  }

  public aboutToDisappear(): void {
    console.log('卸载')
  }

  @JSBridgeMethod()
  getName(entity: H5CallEntity): H5CallbackEntity {
    return {
      code: H5BridgeCode.SUCCESS,
      data: '张三'
    }
  }

  @JSBridgeMethod()
  login(entity: H5CallEntity): Promise<H5CallbackEntity> {
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        resolve({
          code: H5BridgeCode.SUCCESS,
          data: ()=>{
            console.log('鸿蒙log')
          }
        })
      }, 2000)
    })
  }

  @JSBridgeMethod()
  callback(entity: H5CallEntity): H5CallbackEntity {
    entity.args.fun('入参')
    return {
      code: H5BridgeCode.SUCCESS
    }
  }
}