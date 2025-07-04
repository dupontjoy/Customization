
'use strict';

const { Services } = globalThis;
const { Management } = ChromeUtils.importESModule('resource://gre/modules/Extension.sys.mjs');

const { initUloadMap, setUnloadMap, getUnloadMaps } = ChromeUtils.importESModule("chrome://userchromejs/content/utils/ucf.sys.mjs")

const UC = {
    webExts: new Map(),
    sidebar: new Map()
}

try {
    function UserChrome_js () {
        Services.obs.addObserver(this, 'domwindowopened', false);
    };

    UserChrome_js.prototype = {
        observe: function (aSubject, aTopic, aData) {
            aSubject.addEventListener('load', this, true);
        },

        messageListener: function (msg) {
            const browser = msg.target;
            const { addonId } = browser._contentPrincipal;

            browser.messageManager.removeMessageListener('Extension:ExtensionViewLoaded', this.messageListener);

            if (browser.ownerGlobal.location.href == 'chrome://extensions/content/dummy.xhtml') {
                UC.webExts.set(addonId, browser);
                Services.obs.notifyObservers(null, 'UCJS:WebExtLoaded', addonId);
            } else {
                let win = browser.ownerGlobal.windowRoot.ownerGlobal;
                UC.sidebar.get(addonId)?.set(win, browser) || UC.sidebar.set(addonId, new Map([[win, browser]]));
                Services.obs.notifyObservers(win, 'UCJS:SidebarLoaded', addonId);
            }
        },

        handleEvent: function (aEvent) {
            let document = aEvent.originalTarget;
            let window = document.defaultView;
            let { location } = window;
            if (location && location.protocol == 'chrome:') {
                const ios = Cc["@mozilla.org/network/io-service;1"].getService(Ci.nsIIOService);
                const fph = ios.getProtocolHandler("file").QueryInterface(Ci.nsIFileProtocolHandler);
                const ds = Cc["@mozilla.org/file/directory_service;1"].getService(Ci.nsIProperties);

                if (!this.sharedWindowOpened && location.href == 'chrome://extensions/content/dummy.xhtml') {
                    this.sharedWindowOpened = true;

                    Management.on('extension-browser-inserted', function (topic, browser) {
                        browser.messageManager.addMessageListener('Extension:ExtensionViewLoaded', this.messageListener.bind(this));
                    }.bind(this));
                    return;
                }

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

                window.UC = UC;

                ChromeUtils.defineLazyGetter(window, "_uc", () =>
                    ChromeUtils.importESModule("chrome://userchromejs/content/utils/_uc.sys.mjs")._uc
                );

                if (window._gBrowser) // bug 1443849
                    window.gBrowser = window._gBrowser;

                let file = ds.get("UChrm", Ci.nsIFile);
                file.append('userChrome.js');
                let fileURL = fph
                    .getURLSpecFromActualFile(file) + "?" + file.lastModifiedTime;
                Cc["@mozilla.org/moz/jssubscript-loader;1"].getService(Ci.mozIJSSubScriptLoader)
                    .loadSubScript(fileURL, document.defaultView, 'UTF-8');
            }
        },
    };

    if (!Cc['@mozilla.org/xre/app-info;1'].getService(Ci.nsIXULRuntime).inSafeMode)
        new UserChrome_js();

} catch (ex) { Cu.reportError(ex); };

try {
    pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
} catch (e) { }