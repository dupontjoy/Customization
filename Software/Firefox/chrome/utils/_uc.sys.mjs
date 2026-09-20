
'use strict';

const { Services } = globalThis;
const { AppConstants } = ChromeUtils.importESModule('resource://gre/modules/AppConstants.sys.mjs');
const { everLoaded } = ChromeUtils.importESModule('chrome://userchromejs/content/utils/UcScriptRuntime.sys.mjs');
let CUI;
try {
    ({ CustomizableUI: CUI } = ChromeUtils.importESModule('moz-src:///browser/components/customizableui/CustomizableUI.sys.mjs'));
} catch (ex) {
    ({ CustomizableUI: CUI } = ChromeUtils.importESModule('resource:///modules/CustomizableUI.sys.mjs'));
}
const { console } = Cu.getGlobalForObject(Services);
const duplicateWarnings = new Set();

function getLoader(preferredWindow) {
    if (preferredWindow?.userChrome_js) {
        return preferredWindow.userChrome_js;
    }
    const windows = Services.wm.getEnumerator(null);
    while (windows.hasMoreElements()) {
        const win = windows.getNext();
        if (win.userChrome_js) {
            return win.userChrome_js;
        }
        try {
            const frames = win.docShell.getAllDocShellsInSubtree(
                Ci.nsIDocShellTreeItem.typeAll,
                Ci.nsIDocShell.ENUMERATE_FORWARDS
            );
            const frameWindow = frames.map(frame => frame.domWindow).find(frameWin => frameWin?.userChrome_js);
            if (frameWindow) {
                return frameWindow.userChrome_js;
            }
        } catch (e) { }
    }
    return null;
}

function exposeScript(script) {
    if (!Object.getOwnPropertyDescriptor(script, 'isEnabled')) {
        Object.defineProperty(script, 'isEnabled', {
            configurable: true,
            enumerable: true,
            get() {
                const loader = getLoader();
                if (loader?.isScriptEnabled) {
                    return loader.isScriptEnabled(this);
                }
                const disabled = unescape(Services.prefs.getStringPref('userChrome.disable.script', ''))
                    .split(',')
                    .filter(Boolean)
                    .map(unescape);
                return !disabled.includes(this.filename);
            },
        });
    }
    return script;
}

export const _uc = {
    APPNAME: AppConstants.MOZ_APP_NAME,
    ALWAYSEXECUTE: 'rebuild_userChrome.uc.js',
    BROWSERCHROME: AppConstants.MOZ_APP_NAME == 'thunderbird' ? 'chrome://messenger/content/messenger.xhtml' : 'chrome://browser/content/browser.xhtml',
    BROWSERTYPE: AppConstants.MOZ_APP_NAME == 'thunderbird' ? 'mail:3pane' : 'navigator:browser',
    BROWSERNAME: AppConstants.MOZ_APP_NAME.charAt(0).toUpperCase() + AppConstants.MOZ_APP_NAME.slice(1),
    PREF_SCRIPTSDISABLED: 'userChrome.disable.script',
    sss: Cc["@mozilla.org/content/style-sheet-service;1"].getService(Ci.nsIStyleSheetService),
    chromedir: Services.dirsvc.get('UChrm', Ci.nsIFile),
    scriptsDir: '',
    everLoaded,

    get scripts () {
        const loader = getLoader();
        const scripts = Object.create(null);
        for (const script of loader?.scripts || []) {
            if (!/\.uc\.js$/i.test(script.filename)) {
                continue;
            }
            if (scripts[script.filename]) {
                if (!duplicateWarnings.has(script.filename)) {
                    duplicateWarnings.add(script.filename);
                    console.warn(`duplicate userChrome script filename ignored by _uc compatibility API: ${script.filename}`);
                }
                continue;
            }
            scripts[script.filename] = exposeScript(script);
        }
        return scripts;
    },

    get isFaked () {
        return true;
    },

    get isESM () {
        return true;
    },

    getScripts: function () {
        const loader = getLoader();
        if (!loader) {
            return this.scripts;
        }
        loader.getScripts();
        for (const win of loader.getScriptWindows()) {
            const targetLoader = win.userChrome_js;
            if (!targetLoader || targetLoader === loader) {
                continue;
            }
            targetLoader.scripts = loader.scripts;
            targetLoader.overlays = loader.overlays;
            targetLoader.directory = loader.directory;
            targetLoader._parseScriptData = loader._parseScriptData;
            targetLoader._readScriptFile = loader._readScriptFile;
            targetLoader.refreshDisabledState();
        }
        return this.scripts;
    },

    getScriptData: function (file) {
        const loader = getLoader();
        if (!loader) {
            throw new Error('userChrome.js loader is not initialized');
        }
        return exposeScript(loader.getScriptData(file));
    },

    readFile: function (file, metaOnly = false) {
        const loader = getLoader();
        if (!loader) {
            throw new Error('userChrome.js loader is not initialized');
        }
        return loader.readFile(file, metaOnly);
    },

    loadScript: function (script, win) {
        const loader = getLoader(win);
        return !!loader?.loadScript(script, win);
    },

    windows: function (fun, onlyBrowsers = true) {
        let windows = Services.wm.getEnumerator(onlyBrowsers ? this.BROWSERTYPE : null);
        while (windows.hasMoreElements()) {
            let win = windows.getNext();
            if (!win._uc)
                continue;
            if (!onlyBrowsers) {
                let frames = win.docShell.getAllDocShellsInSubtree(Ci.nsIDocShellTreeItem.typeAll, Ci.nsIDocShell.ENUMERATE_FORWARDS);
                let res = frames.some(frame => {
                    let fWin = frame.domWindow;
                    let { document, location } = fWin;
                    if (fun(document, fWin, location))
                        return true;
                });
                if (res)
                    break;
            } else {
                let { document, location } = win;
                if (fun(document, win, location))
                    break;
            }
        }
    },

    createElement: function (doc, tag, atts, XUL = true) {
        let el = XUL ? doc.createXULElement(tag) : doc.createElement(tag);
        for (let att in atts) {
            if (att.startsWith('on')) {
                if (typeof atts[att] == 'function') {
                    el.addEventListener(att.slice(2), atts[att]);
                } else {
                    console.warn(`attribute ${att} is not a function`);
                }
            } else {
                el.setAttribute(att, atts[att]);
            }
        }
        return el
    },

    createWidget: function (desc) {
        if (!desc || !desc.id) {
            throw new Error("custom widget description is missing 'id' property");
        }
        if (!(desc.type === "toolbarbutton" || desc.type === "toolbaritem")) {
            throw new Error(`custom widget has unsupported type: '${desc.type}'`);
        }
        if (CUI.getWidget(desc.id)?.hasOwnProperty("source")) {
            // very likely means that the widget with this id already exists
            // There isn't a very reliable way to 'really' check if it exists or not
            throw new Error(`Widget with ID: '${desc.id}' already exists`);
        }
        let itemStyle = "";
        if (desc.image) {
            if (desc.type === "toolbarbutton") {
                itemStyle += "list-style-image:";
            } else {
                itemStyle += "background: transparent center no-repeat ";
            }
            itemStyle += /^chrome:\/\/|resource:\/\//.test(desc.image)
                ? `url(${desc.image});`
                : `url(chrome://userChrome/content/${desc.image});`;
            itemStyle += desc.style || "";
        }
        const callback = desc.callback;
        if (typeof callback === "function") {
            SharedGlobal.widgetCallbacks.set(desc.id, callback);
        }
        return CUI.createWidget({
            id: desc.id,
            type: 'custom',
            defaultArea: desc.area || CUI.AREA_NAVBAR,
            onBuild: function (aDocument) {
                let toolbaritem = aDocument.createXULElement(desc.type);
                let props = {
                    id: desc.id,
                    class: `toolbarbutton-1 chromeclass-toolbar-additional ${desc.class ? desc.class : ""}`,
                    overflows: !!desc.overflows,
                    label: desc.label || desc.id,
                    tooltiptext: desc.tooltip || desc.id,
                    style: itemStyle
                };
                for (let p in props) {
                    toolbaritem.setAttribute(p, props[p]);
                }

                if (typeof callback === "function") {
                    const allEvents = !!desc.allEvents;
                    toolbaritem.addEventListener("click", (ev) => {
                        const targetWin = ev.target.documentGlobal || ev.target.relevantGlobal || ev.target.ownerDocument?.defaultView;
                        allEvents || ev.button === 0 && SharedGlobal.widgetCallbacks.get(ev.target.id)(ev, targetWin)
                    })
                }
                for (let attr in desc) {
                    if (attr != "callback" && !(attr in props)) {
                        toolbaritem.setAttribute(attr, desc[attr])
                    }
                }
                return toolbaritem;
            }
        });
    }
}
