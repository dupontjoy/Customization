'use strict';

const SHARED_ACTOR_NAME = 'UcSharedActor';
const SHARED_PARENT_URI = 'chrome://userchromejs/content/utils/UcSharedActorParent.sys.mjs';
const SHARED_CHILD_URI = 'chrome://userchromejs/content/utils/UcSharedActorChild.sys.mjs';

const sharedScripts = new Map();
const registeredActorNames = new Set();
const chromeWindowIds = new WeakMap();
const sharedChromeHandlers = new Map();
let nextChromeWindowId = 1;

function ensureChromeWindowId(win) {
    let id = chromeWindowIds.get(win);
    if (id) {
        return id;
    }
    id = nextChromeWindowId++;
    chromeWindowIds.set(win, id);
    win.addEventListener('unload', () => {
        for (const handlers of sharedChromeHandlers.values()) {
            handlers.delete(id);
        }
    }, { once: true });
    return id;
}

function cloneEvents(events = {}) {
    return Object.fromEntries(Object.entries(events).map(([name, options]) => [name, { ...options }]));
}

function registerChromeWindow(win) {
    return ensureChromeWindowId(win);
}

function registerSharedScript(scriptDef) {
    if (!scriptDef?.id || !scriptDef.moduleURI) {
        return false;
    }
    sharedScripts.set(scriptDef.id, {
        id: scriptDef.id,
        moduleURI: scriptDef.moduleURI,
        exportedModule: scriptDef.exportedModule || '',
        matches: Array.isArray(scriptDef.matches) ? [...scriptDef.matches] : [],
        messageManagerGroups: Array.isArray(scriptDef.messageManagerGroups) ? [...scriptDef.messageManagerGroups] : [],
        events: cloneEvents(scriptDef.events),
        allFrames: scriptDef.allFrames !== false,
        sandbox: !!scriptDef.sandbox,
    });
    return true;
}

function getSharedScripts() {
    return Array.from(sharedScripts.values(), script => ({
        ...script,
        matches: [...script.matches],
        messageManagerGroups: [...script.messageManagerGroups],
        events: cloneEvents(script.events),
    }));
}

function getSharedActorOptions() {
    const events = {};
    const matches = new Set();
    const groups = new Set();
    let allFrames = false;

    for (const script of sharedScripts.values()) {
        allFrames ||= script.allFrames !== false;
        for (const [name, options] of Object.entries(script.events || {})) {
            events[name] = { ...options };
        }
        for (const match of script.matches || []) {
            matches.add(match);
        }
        for (const group of script.messageManagerGroups || []) {
            groups.add(group);
        }
    }

    if (Object.keys(events).length === 0) {
        events.DOMContentLoaded = {};
    }

    const options = {
        parent: {
            esModuleURI: SHARED_PARENT_URI,
        },
        child: {
            esModuleURI: SHARED_CHILD_URI,
            events,
        },
        allFrames,
    };

    if (matches.size) {
        options.matches = Array.from(matches);
    }
    if (groups.size) {
        options.messageManagerGroups = Array.from(groups);
    }

    return options;
}

function hasActorRegistration(name) {
    return registeredActorNames.has(name);
}

function markActorRegistered(name) {
    if (!name || registeredActorNames.has(name)) {
        return false;
    }
    registeredActorNames.add(name);
    return true;
}

function registerSharedChromeHandler(win, scriptId, handler) {
    if (!scriptId || typeof handler !== 'function') {
        return false;
    }
    const id = ensureChromeWindowId(win);
    let handlers = sharedChromeHandlers.get(scriptId);
    if (!handlers) {
        handlers = new Map();
        sharedChromeHandlers.set(scriptId, handlers);
    }
    handlers.set(id, handler);
    return true;
}

function dispatchSharedMessageToChrome(win, scriptId, payload) {
    const handlers = sharedChromeHandlers.get(scriptId);
    if (!handlers) {
        return false;
    }
    const id = ensureChromeWindowId(win);
    const handler = handlers.get(id);
    if (typeof handler !== 'function') {
        return false;
    }
    try {
        handler(payload);
        return true;
    } catch (ex) {
        Cu.reportError(ex);
        return false;
    }
}

export {
    SHARED_ACTOR_NAME,
    dispatchSharedMessageToChrome,
    getSharedActorOptions,
    getSharedScripts,
    hasActorRegistration,
    markActorRegistered,
    registerChromeWindow,
    registerSharedChromeHandler,
    registerSharedScript,
};
