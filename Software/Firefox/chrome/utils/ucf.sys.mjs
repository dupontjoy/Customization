export { initUloadMap, setUnloadMap, getUnloadMaps }

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

function setUnloadMap(key, func, context) {
    if (!handler.unloadMap) {
        return;
    }
    handler.unloadMap.set(key, { func, context });
}

function getUnloadMaps() {
    return handler.unloadMap;
}