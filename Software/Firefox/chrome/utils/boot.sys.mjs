
'use strict';

const { Services } = globalThis;
const { Management } = ChromeUtils.importESModule('resource://gre/modules/Extension.sys.mjs');

const { initUloadMap, setUnloadMap, getUnloadMaps } = ChromeUtils.importESModule("chrome://userchromejs/content/utils/ucf.sys.mjs")

const UC = {
    webExts: new Map(),
    sidebar: new Map()
}

try {
    const getNodeWindow = node =>
        node?.documentGlobal || node?.relevantGlobal || node?.ownerDocument?.defaultView || null;

    const getBrowserChromeWindow = win =>
        win?.browsingContext?.embedderWindowGlobal?.browsingContext?.window ||
        win?.windowRoot?.relevantGlobal ||
        win;

    function UserChrome_js () {
        Services.obs.addObserver(this, 'domwindowopened', false);
        Services.obs.addObserver(this, 'chrome-document-global-created', false);
    };

    UserChrome_js.prototype = {
        injectWindowGlobals: function (window) {
            if (!window || window.__ucGlobalsInjected)
                return;

            initUloadMap(window);

            Cu.exportFunction((key, func, context) => {
                setUnloadMap(key, func, context);
            }, window, { defineAs: "setUnloadMap" });

            Cu.exportFunction(() => {
                return getUnloadMaps();
            }, window, { defineAs: "getUnloadMaps" });

            ChromeUtils.defineLazyGetter(window, "xPref", () =>
                ChromeUtils.importESModule("chrome://userchromejs/content/utils/xPref.sys.mjs").xPref
            );

            if (!("UC_API" in window)) {
                ChromeUtils.defineLazyGetter(window, "UC_API", () =>
                    ChromeUtils.importESModule("chrome://userchromejs/content/utils/UcCompatApi.sys.mjs").UC_API
                );
            }

            window.UC = UC;

            ChromeUtils.defineLazyGetter(window, "_uc", () =>
                ChromeUtils.importESModule("chrome://userchromejs/content/utils/_uc.sys.mjs")._uc
            );

            window.__ucGlobalsInjected = true;
        },

        observe: function (aSubject, aTopic, aData) {
            if (aTopic == 'chrome-document-global-created') {
                // Some chrome documents execute inline scripts before the window load event.
                // Inject loader globals here so helper pages can use them immediately.
                this.injectWindowGlobals(aSubject);
                return;
            }

            aSubject.addEventListener('load', this, true);
        },

        messageListener: {
            receiveMessage: function (msg) {
                const browser = msg.target;
                const { addonId } = browser._contentPrincipal;

                browser.messageManager.removeMessageListener('Extension:BackgroundViewLoaded', this);

                const browserWin = getNodeWindow(browser);
                if (browserWin.location.href == 'chrome://extensions/content/dummy.xhtml') {
                    UC.webExts.set(addonId, browser);
                    Services.obs.notifyObservers(null, 'UCJS:WebExtLoaded', addonId);
                } else {
                    let win = getBrowserChromeWindow(browserWin);
                    UC.sidebar.get(addonId)?.set(win, browser) || UC.sidebar.set(addonId, new Map([[win, browser]]));
                    Services.obs.notifyObservers(win, 'UCJS:SidebarLoaded', addonId);
                }
            },
        },

        handleEvent: function (aEvent) {
            let document = aEvent.originalTarget;
            let window = document.defaultView;
            let { location } = window;
            if (location && location.protocol == 'chrome:') {
                const ds = Cc["@mozilla.org/file/directory_service;1"].getService(Ci.nsIProperties);

                if (!this.sharedWindowOpened && location.href == 'chrome://extensions/content/dummy.xhtml') {
                    this.sharedWindowOpened = true;

                    Management.on('extension-browser-inserted', function (topic, browser) {
                        browser.messageManager.addMessageListener('Extension:BackgroundViewLoaded', this.messageListener);
                    }.bind(this));
                    return;
                }

                this.injectWindowGlobals(window);

                if (window._gBrowser) // bug 1443849
                    window.gBrowser = window._gBrowser;

                let file = ds.get("UChrm", Ci.nsIFile);
                file.append('userChrome.js');
                let scriptURL = `chrome://userchromejs/content/userChrome.js?${file.lastModifiedTime}`;
                Services.scriptloader.loadSubScript(scriptURL, document.defaultView, 'UTF-8');
            }
        },
    };

    if (!Cc['@mozilla.org/xre/app-info;1'].getService(Ci.nsIXULRuntime).inSafeMode)
        new UserChrome_js();

} catch (ex) { Cu.reportError(ex); };

try {
    pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
} catch (e) { }
