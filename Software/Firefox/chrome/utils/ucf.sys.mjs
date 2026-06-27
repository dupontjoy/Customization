export { initUloadMap, setUnloadMap, getUnloadMaps }

const handler = {

}

function initUloadMap (win) {
    handler.window = win
    handler.unloadMap = new Map();
    win.addEventListener("unload", () => {
        for (const [key, value] of handler.unloadMap) {
            try {
                value.func?.call(value.context, key);
            } catch (e) {
                Cu.reportError(e);
            }
        }
        handler.unloadMap.clear();
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
