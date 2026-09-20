export { initUloadMap, setUnloadMap, getUnloadMaps }

const unloadMaps = new WeakMap();
const initializedWindows = new WeakSet();

function initUloadMap (win) {
    if (!win) {
        return null;
    }
    let unloadMap = unloadMaps.get(win);
    if (!unloadMap) {
        unloadMap = new Map();
        unloadMaps.set(win, unloadMap);
    }
    if (initializedWindows.has(win)) {
        return unloadMap;
    }
    initializedWindows.add(win);
    win.addEventListener("unload", () => {
        const entries = Array.from(unloadMap);
        unloadMap.clear();
        unloadMaps.delete(win);
        for (const [key, value] of entries) {
            try {
                value.func?.call(value.context, key);
            } catch (e) {
                Cu.reportError(e);
            }
        }
    }, { once: true })
    return unloadMap;
}

function setUnloadMap(win, key, func, context) {
    const unloadMap = initUloadMap(win);
    if (!unloadMap) {
        return;
    }
    unloadMap.set(key, { func, context });
}

function getUnloadMaps(win) {
    return initUloadMap(win);
}
