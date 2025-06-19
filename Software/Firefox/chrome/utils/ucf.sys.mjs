export { initUloadMap, setUnloadMap }

const handler = {

}

function initUloadMap (win) {
    handler.window = win
    handler.unloadMap = new Map();
    win.addEventListener("unload", () => {
        for (const [key, value] of handler.unloadMap) {
            for (const { func, context } of value) {
                try {
                    func.apply(context);
                } catch (e) {
                    Cu.reportError(e);
                }
            }
        }
    }, { once: true })
}

function setUnloadMap (key, func, context) {
    if (!handler.unloadMap) {
        return;
    }
    key = typeof key === "symbol" ? key : Symbol(key)
    if (!handler.unloadMap.has(key)) {
        Cu.reportError(new Error(`ucf.sys.mjs: setUnloadMap: key ${key} is not a symbol`))
        return;
    }
    handler.unloadMap.set(key, [{ func, context }]);
}