
'use strict';

const { Services } = globalThis;
const { AppConstants } = ChromeUtils.importESModule('resource://gre/modules/AppConstants.sys.mjs');
const { CustomizableUI: CUI } = ChromeUtils.importESModule('resource:///modules/CustomizableUI.sys.mjs');
const { console } = Cu.getGlobalForObject(Services);
export const _uc = {
    APPNAME: AppConstants.MOZ_APP_NAME,
    BROWSERCHROME: AppConstants.MOZ_APP_NAME == 'thunderbird' ? 'chrome://messenger/content/messenger.xhtml' : 'chrome://browser/content/browser.xhtml',
    BROWSERTYPE: AppConstants.MOZ_APP_NAME == 'thunderbird' ? 'mail:3pane' : 'navigator:browser',
    BROWSERNAME: AppConstants.MOZ_APP_NAME.charAt(0).toUpperCase() + AppConstants.MOZ_APP_NAME.slice(1),
    sss: Cc["@mozilla.org/content/style-sheet-service;1"].getService(Ci.nsIStyleSheetService),
    chromedir: Services.dirsvc.get('UChrm', Ci.nsIFile),
    scriptsDir: '',

    get isFaked() {
        return true;
    },

    get isESM() {
        return true;
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
                        allEvents || ev.button === 0 && SharedGlobal.widgetCallbacks.get(ev.target.id)(ev, ev.target.ownerGlobal)
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