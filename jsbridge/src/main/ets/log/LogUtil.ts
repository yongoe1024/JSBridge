import hilog from '@ohos.hilog';

/**
 * ArkTS Hilog 日志工具类
 */
const DOMAIN: number = 0x0000;
const TAG: string = 'jsbrdge';

export class LogUtil {
  /**
   * 调试级日志（DEBUG）- 开发调试用，生产环境可关闭
   * @param message 日志内容
   * @param params 可变参数（可选，用于格式化日志内容）
   */
  public static debug(message: string, ...params: any[]): void {
    hilog.debug(DOMAIN, TAG, message, params);
  }

  /**
   * 信息级日志（INFO）- 输出关键业务信息（如初始化完成、用户操作）
   * @param message 日志内容
   * @param params 可变参数（可选）
   */
  public static info(message: string, ...params: any[]): void {
    hilog.info(DOMAIN, TAG, message, params);
  }

  /**
   * 警告级日志（WARN）- 输出潜在风险（如参数异常、接口超时重试）
   * @param message 日志内容
   * @param params 可变参数（可选）
   */
  public static warn(message: string, ...params: any[]): void {
    hilog.warn(DOMAIN, TAG, message, params);
  }

  /**
   * 错误级日志（ERROR）- 输出严重错误（如接口调用失败、崩溃前兆）
   * @param message 日志内容
   * @param params 可变参数（可选）
   */
  public static error(message: string, ...params: any[]): void {
    // 错误日志建议强制输出（即使关闭调试，也需保留错误追踪）
    hilog.error(DOMAIN, TAG, message, params);
  }

}