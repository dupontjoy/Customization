'use strict';

const scriptStates = new Map();
const everLoadedKeys = new Set();
const everLoaded = [];
const windowSandboxes = new WeakMap();

function getScriptId(scriptOrId) {
    if (typeof scriptOrId === 'string') {
        return scriptOrId;
    }
    if (!scriptOrId?.filename) {
        return '';
    }
    return scriptOrId.scriptId || `${scriptOrId.dir || 'root'}/${scriptOrId.filename}`;
}

function ensureState(scriptOrId) {
    const scriptId = getScriptId(scriptOrId);
    if (!scriptId) {
        return null;
    }
    let state = scriptStates.get(scriptId);
    if (!state) {
        state = {
            globalRunning: false,
            onlyonce: !!scriptOrId?.onlyonce,
            windows: new Set(),
        };
        scriptStates.set(scriptId, state);
    } else if (typeof scriptOrId === 'object') {
        state.onlyonce = !!scriptOrId.onlyonce;
    }
    return state;
}

function isScriptRunning(scriptOrId) {
    const state = scriptStates.get(getScriptId(scriptOrId));
    return !!state && (state.globalRunning || state.windows.size > 0);
}

function registerScript(script) {
    const scriptId = getScriptId(script);
    if (!scriptId) {
        return '';
    }
    script.scriptId = scriptId;
    ensureState(script);

    const descriptor = Object.getOwnPropertyDescriptor(script, 'isRunning');
    if (!descriptor?.get) {
        Object.defineProperty(script, 'isRunning', {
            configurable: true,
            enumerable: true,
            get() {
                return isScriptRunning(scriptId);
            },
            set(value) {
                if (value === false) {
                    clearScriptRunning(scriptId);
                }
            },
        });
    }
    return scriptId;
}

function markScriptRunning(script, win) {
    const scriptId = registerScript(script);
    const state = ensureState(script);
    if (!state) {
        return false;
    }
    if (state.onlyonce) {
        state.globalRunning = true;
    }
    if (win) {
        state.windows.add(win);
    }
    return isScriptRunning(scriptId);
}

function markScriptStopped(scriptOrId, win) {
    const scriptId = getScriptId(scriptOrId);
    const state = scriptStates.get(scriptId);
    if (!state) {
        return false;
    }
    if (state.onlyonce || !win) {
        state.globalRunning = false;
        state.windows.clear();
    } else {
        state.windows.delete(win);
    }
    return isScriptRunning(scriptId);
}

function clearScriptRunning(scriptOrId) {
    return markScriptStopped(scriptOrId, null);
}

function forgetWindow(win) {
    if (!win) {
        return;
    }
    for (const state of scriptStates.values()) {
        state.windows.delete(win);
    }
    windowSandboxes.delete(win);
}

function getRunningWindows(scriptOrId) {
    const state = scriptStates.get(getScriptId(scriptOrId));
    if (!state) {
        return [];
    }
    return Array.from(state.windows).filter(win => win && !win.closed);
}

function getWindowSandbox(win) {
    return win ? windowSandboxes.get(win) : undefined;
}

function setWindowSandbox(win, sandbox) {
    if (win && sandbox) {
        windowSandboxes.set(win, sandbox);
    }
    return sandbox;
}

function markEverLoaded(script) {
    const scriptId = getScriptId(script);
    if (!scriptId) {
        return;
    }
    everLoadedKeys.add(scriptId);
    const publicId = script.id || scriptId;
    if (!everLoaded.includes(publicId)) {
        everLoaded.push(publicId);
    }
}

function hasEverLoaded(script) {
    const scriptId = getScriptId(script);
    return everLoadedKeys.has(scriptId) || everLoaded.includes(script?.id || scriptId);
}

export {
    clearScriptRunning,
    everLoaded,
    forgetWindow,
    getRunningWindows,
    getScriptId,
    getWindowSandbox,
    hasEverLoaded,
    isScriptRunning,
    markEverLoaded,
    markScriptRunning,
    markScriptStopped,
    registerScript,
    setWindowSandbox,
};
