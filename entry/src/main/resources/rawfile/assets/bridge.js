/**
 * JSBridge 演示页共享脚本：调用封装 + 结果展示工具。
 * 由 index/sync/callback/async 各页通过 <script src="assets/bridge.js"></script> 引入，
 * 各页只需在其后编写本页按钮的薄包装函数。
 */

/**
 * 统一调用封装。
 * @param service 服务名，对应 @JSBridgeService 的入参
 * @param method  方法名，对应 @JSBridgeMethod 暴露的 H5 调用名
 * @param args    调用参数（可选）：普通入参，或供鸿蒙侧回调执行的函数
 * @returns 同步方法返回 H5Result；异步方法返回 Promise<H5Result>
 */
function call(service, method, args) {
    return App.callNative({
        service: service,
        method: method,
        args: args
    });
}

// 把返回值安全序列化为可读文本；函数字段统一显示为 [Function]。
function formatValue(value) {
    if (typeof value === 'string') {
        return value
    }
    if (typeof value === 'function') {
        return '[Function]';
    }
    try {
        return JSON.stringify(value, function (key, val) {
            if (typeof val === 'function') {
                return '[Function]';
            }
            return val;
        }, 2);
    } catch (error) {
        return String(value);
    }
}

// 把结果写入页面底部的结果面板。
function showResult(value) {
    var resultEl = document.getElementById('result');
    if (resultEl) {
        resultEl.textContent = formatValue(value) + '\n' + resultEl.textContent
    }
}

// 重置结果面板。
function clearResult() {
    var resultEl = document.getElementById('result');
    if (resultEl) {
        resultEl.textContent = '等待操作...';
    }
}
