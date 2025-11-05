// ==UserScript==
// @name            DownloadPlus_Fx136.uc.js
// @author          Ryan
// @long-description
// @description
/* 下载增强脚本，修改整合自（w13998686967、ywzhaiqi、黒仪大螃蟹、Alice0775、紫云飞），已重写代码。
相关 about:config 选项 修改后请重启浏览器，不支持热重载
userChromeJS.downloadPlus.enableFlashgotIntergention 启用 Flashgot 集成
userChromeJS.downloadPlus.flashgotPath Flashgot可执行文件路径
FlashGot.exe 下载：https://github.com/benzBrake/Firefox-downloadPlus.uc.js/releases/tag/v2023.05.11
比如 \\chrome\\UserTools\\FlashGot.exe，需要使用\\替代\
userChromeJS.downloadPlus.flashgotDownloadManagers 下载器列表缓存（一般不需要修改)
userChromeJS.downloadPlus.flashgotDefaultManager 默认第三方下载器（一般不需要修改）
userChromeJS.downloadPlus.enableRename 下载对话框启用改名功能
userChromeJS.downloadPlus.enableEncodeConvert 启用编码转换，如果userChromeJS.lus.enableRename没开启，这个选项无效
userChromeJS.downloadPlus.enableDoubleClickToCopyLink 下载对话框双击复制链接
userChromeJS.downloadPlus.enableCopyLinkButton 下载对话框启用复制链接按钮
userChromeJS.downloadPlus.enableDoubleClickToSave 双击保存
userChromeJS.downloadPlus.enableSaveAndOpen 下载对话框启用保存并打开
userChromeJS.downloadPlus.enableSaveAs 下载对话框启用另存为
userChromeJS.downloadPlus.enableSaveTo 下载对话框启用保存到
// @note userChromeJS.downloadPlus.showAllDrives 下载对话框显示所有驱动器
*/
// @note            20251103 修复修改文件名后点击保存不遵循“总是询问保存至何处(A)”设置的问题
// @note            20250827 修复 Fx143 菜单图标的问题
// @note            20250827 修复选择 FlashGot 后点击保存文件无效的问题
// @note            20250826 禁止快速保存后会自动打开文文件，感谢@Cloudy901
// @note            20250802 修复 Fx140 dropmarker 显示异常, 强制弹出下载对话框
// @note            20250620 修复按钮和弹出菜单的一些问题
// @note            20250610 Fx139
// @note            20250509 修复文件名无效字符导致下载失败的问题，简化几处 locationText 的调用
// @note            20250501 修复下载文件改名失效
// @note            20250319 增加复制按钮开关pref，
// @note            20250226 正式进入无 JSM 时代，永久删除文件功能未集成，请使用 removeFileFromDownloadManager.uc.js，下载规则暂时也不支持
// @include         main
// @sandbox         true
// @include         chrome://browser/content/places/places.xhtml
// @include         chrome://mozapps/content/downloads/unknownContentType.xhtml
// @include         chrome://browser/content/downloads/contentAreaDownloadsView.xhtml
// @include         chrome://browser/content/downloads/contentAreaDownloadsView.xhtml?SM
// @include         about:downloads
// @version         1.0.5
// @compatibility   Firefox 139
// @homepageURL     https://github.com/benzBrake/FirefoxCustomize
// ==/UserScript==
(async function (globalCSS, placesCSS, unknownContentCSS) {

    let { classes: Cc, interfaces: Ci, utils: Cu, results: Cr } = Components;
    const Services = globalThis.Services;
    const Downloads = globalThis.Downloads || ChromeUtils.importESModule("resource://gre/modules/Downloads.sys.mjs").Downloads;
    const ctypes = globalThis.ctypes || ChromeUtils.importESModule("resource://gre/modules/ctypes.sys.mjs").ctypes;
    const invalidChars = /[<>:"/\\|?*]/g;

    const LANG = {
        'zh-CN': {
            "download plus btn": "DownloadPlus",
            "download enhance click to switch default download manager": "下载增强，点击可切换默认下载工具",
            "force reload download managers list": "刷新下载工具",
            "reload download managers list finish": "读取FlashGot 支持的下载工具完成，请选择你喜欢的下载工具",
            "download through flashgot": "使用 FlashGot 下载",
            "download by default download manager": "使用默认工具下载",
            "no supported download manager": "没有找到 FlashGot 支持的下载工具",
            "default download manager": "%s（默认）",
            "file not found": "文件不存在：%s",
            "about download plus": "关于 DownloadPlus",
            "original name": "默认编码: ",
            "encoding convert tooltip": "点击转换编码",
            "complete link": "链接：",
            "copy link": "复制链接",
            "copied": "复制完成",
            "dobule click to copy link": "双击复制链接",
            "successly copied": "复制成功",
            "no download managers": "没有下载工具",
            "force reload download managers list": "重新读取下载工具列表",
            "reloading download managers list": "正在重新读取下载工具列表，请稍后！",
            "reload download managers list finish": "读取下载工具列表完成，请选择你喜欢的下载器",
            "set to default download manger": "设置 %s 为默认下载器",
            "save and open": "保存并打开",
            "save as": "另存为",
            "save to": "保存到",
            "desktop": "桌面",
            "downloads folder": "下载",
            "disk %s": "%s 盘",
        },
        format (...args) {
            if (!args.length) {
                throw new Error("format: no arguments");
            }

            const formatString = this.LANGUAGE[args[0]] || args[0];
            const values = args.slice(1);
            let valueIndex = 0;
            let result = "";

            if (typeof formatString !== 'string') {
                throw new Error("format: first argument must be a string");
            }

            if (!values.length) {
                return formatString.charAt(0).toUpperCase() + formatString.slice(1);
            }

            for (let i = 0; i < formatString.length; i++) {
                if (formatString[i] === '%') {
                    i++; // Move to the next character (the format specifier)

                    if (i >= formatString.length) {
                        // Incomplete format specifier at the end, treat as literal '%'
                        result += '%';
                        break;
                    }

                    switch (formatString[i]) {
                        case 's': // String
                            if (valueIndex < values.length) {
                                result += String(values[valueIndex]);
                                valueIndex++;
                            } else {
                                result += '%s'; // Not enough arguments
                            }
                            break;
                        case 'n': // Number
                            if (valueIndex < values.length) {
                                const num = Number(values[valueIndex]);
                                if (isNaN(num)) {
                                    result += 'NaN';
                                } else {
                                    result += num.toString();
                                }
                                valueIndex++;
                            } else {
                                result += '%n'; // Not enough arguments
                            }
                            break;

                        case '%': // Literal '%'
                            result += '%';
                            break;
                        default:
                            // Unknown format specifier - treat as literal characters
                            result += '%' + formatString[i];
                    }
                } else {
                    result += formatString[i];
                }
            }

            while (valueIndex < values.length) {
                result += " " + String(values[valueIndex]);
                valueIndex++;
            }

            return result;
        },
        init () {
            const _LOCALE = LANG.hasOwnProperty(Services.locale.appLocaleAsBCP47) ? Services.locale.appLocaleAsBCP47 : 'zh-CN';
            if (_LOCALE in this) {
                this.LANGUAGE = this[_LOCALE];
            } else {
                this.LANGUAGE = this['zh-CN'];
            }
        }
    }

    LANG.init();

    const FLASHGOT_OUTPUT_ENCODING = (() => {
        switch (Services.locale.appLocaleAsBCP47) {
            case 'zh-CN': return 'GBK';
            case 'zh-TW':
            case 'zh-HK': return 'BIG5';
            default: return 'UTF-8';
        }
    })();

    const versionGE = (v) => {
        return Services.vc.compare(Services.appinfo.version, v) >= 0;
    }

    const processCSS = (css) => {
        if (versionGE("143a1")) {
            css = `#DownloadPlus-Btn { list-style-image: var(--menuitem-icon); }\n` + css.replaceAll('list-style-image', '--menuitem-icon');
        }
        return css;
    }

    /* Do not change below 不懂不要改下边的 */
    if (window.DownloadPlus) return;

    window.DownloadPlus = {
        debug: false,
        PREF_FLASHGOT_PATH: 'userChromeJS.downloadPlus.flashgotPath',
        PREF_DEFAULT_MANAGER: 'userChromeJS.downloadPlus.flashgotDefaultManager',
        PREF_DOWNLOAD_MANAGERS: 'userChromeJS.downloadPlus.flashgotDownloadManagers',
        SAVE_DIRS: [[Services.dirsvc.get('Desk', Ci.nsIFile).path, LANG.format("desktop")], [
            Services.dirsvc.get('DfltDwnld', Ci.nsIFile).path, LANG.format("downloads folder")
        ]],
        DOWNLOAD_MANAGERS: [],
        DL_FILE_STRUCTURE: `{num};{download-manager};{is-private};;\n{referer}\n{url}\n{description}\n{cookies}\n{post-data}\n{filename}\n{extension}\n{download-page-referer}\n{download-page-cookies}\n\n\n{user-agent}`,
        USERAGENT_OVERRIDES: {},
        REFERER_OVERRIDES: {
            'aliyundrive.net': 'https://www.aliyundrive.com/'
        },
        get FLASHGOT_PATH () {
            delete this.FLASHGOT_PATH;
            let flashgotPref = Services.prefs.getStringPref(this.PREF_FLASHGOT_PATH, "\\chrome\\UserTools\\FlashGot.exe");
            flashgotPref = handlePath(flashgotPref);
            const flashgotFile = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile);
            flashgotFile.initWithPath(flashgotPref);
            return this.FLASHGOT_PATH = flashgotFile.exists() ? flashgotFile.path : false;
        },
        get DEFAULT_MANAGER () {
            return Services.prefs.getStringPref(this.PREF_DEFAULT_MANAGER, '');
        },
        set DEFAULT_MANAGER (value) {
            Services.prefs.setStringPref(this.PREF_DEFAULT_MANAGER, value);
        },
        init: async function () {
            const documentURI = location.href.replace(/\?.*$/, '');
            switch (documentURI) {
                case 'chrome://browser/content/browser.xhtml':
                    windowUtils.loadSheetUsingURIString("data:text/css;charset=utf-8," + encodeURIComponent(processCSS(globalCSS)), windowUtils.AUTHOR_SHEET);
                    await this.initChrome();
                    break;
                case 'about:downloads':
                case 'chrome://browser/content/places/places.xhtml':
                    windowUtils.loadSheetUsingURIString("data:text/css;charset=utf-8," + encodeURIComponent(processCSS(placesCSS)), windowUtils.AUTHOR_SHEET);
                    break;
                case 'chrome://mozapps/content/downloads/unknownContentType.xhtml':
                    windowUtils.loadSheetUsingURIString("data:text/css;charset=utf-8," + encodeURIComponent(processCSS(unknownContentCSS)), windowUtils.AGENT_SHEET);
                    await this.initDownloadPopup();
                    break;
            }
        },
        initChrome: async function () {
            Services.prefs.setBoolPref('browser.download.always_ask_before_handling_new_types', true);
            // 保存按钮无需等待即可点击
            Services.prefs.setIntPref('security.dialog_enable_delay', 0);

            let sb = window.userChrome_js?.sb;
            if (!sb) {
                sb = Cu.Sandbox(window, {
                    sandboxPrototype: window,
                    sameZoneAs: window,
                });

                /* toSource() is not available in sandbox */
                Cu.evalInSandbox(`
          Function.prototype.toSource = window.Function.prototype.toSource;
          Object.defineProperty(Function.prototype, "toSource", {enumerable : false})
          Object.prototype.toSource = window.Object.prototype.toSource;
          Object.defineProperty(Object.prototype, "toSource", {enumerable : false})
          Array.prototype.toSource = window.Array.prototype.toSource;
          Object.defineProperty(Array.prototype, "toSource", {enumerable : false})
      `, sb);
                window.addEventListener("unload", () => {
                    setTimeout(() => {
                        Cu.nukeSandbox(sb);
                    }, 0);
                }, { once: true });
            }
            this.sb = sb;
            if (isTrue('userChromeJS.downloadPlus.enableSaveAndOpen')) {
                this.URLS_FOR_OPEN = [];
                const saveAndOpenView = {
                    onDownloadChanged: function (dl) {
                        if (dl.progress != 100) return;
                        if (window.DownloadPlus.URLS_FOR_OPEN.indexOf(dl.source.url) > -1) {
                            let target = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
                            target.initWithPath(dl.target.path);
                            target.launch();
                            window.DownloadPlus.URLS_FOR_OPEN[window.DownloadPlus.URLS_FOR_OPEN.indexOf(dl.source.url)] = "";
                        }
                    },
                    onDownloadAdded: function (dl) { },
                    onDownloadRemoved: function (dl) { },
                }
                function addDownloadView (list, view) {
                    const result = list.addView(view);
                    if (result && typeof result.then === "function") {
                        result.then(null, Cu.reportError);
                    }
                }
                function removeDownloadView (list, view) {
                    const result = list.removeView(view);
                    if (result && typeof result.then === "function") {
                        result.then(null, Cu.reportError);
                    }
                }
                Downloads.getList(Downloads.ALL).then(list => { addDownloadView(list, saveAndOpenView) });
                window.addEventListener("beforeunload", () => {
                    Downloads.getList(Downloads.ALL).then(list => { removeDownloadView(list, saveAndOpenView) });
                });
            }
            if (isTrue('userChromeJS.downloadPlus.showAllDrives')) {
                getAllDrives().forEach(drive => {
                    this.SAVE_DIRS.push([drive, LANG.format("disk %s", drive.replace(':\\', ""))])
                });
            }
            if (isTrue('userChromeJS.downloadPlus.enableFlashgotIntergention')) {
                if (!this.FLASHGOT_PATH) return; // flashgot.exe not found
                this.reloadSupportedManagers();
                try {
                    CustomizableUI.createWidget({
                        id: 'DownloadPlus-Btn',
                        removable: true,
                        defaultArea: CustomizableUI.AREA_NAVBAR,
                        type: "custom",
                        onBuild: doc => {
                            const btn = createEl(doc, 'toolbarbutton', {
                                id: 'DownloadPlus-Btn',
                                label: LANG.format('download plus btn'),
                                tooltiptext: LANG.format('download enhance click to switch default download manager'),
                                type: 'menu',
                                class: 'toolbarbutton-1 chromeclass-toolbar-additional FlashGot-icon',
                            });
                            btn.appendChild(this.populateMenu(doc, {
                                id: 'DownloadPlus-Btn-Popup',
                            }));
                            btn.addEventListener('mouseover', this, false);
                            return btn;
                        }
                    });
                } catch (e) { }
                const contextMenu = $('#contentAreaContextMenu');
                contextMenu.addEventListener('popupshowing', this, false);
                const downloadPlusMenu = createEl(document, 'menu', {
                    id: 'DownloadPlus-ContextMenu',
                    label: LANG.format("download through flashgot"),
                    class: 'FlashGot-icon menu-iconic',
                    accesskey: 'F',
                    onclick: function (event) {
                        event.target.querySelector("#DownloadPlus-ContextMenuitem")?.doCommand()
                    }
                });
                downloadPlusMenu.appendChild(this.populateMenu(document, {
                    id: 'DownloadPlus-ContextMenu-Popup',
                }));
                contextMenu.insertBefore(downloadPlusMenu, contextMenu.querySelector('#context-media-eme-learnmore ~ menuseparator'));
            }
            this._log("初始化完成");
        },
        initDownloadPopup: async function () {
            this._log("initDownloadPopup 开始");
            const dialogFrame = dialog.dialogElement('unknownContentType');
            // 原有按钮增加 accesskey
            dialogFrame.getButton('accept').setAttribute('accesskey', 'c');
            dialogFrame.getButton('cancel').setAttribute('accesskey', 'x');
            if (isTrue('userChromeJS.downloadPlus.enableRename')) {
                let locationHbox = createEl(document, 'hbox', {
                    id: 'locationHbox',
                    flex: 1,
                    align: 'center',
                });
                let location = $('#location');
                location.hidden = true;
                location.after(locationHbox);
                let locationText = locationHbox.appendChild(createEl(document, "html:input", {
                    id: "locationText",
                    value: dialog.mLauncher.suggestedFileName,
                    flex: 1
                }));


                // 输入不能用于文件名的字符输入框变红
                locationText.addEventListener('input', function (e) {
                    const currentText = this.value;
                    if (currentText.match(invalidChars)) {
                        this.classList.add('invalid');
                    } else {
                        this.classList.remove('invalid');
                    }
                });
                if (isTrue('userChromeJS.downloadPlus.enableEncodeConvert')) {
                    let encodingConvertButton = locationHbox.appendChild(createEl(document, 'button', {
                        id: 'encodingConvertButton',
                        type: 'menu',
                        size: 'small',
                        tooltiptext: LANG.format("encoding convert tooltip")
                    }));
                    let converter = Cc['@mozilla.org/intl/scriptableunicodeconverter']
                        .getService(Ci.nsIScriptableUnicodeConverter);
                    let menupopup = createEl(document, 'menupopup', {
                        position: 'after_end'
                    }), orginalString;
                    menupopup.appendChild(createEl(document, 'menuitem', {
                        value: dialog.mLauncher.suggestedFileName,
                        label: LANG.format("original name") + dialog.mLauncher.suggestedFileName,
                        selected: true,
                        default: true,
                    }));
                    try {
                        orginalString = (opener.localStorage.getItem(dialog.mLauncher.source.spec) ||
                            dialog.mLauncher.source.asciiSpec.substring(dialog.mLauncher.source.asciiSpec.lastIndexOf("/"))).replace(/[\/:*?"<>|]/g, "");
                        opener.localStorage.removeItem(dialog.mLauncher.source.spec)
                    } catch (e) {
                        orginalString = dialog.mLauncher.suggestedFileName;
                    }
                    function createMenuitem (encoding) {
                        converter.charset = encoding;
                        let menuitem = menupopup.appendChild(document.createXULElement("menuitem"));
                        menuitem.value = converter.ConvertToUnicode(orginalString).replace(/^"(.+)"$/, "$1");
                        menuitem.label = encoding + ": " + menuitem.value;
                    }
                    ["GB18030", "BIG5", "Shift-JIS"].forEach(function (item) {
                        createMenuitem(item)
                    });
                    menupopup.addEventListener('click', (event) => {
                        let { target } = event;
                        if (target.localName === "menuitem") {
                            locationText.value = target.value;
                        }
                    });
                    encodingConvertButton.appendChild(menupopup);
                }
            }
            let h = createEl(document, 'hbox', { align: 'center' });
            $("#source").parentNode.after(h);
            // 复制链接
            if (isTrue('userChromeJS.downloadPlus.enableDoubleClickToCopyLink')) {
                let label = h.appendChild(createEl(document, 'label', {
                    innerHTML: LANG.format("complete link"),
                    style: 'margin-top: 1px'
                }));
                let description = h.appendChild(createEl(document, 'description', {
                    id: 'completeLinkDescription',
                    class: 'plain',
                    flex: 1,
                    crop: 'center',
                    value: dialog.mLauncher.source.spec,
                    tooltiptext: LANG.format("dobule click to copy link"),
                }));
                [label, description].forEach(el => el.addEventListener("dblclick", () => {
                    copyText(dialog.mLauncher.source.spec);
                }));
            }
            if (isTrue('userChromeJS.downloadPlus.enableCopyLinkButton')) {
                h.appendChild(createEl(document, 'button', {
                    id: 'copy-link-btn',
                    label: LANG.format("copy link"),
                    size: 'small',
                    onclick: function () {
                        copyText(dialog.mLauncher.source.spec);
                        this.setAttribute("label", LANG.format("copied"));
                        this.parentNode.classList.add("copied");
                        setTimeout(function () {
                            this.setAttribute("label", LANG.format("copy link"));
                            this.parentNode.classList.remove("copied");
                        }.bind(this), 1000);
                    }
                }));
            }
            // 双击保存
            if (isTrue('userChromeJS.downloadPlus.enableDoubleClickToSave')) {
                $('#save').addEventListener('dblclick', (event) => {
                    const { dialog } = event.target.ownerGlobal;
                    dialog.dialogElement('unknownContentType').getButton("accept").click();
                });
            }
            // 调用 FlashGot
            if (isTrue('userChromeJS.downloadPlus.enableFlashgotIntergention')) {
                const bw = Services.wm.getMostRecentWindow("navigator:browser");
                const { DownloadPlus: fdp } = bw;
                if (fdp.FLASHGOT_PATH, fdp.DOWNLOAD_MANAGERS.length) {
                    const createElem = (tag, attrs, children = []) => {
                        let elem = createEl(document, tag, attrs);
                        children.forEach(child => elem.appendChild(child));
                        return elem;
                    };

                    const triggerDownload = _ => {
                        const { mLauncher, mContext } = dialog;
                        let { source } = mLauncher;
                        if (source.schemeIs('blob')) {
                            source = Services.io.newURI(source.spec.slice(5));
                        }
                        let mSourceContext = mContext.BrowsingContext.get(mLauncher.browsingContextId);
                        fdp.downloadByManager($('#flashgotHandler').getAttribute('manager'), source.spec, {
                            fileName: $("#locationText")?.value?.replace(invalidChars, '_') || dialog.mLauncher.suggestedFileName,
                            mLauncher,
                            mSourceContext: mSourceContext.parent ? mSourceContext.parent : mSourceContext,
                            isPrivate: bw.PrivateBrowsingUtils.isWindowPrivate(window)
                        })
                        close();
                    };

                    // 创建 FlashGot 选项
                    let flashgotHbox = createElem('hbox', { id: 'flashgotBox' }, [
                        createElem('radio', {
                            id: 'flashgotRadio', label: LANG.format("download through flashgot"), accesskey: 'F',
                            ondblclick: () => {
                                triggerDownload();
                            }
                        }),
                        createElem('deck', { id: 'flashgotDeck', flex: 1 }, [
                            createElem('hbox', { flex: 1, align: 'center' }, [
                                createElem('menulist', { id: 'flashgotHandler', label: LANG.format('default download manager', fdp.DEFAULT_MANAGER), manager: fdp.DEFAULT_MANAGER, flex: 1, native: true }, [
                                    (() => {
                                        let menupopup = createEl(document, 'menupopup', {
                                            id: 'DownloadPlus-Flashgot-Handler-Popup',
                                        });
                                        menupopup.addEventListener('popupshowing', this, false);
                                        return menupopup;
                                    })()
                                ]),
                                createElem('toolbarbutton', {
                                    id: 'Flashgot-Download-By-Default-Manager',
                                    tooltiptext: LANG.format("download through flashgot"),
                                    class: "toolbarbutton-1",
                                    accesskey: "D",
                                    image: 'chrome://browser/skin/downloads/downloads.svg',
                                    oncommand: () => {
                                        $('#flashgotRadio').click();
                                        triggerDownload();
                                    }
                                })
                            ])
                        ])
                    ]);

                    $('#mode').addEventListener("select", (event) => {
                        const flashGotRadio = $('#flashgotRadio');
                        const rememberChoice = $('#rememberChoice');
                        if (flashGotRadio && flashGotRadio.selected) {
                            rememberChoice.disabled = true;
                            rememberChoice.checked = false;
                            other = false;
                        } else {
                            rememberChoice.disabled = false;
                        }
                    });

                    $('#mode').appendChild(flashgotHbox);
                }
            }
            // 保存并打开
            if (isTrue('userChromeJS.downloadPlus.enableSaveAndOpen')) {
                let saveAndOpen = createEl(document, 'button', {
                    id: 'save-and-open',
                    label: LANG.format("save and open"),
                    accesskey: 'P',
                    size: 'small',
                    part: 'dialog-button'
                });
                saveAndOpen.addEventListener('click', () => {
                    Services.wm.getMostRecentWindow("navigator:browser").DownloadPlus.URLS_FOR_OPEN.push(dialog.mLauncher.source.asciiSpec);
                    dialog.dialogElement('save').click();
                    dialogFrame.getButton("accept").disabled = 0;
                    dialogFrame.getButton("accept").click();
                });
                dialogFrame.getButton('extra2').before(saveAndOpen);
            }
            // 另存为
            if (isTrue('userChromeJS.downloadPlus.enableSaveAs')) {
                let saveAs = createEl(document, 'button', {
                    id: 'save-as',
                    label: LANG.format("save as"),
                    accesskey: 'E',
                    oncommand: function () {
                        const mainwin = Services.wm.getMostRecentWindow("navigator:browser");
                        // 感谢 ycls006 / alice0775
                        Cu.evalInSandbox("(" + mainwin.internalSave.toString().replace("let ", "").replace("var fpParams", "fileInfo.fileExt=null;fileInfo.fileName=aDefaultFileName;var fpParams") + ")", mainwin.DownloadPlus.sb)(dialog.mLauncher.source.asciiSpec, null, null, ($("#locationText")?.value?.replace(invalidChars, '_') || dialog.mLauncher.suggestedFileName), null, null, false, null, null, null, null, null, false, null, mainwin.PrivateBrowsingUtils.isBrowserPrivate(mainwin.gBrowser.selectedBrowser), Services.scriptSecurityManager.getSystemPrincipal());
                        close();
                    }
                });
                dialogFrame.getButton('extra2').before(saveAs);
            }
            // 快速保存
            if (isTrue('userChromeJS.downloadPlus.enableSaveTo')) {
                let saveTo = createEl(document, 'button', {
                    id: 'save-to',
                    part: 'dialog-button',
                    size: 'small',
                    label: LANG.format("save to"),
                    type: 'menu',
                    accesskey: 'T'
                });
                let saveToMenu = createEl(document, 'menupopup');
                saveToMenu.appendChild(createEl(document, "html:link", {
                    rel: "stylesheet",
                    href: "chrome://global/skin/global.css"
                }));
                saveToMenu.appendChild(createEl(document, "html:link", {
                    rel: "stylesheet",
                    href: "chrome://global/content/elements/menupopup.css"
                }));
                saveTo.appendChild(saveToMenu);
                Services.wm.getMostRecentWindow("navigator:browser").DownloadPlus.SAVE_DIRS.forEach(item => {
                    let [name, dir] = [item[1], item[0]];
                    saveToMenu.appendChild(createEl(document, "menuitem", {
                        label: name || (dir.match(/[^\\/]+$/) || [dir])[0],
                        dir: dir,
                        image: "moz-icon:file:///" + dir + "\\",
                        class: "menuitem-iconic",
                        onclick: function () {
                            let dir = this.getAttribute('dir');
                            let file = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
                            let path = dir.replace(/^\./, Cc["@mozilla.org/file/directory_service;1"].getService(Ci.nsIProperties).get("ProfD", Ci.nsIFile).path);
                            path = path.endsWith("\\") ? path : path + "\\";
                            file.initWithPath(path + ($("#locationText")?.value?.replace(invalidChars, '_') || dialog.mLauncher.suggestedFileName));
                            if (dialog.mLauncher.MIMEInfo) {
                                dialog.mLauncher.MIMEInfo.preferredAction = Ci.nsIMIMEInfo.saveToDisk;
                                dialog.mLauncher.MIMEInfo.alwaysAskBeforeHandling = false;
                            }
                            dialog.mLauncher.saveDestinationAvailable(file);
                            dialog.onCancel = function () { };
                            close();
                        }
                    }));
                })
                dialogFrame.getButton('cancel').before(saveTo);
            }
            dialog.onOK = (() => {
                var cached_function = dialog.onOK;
                return async function (...args) {
                    if ($('#flashgotRadio')?.selected)
                        return $('#Flashgot-Download-By-Default-Manager').click();
                    else if ($('#locationText')?.value && $('#locationText')?.value != dialog.mLauncher.suggestedFileName) {
                        if (isTrue('browser.download.useDownloadDir')) {
                            dialog.onCancel = function () { };
                            let file = await IOUtils.getFile(await Downloads.getPreferredDownloadsDirectory(), $('#locationText').value);
                            return dialog.mLauncher.saveDestinationAvailable(file);
                        } else {
                            const mainwin = Services.wm.getMostRecentWindow("navigator:browser");
                            // 感谢 ycls006 / alice0775
                            Cu.evalInSandbox("(" + mainwin.internalSave.toString().replace("let ", "").replace("var fpParams", "fileInfo.fileExt=null;fileInfo.fileName=aDefaultFileName;var fpParams") + ")", mainwin.DownloadPlus.sb)(dialog.mLauncher.source.asciiSpec, null, null, ($("#locationText")?.value?.replace(invalidChars, '_') || dialog.mLauncher.suggestedFileName), null, null, false, null, null, null, null, null, false, null, mainwin.PrivateBrowsingUtils.isBrowserPrivate(mainwin.gBrowser.selectedBrowser), Services.scriptSecurityManager.getSystemPrincipal());
                            close();
                        }
                    } else {
                        return cached_function.apply(this, ...args);
                    }
                };
            })();
            setTimeout(() => {
                // 强制显示打开/保存/FlashGot选项
                document.getElementById("normalBox").removeAttribute("collapsed");
                window.sizeToContent();
            }, 100);
            this._log("initDownloadPopup 结束");
        },
        handleEvent: async function (event) {
            this._log("handleEvent", event.type, event.target.id);
            const { button, type, target } = event;
            if (type === 'popupshowing') {
                if (target.id === "DownloadPlus-Btn-Popup" || target.id === "DownloadPlus-ContextMenu-Popup") {
                    this.populateDynamicItems(target);
                } else if (target.id === "DownloadPlus-Flashgot-Handler-Popup") {
                    let dropdown = event.target;
                    let bw = Services.wm.getMostRecentWindow("navigator:browser");
                    dropdown.querySelectorAll('menuitem[manager]').forEach(e => e.remove());
                    bw.DownloadPlus.DOWNLOAD_MANAGERS.forEach(manager => {
                        const menuitemManager = createEl(dropdown.ownerDocument, 'menuitem', {
                            label: this.DEFAULT_MANAGER === manager ? LANG.format('default download manager', manager) : manager,
                            manager,
                            default: this.DEFAULT_MANAGER === manager
                        });
                        menuitemManager.addEventListener('command', (event) => {
                            const { target } = event;
                            const { ownerDocument: aDoc } = target;
                            const handler = aDoc.querySelector("#flashgotHandler");
                            target.parentNode.querySelectorAll("menuitem").forEach(el => el.removeAttribute("selected"));
                            handler.setAttribute("label",
                                target.getAttribute("default") === "true" ? LANG.format('default download manager', target.getAttribute("manager")) : target.getAttribute("manager"));
                            handler.setAttribute("manager", target.getAttribute("manager"));
                            target.setAttribute("selected", true);
                            aDoc.querySelector("#flashgotRadio").click();
                        })
                        dropdown.appendChild(menuitemManager);
                    })
                }
            } else if (type === "mouseover") {
                const btn = target.ownerDocument.querySelector('#DownloadPlus-Btn');
                if (!btn) return;
                const mp = btn.querySelector("#DownloadPlus-Btn-Popup");
                if (!mp) return;
                // 获取按钮的位置信息
                const rect = btn.getBoundingClientRect();
                // 获取窗口的宽度和高度
                const windowWidth = target.ownerGlobal.innerWidth;
                const windowHeight = target.ownerGlobal.innerHeight;

                const x = rect.left + rect.width / 2;  // 按钮的水平中心点
                const y = rect.top + rect.height / 2;  // 按钮的垂直中心点

                if (x < windowWidth / 2 && y < windowHeight / 2) {
                    mp.removeAttribute("position");
                } else if (x >= windowWidth / 2 && y < windowHeight / 2) {
                    mp.setAttribute("position", "after_end");
                } else if (x >= windowWidth / 2 && y >= windowHeight / 2) {
                    mp.setAttribute("position", "before_end");
                } else {
                    mp.setAttribute("position", "before_start");
                }
            }
        },
        populateMenu (doc, menuObj) {
            const popup = createEl(doc, 'menupopup', menuObj);
            if (menuObj.id === 'DownloadPlus-ContextMenu-Popup') {
                popup.appendChild(createEl(doc, 'menuitem', {
                    label: LANG.format('download by default download manager'),
                    id: 'DownloadPlus-ContextMenuitem',
                    class: 'FlashGot-icon menuitem-iconic',
                    oncommand: () => {
                        this.downloadByManager();
                    }
                }));
            } else {
                popup.appendChild(createEl(doc, 'menuitem', {
                    label: LANG.format('force reload download managers list'),
                    id: 'FlashGot-reload',
                    class: 'FlashGot-reload menuitem-iconic',
                    oncommand: () => {
                        this.reloadSupportedManagers(true, true, () => {
                            $('#DownloadPlus-ContextMenu-Popup')?.removeAttribute("initialized");
                            $('#DownloadPlus-Btn-Popup')?.removeAttribute("initialized");
                        });
                    }
                }));
            }
            popup.appendChild(createEl(doc, 'menuseparator', {
            }));
            popup.appendChild(createEl(doc, 'menuseparator', {
                id: 'FlashGot-DownloadManagers-Separator'
            }));
            popup.appendChild(createEl(doc, 'menuitem', {
                label: LANG.format('about download plus'),
                id: 'FlashGot-about',
                class: 'FlashGot-about menuitem-iconic',
                oncommand: function () {
                    openTrustedLinkIn("https://github.com/benzBrake/Firefox-downloadPlus.uc.js", "tab");
                }
            }));
            popup.addEventListener('popupshowing', this, false);
            return popup;
        },
        populateDynamicItems (popup) {
            if (popup.hasAttribute("initialized")) return;
            popup.setAttribute("initialized", true);
            popup.querySelectorAll('menuitem[dynamic]').forEach(item => item.remove());
            const sep = popup.querySelector("#FlashGot-DownloadManagers-Separator")
            for (let name of this.DOWNLOAD_MANAGERS) {
                if (name.trim() === '') continue;
                let obj = {
                    label: name,
                    managerId: name.trim().replace(/\s+/g, '-'),
                    dynamic: true,
                };
                if (popup.id === "DownloadPlus-Btn-Popup") {
                    obj.type = 'radio';
                    obj.oncommand = () => {
                        this.DEFAULT_MANAGER = name;
                    }
                    obj.checked = this.isManagerEnabled(name);
                } else if (popup.id === "DownloadPlus-ContextMenu-Popup") {
                    obj.oncommand = () => {
                        this.downloadByManager(name);
                    }
                    obj.class = 'downloader-item menuitem-iconic';
                }
                let item = createEl(popup.ownerDocument, 'menuitem', obj);
                popup.insertBefore(item, sep);
            }
            if (!popup.querySelector("menuitem[dynamic]")) popup.removeAttribute("initialized");
        },
        isManagerEnabled (name) {
            return this.DEFAULT_MANAGER === name;
        },
        exec: async function (path, args, options = { startHidden: false }) {
            this._log("exec 调用", { path, args, options });
            switch (typeof args) {
                case 'string':
                    args = args.split(/\s+/);
                case 'object':
                    if (Array.isArray(args)) break;
                default:
                    args = [];
            }
            let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile);
            let process = Cc['@mozilla.org/process/util;1'].createInstance(Ci.nsIProcess);
            if (options.startHidden) process.startHidden = true;
            try {
                file.initWithPath(path);
                if (!file.exists()) {
                    alerts(LANG.format("file not found", path), "error");
                    return;
                }

                if (file.isExecutable()) {
                    process.init(file);
                    if (typeof options.processObserver === "object") {
                        this._log("使用异步 processObserver");
                        process.runwAsync(args, args.length, options.processObserver);
                    } else {
                        this._log("同步执行");
                        process.runw(false, args, args.length);
                    }

                } else {
                    this._log("非可执行文件，直接 launch");
                    file.launch();
                }
            } catch (e) {
                console.error("Execution error:", e);
            }
        },
        reloadSupportedManagers: async function (force = false, alert = false, callback) {
            this._log("reloadSupportedManagers 调用", { force, alert, current: this.DOWNLOAD_MANAGERS });
            try {
                let prefVal = Services.prefs.getStringPref('userChromeJS.downloadPlus.flashgotDownloadManagers');
                this.DOWNLOAD_MANAGERS = prefVal.split(",");
                this._log("从 prefs 读取下载器列表", this.DOWNLOAD_MANAGERS);
            } catch (e) {
                force = true;
                this._log("读取 prefs 失败，强制重新扫描", e);
            }
            if (force) {
                const resultPath = handlePath('{TmpD}\\.flashgot.dm.' + Math.random().toString(36).slice(2) + '.txt');
                this._log("强制刷新，生成临时文件", resultPath);
                await new Promise((resolve, reject) => {
                    // read download managers list from flashgot.exe
                    this.exec(this.FLASHGOT_PATH, ["-o", resultPath], {
                        processObserver: {
                            observe (subject, topic) {
                                switch (topic) {
                                    case "process-finished":
                                        this._log("FlashGot.exe 执行完毕，准备读取结果");
                                        try {
                                            // Wait 1s after process to resolve
                                            setTimeout(resolve, 1000);
                                        } catch (ex) {
                                            reject(ex);
                                        }
                                        break;
                                    default:
                                        this._log("FlashGot.exe 异常结束", topic);
                                        reject(topic);
                                        break;
                                }
                            }
                        },
                    });
                });
                let resultString = readText(resultPath, FLASHGOT_OUTPUT_ENCODING);
                this._log("FlashGot 输出原始内容", resultString);
                this.DOWNLOAD_MANAGERS = resultString.split("\n").filter(l => l.includes("|OK")).map(l => l.replace("|OK", ""));
                await IOUtils.remove(resultPath, { ignoreAbsent: true });
                this._log("解析后下载器列表", this.DOWNLOAD_MANAGERS);
                Services.prefs.setStringPref(this.PREF_DOWNLOAD_MANAGERS, this.DOWNLOAD_MANAGERS.join(","));
            }
            if (alert) {
                alerts(LANG.format("reload download managers list finish"));
            }
            if (typeof callback === "function") {
                callback(this);
            }
        },
        downloadByManager: async function (manager, url, options = {}) {
            if (!manager) {
                manager = this.DEFAULT_MANAGER;
            }
            if (!url) {
                if (gContextMenu) {
                    if (gContextMenu.onLink) {
                        url = gContextMenu.linkURL;
                    } else if (gContextMenu.isTextSelected && gContextMenu.onPlainTextLink) {
                        try {
                            let URI = Services.uriFixup.getFixupURIInfo(gContextMenu.selectedText).fixedURI;
                            url = URI.spec;
                        } catch (e) {
                            console.error(e);
                        }
                    }
                } else {
                    url = gBrowser.selectedBrowser.currentURI.spec;
                }
            }
            if (!url) return;
            const uri = Services.io.newURI(url);
            const { FLASHGOT_PATH, DL_FILE_STRUCTURE, REFERER_OVERRIDES, USERAGENT_OVERRIDES } = this;
            const { description, mBrowser, isPrivate } = options;
            const userAgent = (function (o, u, m, c) {
                for (let d of Object.keys(o)) {
                    // need to implement regex / subdomain process
                    if (u.host.endsWith(d)) return o[d];
                }
                return m?.browsingContext?.customUserAgent || c["@mozilla.org/network/protocol;1?name=http"].getService(Ci.nsIHttpProtocolHandler).userAgent;
            })(USERAGENT_OVERRIDES, uri, mBrowser, Cc);
            let referer = '', postData = '', fileName = '', extension = '', downloadPageReferer = '', downloadPageCookies = '';
            if (options.mBrowser) {
                const { mBrowser, mContentData } = options;
                referer = mBrowser.currentURI.spec;
                downloadPageReferer = mContentData.referrerInfo.originalReferrer.spec
            } else if (options.mLauncher) {
                const { mLauncher, mSourceContext } = options;
                downloadPageReferer = mSourceContext.currentURI.spec;
                downloadPageCookies = gatherCookies(downloadPageReferer);
                fileName = options.fileName || mLauncher.suggestedFileName;
                try { extension = mLauncher.MIMEInfo.primaryExtension; } catch (e) { }
            }
            if (downloadPageReferer) {
                downloadPageCookies = gatherCookies(downloadPageReferer);
            }
            let refMatched = domainMatch(uri.host, REFERER_OVERRIDES);
            if (refMatched) {
                referer = refMatched;
            }
            let uaMatched = domainMatch(uri.host, USERAGENT_OVERRIDES);
            if (uaMatched) {
                userAgent = uaMatched;
            }
            const initData = replaceArray(DL_FILE_STRUCTURE, [
                '{num}', '{download-manager}', '{is-private}', '{referer}', '{url}', '{description}', '{cookies}', '{post-data}',
                '{filename}', '{extension}', '{download-page-referer}', '{download-page-cookies}', '{user-agent}'
            ], [
                1, manager, isPrivate, referer, uri.spec, description || '', gatherCookies(uri.spec), postData,
                fileName, extension, downloadPageReferer, downloadPageCookies, userAgent
            ]);
            this._log("生成 .dl.properties 内容", initData);
            const initFilePath = handlePath(`{TmpD}\\${hashText(uri.spec)}.dl.properties`);
            this._log("写入临时文件", initFilePath);
            await IOUtils.writeUTF8(initFilePath, initData);
            await new Promise((resolve, reject) => {
                this.exec(FLASHGOT_PATH, initFilePath, {
                    processObserver: {
                        observe (subject, topic) {
                            switch (topic) {
                                case "process-finished":
                                    try {
                                        // Wait 1s after process to resolve
                                        setTimeout(resolve, 1000);
                                    } catch (ex) {
                                        reject(ex);
                                    }
                                    break;
                                default:
                                    reject(topic);
                                    break;
                            }
                        }
                    },
                });
            });
            function domainMatch (domain, domainCollections) {
                let isObject = typeof domainCollections === 'object', isMatch = false;
                if (isObject && !Array.isArray(domainCollections)) {
                    isMatch = match(domain, Object.keys(domainCollections));
                    if (isMatch) {
                        return domainCollections[isMatch];
                    }
                    return;
                }
                return match(domain, domainCollections);

                function match (domain, domains) {
                    for (let i = 0; i < domains.length; i++) {
                        if (domain.endsWith(domains[i])) {
                            return domains[i];
                        }
                    }
                    return false;
                }
            }
        },
        _log (...args) {
            if (isTrue(this.debug)) {
                Services.wm.getMostRecentWindow("navigator:browser").console.log("DownloadPlus", ...args);
            }
        }
    }
    function isTrue (pref, defaultValue = true) {
        return Services.prefs.getBoolPref(pref, defaultValue) === true;
    }

    /**
     * 获取所有盘符，用到 dll 调用，只能在 windows 下使用
     * 
     * @system windows
     * @returns {array} 所有盘符数组
     */
    function getAllDrives () {
        let lib = ctypes.open("kernel32.dll");
        let GetLogicalDriveStringsW = lib.declare('GetLogicalDriveStringsW', ctypes.winapi_abi, ctypes.unsigned_long, ctypes.uint32_t, ctypes.char16_t.ptr);
        let buffer = new (ctypes.ArrayType(ctypes.char16_t, 1024))();
        let rv = GetLogicalDriveStringsW(buffer.length, buffer);
        let resultLen = parseInt(rv.toString() || "0");
        let arr = [];
        if (!resultLen) {
            lib.close();
            return arr;
        }
        for (let i = 0; i < resultLen; i++) {
            arr[i] = buffer.addressOfElement(i).contents;
        }
        arr = arr.join('').split('\0').filter(el => el.length);
        lib.close();
        return arr;
    }

    /**
     * 选择 HTML 元素
     * 
     * @param {string} sel 选择表达式
     * @returns 
     */
    function $ (sel) {
        return document.querySelector(sel);
    }

    /**
     * 创建 DOM 元素
     * 
     * @param {Document} doc 
     * @param {string} type 
     * @param {Object} attrs 
     * @returns 
     */
    function createEl (doc, type, attrs = {}) {
        let el = type.startsWith('html:') ? doc.createElementNS('http://www.w3.org/1999/xhtml', type) : doc.createXULElement(type);
        for (let key of Object.keys(attrs)) {
            if (key === 'innerHTML') {
                el.innerHTML = attrs[key];
            } else if (key.startsWith('on')) {
                el.addEventListener(key.slice(2).toLocaleLowerCase(), attrs[key]);
            } else {
                el.setAttribute(key, attrs[key]);
            }
        }
        return el;
    }

    /**
     * 复制文本到剪贴板
     * 
     * @param {string} aText 需要复制的文本
     */
    function copyText (aText) {
        Cc["@mozilla.org/widget/clipboardhelper;1"].getService(Ci.nsIClipboardHelper).copyString(aText);
    }

    /**
     * 从文件读取内容
     * 
     * @param {Ci.nsIFile|string} aFileOrPath 文件实例或路径
     * @param {string} encoding 编码
     * @returns 
     */
    function readText (aFileOrPath, encoding = "UTF-8") {
        encoding || (encoding = "UTF-8");
        var aFile;
        if (typeof aFileOrPath == "string") {
            aFile = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile);;
            aFile.initWithPath(aFileOrPath);
        } else {
            aFile = aFileOrPath;
        }
        if (aFile.exists()) {
            let stream = Cc['@mozilla.org/network/file-input-stream;1'].createInstance(Ci.nsIFileInputStream);
            stream.init(aFile, 0x01, 0, 0);
            let cvstream = Cc['@mozilla.org/intl/converter-input-stream;1'].createInstance(Ci.nsIConverterInputStream);
            cvstream.init(stream, encoding, 1024, Ci.nsIConverterInputStream.DEFAULT_REPLACEMENT_CHARACTER);
            let content = '',
                data = {};
            while (cvstream.readString(4096, data)) {
                content += data.value;
            }
            cvstream.close();
            return content.replace(/\r\n?/g, '\n');
        } else {
            return "";
        }
    }

    /**
     * 弹出右下角提示
     * 
     * @param {string} aMsg 提示信息
     * @param {string} aTitle 提示标题
     * @param {Function} aCallback 提示回调，可以不提供
     */
    function alerts (aMsg, aTitle, aCallback) {
        var callback = aCallback ? {
            observe: function (subject, topic, data) {
                if ("alertclickcallback" != topic)
                    return;
                aCallback.call(null);
            }
        } : null;
        var alertsService = Cc["@mozilla.org/alerts-service;1"].getService(Ci.nsIAlertsService);
        alertsService.showAlertNotification(
            "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgd2lkdGg9IjY0IiBoZWlnaHQ9IjY0IiBmaWxsPSJjb250ZXh0LWZpbGwiIGZpbGwtb3BhY2l0eT0iY29udGV4dC1maWxsLW9wYWNpdHkiPjxwYXRoIGZpbGw9Im5vbmUiIGQ9Ik0wIDBoMjR2MjRIMHoiLz48cGF0aCBkPSJNMTIgMjJDNi40NzcgMjIgMiAxNy41MjMgMiAxMlM2LjQ3NyAyIDEyIDJzMTAgNC40NzcgMTAgMTAtNC40NzcgMTAtMTAgMTB6bTAtMmE4IDggMCAxIDAgMC0xNiA4IDggMCAwIDAgMCAxNnpNMTEgN2gydjJoLTJWN3ptMCA0aDJ2NmgtMnYtNnoiLz48L3N2Zz4=", aTitle || "DownloadPlus",
            aMsg + "", !!callback, "", callback);
    }

    function handlePath (path) {
        if (typeof path !== "string")
            throw new Error("Path must be a string");
        path = path.replace(/{\w*}/g, function (...matches) {
            let match = matches[0];
            try {
                return Services.dirsvc.get(match.slice(1, -1), Ci.nsIFile).path;
            } catch (e) {
                throw new Error("Invalid path variable: " + match);
            }
        });
        if (AppConstants.platform === "win") {
            path = path.replace(/\//g, "\\");
            if (path.startsWith("\\")) {
                let f = Services.dirsvc.get("ProfD", Ci.nsIFile);
                f.appendRelativePath(path.slice(1));
                path = f.path;
            }
        } else {
            path = path.replace(/\\/g, "/");
            if (/^\w/.test(path)) {
                let f = Services.dirsvc.get("ProfD", Ci.nsIFile);
                f.appendRelativePath(path.slice(1));
                path = f.path
            }
        }
        return path;
    }

    /**
     * 计算文本的哈希值
     * 
     * @param {string} text 需要计算的文本
     * @param {string} type 哈希类型
     * @returns 
     */
    function hashText (text, type) {
        if (!(typeof text == 'string' || text instanceof String)) {
            text = "";
        }

        // var converter = Cc["@mozilla.org/intl/scriptableunicodeconverter"]
        //     .createInstance(Ci.nsIScriptableUnicodeConverter);

        // converter.charset = "UTF-8";
        // var result = {};
        // var data = converter.convertToByteArray(text, result);

        // Bug 1851797 - Remove nsIScriptableUnicodeConverter convertToByteArray and convertToInputStream
        let data = new TextEncoder("utf-8").encode(text);

        if (Ci.nsICryptoHash[type]) {
            type = Ci.nsICryptoHash[type]
        } else {
            type = 2;
        }
        var hasher = Cc["@mozilla.org/security/hash;1"].createInstance(
            Ci.nsICryptoHash
        );

        text = null;
        hasher.init(type);
        hasher.update(data, data.length);
        var hash = hasher.finish(false);
        str = data = hasher = null;

        function toHexString (charCode) {
            return ("0" + charCode.toString(16)).slice(-2);
        }

        return Array.from(hash, (c, i) => toHexString(hash.charCodeAt(i))).join("");
    }

    /**
     * 文本串替换
     * 
     * @param {string} replaceString 需要处理的文本串
     * @param {Array} find 需要被替换的文本串
     * @param {Array} replace 替换的文本串
     * @returns string
     */
    function replaceArray (replaceString, find, replace) {
        var regex;
        for (var i = 0; i < find.length; i++) {
            regex = new RegExp(find[i], "g");
            replaceString = replaceString.replace(regex, replace[i]);
        }
        return replaceString;
    }

    /**
     * 收集 cookie 并保存到文件
     * 
     * @param {string} link 链接
     * @param {boolean} saveToFile 是否保存到文件 
     * @param {Function|string|undefined} filter Cookie 过滤器
     * @returns 
     */
    function gatherCookies (link, saveToFile = false, filter) {
        if (!link) return "";
        if (!/^https?:\/\//.test(link)) return "";
        const uri = Services.io.newURI(link, null, null);
        let cookies = Services.cookies.getCookiesFromHost(uri.host, {});
        const cookieSavePath = handlePath("{TmpD}");

        // Apply filter if specified
        if (filter) cookies = cookies.filter(cookie => filter.includes(cookie.name));

        // Format and save cookies to file if needed
        if (saveToFile) {
            const cookieString = cookies.map(formatCookie).join('');
            const file = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
            file.initWithPath(cookieSavePath);
            file.append(`${uri.host}.txt`);

            if (!file.exists()) file.create(Ci.nsIFile.NORMAL_FILE_TYPE, 0o644);

            const foStream = Cc["@mozilla.org/network/file-output-stream;1"].createInstance(Ci.nsIFileOutputStream);
            foStream.init(file, 0x02 | 0x08 | 0x20, 0o666, 0);
            foStream.write(cookieString, cookieString.length);
            foStream.close();

            return file.path;
        } else {
            return cookies.map(cookie => `${cookie.name}:${cookie.value}`).join("; ");
        }

        function formatCookie (co) {
            // Format to Netscape type cookie format
            return [
                `${co.isHttpOnly ? '#HttpOnly_' : ''}${co.host}`,
                co.isDomain ? 'TRUE' : 'FALSE',
                co.path,
                co.isSecure ? 'TRUE' : 'FALSE',
                co.expires > 0 ? co.expires : "0",
                co.name,
                co.value
            ].join('\t') + '\n';
        }
    }

    await window.DownloadPlus.init();
})(`
.FlashGot-icon {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABd0lEQVQ4T5WTv0/CQBzFXy22Axh+NHXqYJjAYggd2JTYNrK5OTg5GTf/Dv0jHEjUzdnEUHbD1KQaEwYTnAwlhiiIxub0jvCjFCjeeN/3Pn33eschZFWrVZJOpxGPxyFJEjctD2xMCqjZMIzRluu6kGXZ5wkAqIk6kskkNE3zfZAC6JqE+ADUXCqVwPM8E3JcMCAhBO12ewQZKai5UCgglUotbGUIGCZhgOmzhhXreR4sy0K5XB5kpABd18N8vnmtVoNpmmNAPp//F8C27TGgXq+z5judzlKQSCQCVVVZkb6aHxyHCKKIt/MDH+jn2cF334N7coGsVmQzNZdj3sB/sg6zRFeaTETWFHitBj5egNezR2QymfCb2DJBEtkV8OuDEA2bYOOqD1EUZ97awGav1yPvR1HIO38Jvjh8OgTN03tsasXlALdGjOzud7EaA+6uo9iqPEFRlLlvJjCggL3jLtwbIHE5P/qw5Zkl0uF2xYYgCAtfK9X9AmZ+hRG+dHY+AAAAAElFTkSuQmCC');
}
.FlashGot-reload {
    list-style-image: url("chrome://global/skin/icons/reload.svg");
}
.FlashGot-about {
    list-style-image: url("chrome://global/skin/icons/help.svg");
}
.FlashGot-download {
    list-style-image: url("chrome://browser/skin/downloads/downloads.svg");
}
.downloader-item[managerId="BitComet"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADcUlEQVQ4T12Ta2hbZQCGn+/kpLltS9J7adps7eqlK047GF3qZUwHOhCpxWyCOH9s+qOgrIMIoqN4+aFQhxX2Q4cIrkgbBoKYKmrLZG02sa51W2fXa2zWZs3aNWkuTU5yjsfIoPr9+fh+vM/38vK+gv+die6uFkMqcsJaZPaaXPVoGmzcuML8xEx/ssh4+lDfT5c2S8S9R6Cny3VfIt1tqizxOj0HsOxsBFGEEBqqmiMdmmL6q89YGL7Yr7h3nWw/2xv+R1sADPX4XPV504j14Udq7Huf1HVmMBgKbJHPFu5kNMSWskpCgW8YP3N6IV9a7WnvHQgXABPvvd5X/uh+r6P1ANr6Opi3ISy2glBJxSgyWcjMjqEsTmNqfoLQ+X4ufX6m/2hw7rAY8h1raaguD1a+2gmxNd2ugqF8B0p0UgcVQy5JLn4bc00TuR/PEYuv43zqOX5+o4PIcmKfuPrm0b7atnavbXsjInmXnM2OsDvQxr9DczejSSq5a99j8bxC5uYwpqlRltI5FFMVgz2f+kX47Re1io63yEcXkCXIuxpITF3Anlokt2M/GGWkyQDxbbVYK5uQLvaS+vMK6sHjjLxzCnHn3SOa/dkjelgKqbgeVGsbK/7XKKlvJuXYpQdqwHx7lLWVCM6n3yf2tQ/LSpR1Ry2Xz/2AiH9wWJNrSilybyeTWYIH9ui/fIixbg9Joxth0JBZQrkWxNr2BYmBT7BE5ojNhpiZ1RBrvlZNkiMYXXZU9260UivG8CCivB7FUo2QdUAmDvNBsntPwfQohrEAybkovy0XIyZPNPZVaXe8JucGiqcdSZ1Gzi4inE7yljodoCJlMhC+zEbdy0ixFPIvXxKaz3Jhtd4vho41tzSY5oLFjg2kxw8hZcf09iTAUYxmrQbdgUgnkJYmyJY9g5rIkR8ZYPAPmM09uK9QpGDHzr4Gy5LX+lAd8paZQoGkqiryBqvuwKLz9GxWo+S37ib5V5wbv84xEi7z+75d8BYA533Pu+5Xr4+U2G7VlLlVvYUZtK1WVJsuNphgXQcoMsqajfGrWUYjzgVH9WOelz7q/bfK9yAV4np3hXzLW1mawewEzSwjJH1MGyrLy/D7TZmJ1Qp/aZOn83jXpjFtnmfA19oicoudxcbYC2o+QTYPac3O7F2zP22s/fjk2eH/zPlvFuZthlH+/JwAAAAASUVORK5CYII=');
}
.downloader-item[managerId="Download-Accelerator-Manager"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACwUlEQVQ4T22TbUhTYRTH/8/clDmdZk7WarbIrcJSCiyvFRVIS8MoJRA/BFHRC/QClQrSJ/ODfrCgD1GwbyZFIJGoTSIkRG30QsZ62bSmk5k2JOfLWO7e27n3QbPycuHhnpff+Z/znMuwwuN0Ovs8Ho+QZTJBlOKYnAxDEIR+t9td9G84W25QEoPDL4Vr16tx5NhprMowqe7v4wF0PWlG8y0XrPbiv0BLAIfDMVomjFgbmlsh6gTok2TERY7XahmiMQ0SZh6grvYq2gccQZ/Pl634VIBSOW+NW2i6eQli+knMzAPpKcB8jPOTk4DpOYYUPUEmalFd34HBcaeqRI3YZGNyzZlEHDjaguhCMowGQKOhqr+4An0SgywDMwSJR7/C030BjS6GLwGZMaX68UK3cKrCBpjr4B+TYM8mLiWEI1xBplHRyjAUBHLWkiN4Ga6n83g84OxnqSkG+XPbHCxmAmSewKBPRp6DEiguNMUBlgw66f3gZ9hm19BUmxAKz2JzuQFsdbpOfnZ3AQk6I9KsFfASIDeHV5yY4mMyZ/Dz4zC1uzGOyEgLJEnEofO6PwANgdPMRXjtNaBgq6KAIRjmidYsPos3XobtjglEJt9BIoUqYKkFpYo2FZ2v1qN0L5/BJ+pZAWyxqge6emWUFPgAMUbtgbewNMQyXuXhi2RUltAdSgyDAW7Ls1G2RkZrx09UFcdUm6sdfIjKh83C5BtnZWipjfd+qLdg0GsR/EHXR/5sk4y5aBz+URn5diAuAfX3GAIhukYFoKjIt7iFxitAZBZ47gHK9wNvh7iCHTTUth6geCdgJHE1t6lQaNkiKUHqKhf6rA0XQVKBqlLA+40DcjeQrZNsh4G6O/h/lXkYVzI21C2cq5QxPQ3s28XtPf1UOQ24/4hhnf3gyj/TImQR1NfXKyQwvsuilIii3XtW/J1/A3isFeq04ej9AAAAAElFTkSuQmCC');
}
.downloader-item[managerId="EagleGet"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADV0lEQVQ4T11TXWxTZRh+ztdzuq6tHbSDAd2WUmFotkAnCnHTKSWoGQI3DjXq1TK2xAsXvYAEYwzRkBiyCAE2QQI3u8CMMILGJSaQDWEMwhxE1nVja9c6fja6tuv56fmt3zlkCnzJe/HlzfN8z/e+z8PguePf1h3iSspb7S5XmNgdAbOtyVJcExYuqQupn2b+2D3yNIRZvJS/3lFs879y2O2vbCY2G5HmHkHOZqy2Y+lSFPvKoGuKwc8kTun3R774Z/BLyexZBOVNHcX1NfV9tRuWN7hZHSQzB00SkeMV3H8o4G40jb/Gc/CsrYG3qhoLidiAmrjxnkliEezaP3jiSFtFC0EBuq7DMIznf4bZlIj2b65gSvRi5aY3kJmKnpw+F97DBBq7Qwf3Ndz6e/gekR7PgbXpmE6kaAnY/m4VPm0KYfj2FNZXV8J2/Wt0982i3/khHhSHjUxkZCPzwbc3O39uX9smKxoFM5YCXhDQvrcX8biM1uY6fH/od5z98WXUxA6BGLql7k5+CT4bOtDFdJybiLa8s6KqUChY0s3SNA2SJGF+Pg2TeNnDs3Dc68NkmmDycRFeKhXh8DrRNHJsnPmlPym//5rPvkhgKjBLVVXwPI9YLIbI5V78dtOJoTEWfJ7A51GwfmsQycKbCtNzZUbesanUbr68OEATHIlE0D9wGxd/fYBYUoOoFKxiWA6EY1H2aj1cZasU5uiFeLS10V9lSmYYxpJ+7doges5HcXkgDbudAy+qSGUVCmb/I6gMN4IQMs589N1wZ+fnq9ui0QkEgwH8eXUIXWfGMRbl4XJyEAQF2axMpWsW2CRh3S9gzc7dyCXiXXSNp0NHvqq9VeFjyOzsPH44PmqtEHSoRRzBQi6PNCXIy3T6FExYG5bXbkbJi+uMzOjgRstI2/dePXHgY0/LwTNx3BmahKHpcDo4KLIKgco3HSmYCmwEnsAa+Ou2IBObODnd8/aeJ1amOVhd91Yf8a5qECfvYm50DMtKWCo9D1FSoSg6BJVgCbVxafUG5GYSA0rs+v9WXiRxBjcf9gYrmulDhBVTyD5KUR8YIC4POO9KGiaDhmn6lJocfjZMTxvfv+10yL1iXavb5w6DKwroegGqIMfz2eylfCpJ4/zJM3H+F/BksCbdxY7YAAAAAElFTkSuQmCC');
}
.downloader-item[managerId="FlareGet"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADLklEQVQ4T6WTW0iUeRjGn/98M85BZ75vxmZq/BzTHPOc5WSaWClu0LawGy3ssrGFDRVWlBVtUBfddOFNQVEYdLAgomKEqHRBd9gs0qDaZdZGbLdxtIPmpI5z+ObsfP9mhYKC6KL39uX5vQ8vz0PwlUM+p79bXy9NT5vc8Wx6pnOJuXC5VKlZ53Q8dASoaP9jccOwzWZL/q/9CEApJW0NhvQqUaNlLY22f33B3ECaSsVKoM73DmOBLhNExyM4+cr7evSf47U97taPAH2r8ptCyfj4VPWPl+dZm42E4TDhCUCtkSMijSPafgJ1A11+3UITS/Tz8cTxdMsHwKX6XEUVZxy6zy8TfWu2LrIU8yl/qdNKOQzpUsSVDB57wui+0dWz8dZv59YsK+uYlGfYySmLNscgUdJcPr9Rlld56eEv+1HAqeD3hqHVsWDVCmiQgDvlJJaZgbv2QfRfu3L4NNO7mytaOkL2mDP0zQU5HSrLN9JOcVGt7FcrBOd/4HRqaDNZaFUMTLIQno24ITx3oZ8uhvPMkeBBU/gYl8WL5JBZl91SveSlYqEZR2OrSUhvQHamHLGIH4rJYZRTH0pTPzCQOJiBLuzNakHvLZt4yvj8/NNA4ADpbizeUG2puZmIeLHBVTHGW6r54iI9Mhx3UBiegjHloMBkBHU9QGTchSauBa57t3FQ4ajY5Xw7QB40rW8uMfFnZ14MBusGyq8bc/K2f7fpJ0i1DDx9nSgbsuNnfQTE9wKvIxJsxj64H3WMBse68+ZycGF17sUfamqsoneEHuqdaP9d8a21uLKKmKQ+7Ez0oFQqYNb3FiP+CEaZLOybKEEanToy6uxsnQPc27b+askCdpM4MYS4N4T+sBx+qFDLiTBGBZB4Aq1javQJMtSzUXQwJU/Emb/qXC5XbA5wdmU231BVYdcyQpFEpMBsAjQQSlkOQxJLom1ajXZaAaVslpoxfnNYUGwfHOz2vq/AXJCOlaq/X6FRtRWq0vhEkmI6PivMk8mY/ig5eV63NkpEOi1EPH/+fb9r6NPufEjiznJWy0Gcn4zTsgZNeuUb4IL1scf9pbJ+to1fEr7fvwOS4EAIdr4rTAAAAABJRU5ErkJggg==');
}
.downloader-item[managerId="Free-Download-Manager"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAACqElEQVQ4T42STUhUURTH//e9NzM6M45jSqFI0a5FtAn6WKTRSnAIUsayDzVnaCVElohETS2CNiFCtIxoUZBIChXJtFLUooVSkNiQJYM6kvgxn+/NzL2vc9/gJy66cN+97957fvz/5xxmP3vjCDf5IxM4BzAN/zXMOSbMEB99PsDU2sCQaeK8SR9TEIb9F4EemT+RzTcxpTaQpEBXZUUZLtQcR6nbCQnba2yeFjb5jJHpIEBQF5w7bl6sQ29HkyVA3ksxckrWnivAF2JLtzcBD4ONuN9ajzw3keUCnKJksFSzAdgAFxQyHlvaBngQbCCAD2kjj8fvJzD5Nw3FZrdyYj1ntNnIj1wZ43oisaVAAu61+JDI5OB/8QnhlAvM5YHCTHg0E6s5wmhUJEWhSQCFcSTXtgECDbhLgCQBml6NIJwrByspg1cTeHLMg9HFON4sGkjbnVA01bKgJJZ3AnquSQs5dL37inHDDcXphkcV6DtRiWq3HYOzy+iLrGNGOMBsDq7GdwG6r/qQywusZ7IwhPReqInbppFiZv1F1lJ4OrOMoVVwPZXcUhAiC91XCgBF+rTKV6hAliojZFUIoBLl89w8OiZjPGqwnYCuyz4YOY4vv6KIpXSyqcCuKjh5qAolxUWUHx0DU9N4Nr2AqLeaq+YuwJ1mH1JGFtdfhzG8rkItdmGfDeivO0oydPSOfcOHNeqTAwfB3F6O+AopqAnMCiEOSwudl2QSDbS9HcewqIDiKYObquUvSWMk8gcRrRRKRRVQVCztJJWl+Ram1rS1U+OFQu2N1bdIQUYqGJzAR+wngJcSR/71lNX8zOmkXrBZJyyTeOkZG+thfr9f7Y/aT3U2+0631p9x6Nk8usJTGEE5NBlAObAGLUIml4hM13+7fnwfjvcGV/4BtgR56y5SI9QAAAAASUVORK5CYII=');
}
.downloader-item[managerId="Internet-Download-Manager"] {
    list-style-image: url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADRUlEQVQ4T6WTf2wTZRzGn/e9u/687my3MVgZRegGOoEhS9hYQFGqKBH+ARPQ6B8zkSjEQAwhBnUxxhBiwB+I6AwYCI5MGYSYGEJIzAiQJSwBQxldSdfa9Xd37dq73W6963mQiEaJ//j9503evM/nyfvk+xD8zyH/pT99urdDY+q3lvSZQEzmQ+WJscEje97+ytTM/Kl7KMAwDLL/cPe+Zf5nt3sErdEl+JAsl/BjuBVKTs6x4m9v+dhXBnp6SPVfgGCwx/Jpb3Dj/Ceun1reuMriqbHD3dSMMr8JZ4NNSERsKMbGdMR+2PHzsQ+OPgD0938jPKJe3EKV8qb+dHR1kz8pzHN3YW37RjS4JYjGMvQNezB8ezmK8STE8C/K1OjJtvuAgYHXWoRc+oTr0tjKGylavfl8grq9FDWCC2s72uD3rMKNyWdwfmgJomGglAqhEL0COfzTx6Tnu25PR92tQffRbOudMAkeczJi64bMamEhBWezYE5DIyTyCeKFpzEeVVDKJSDnTUBsCFp26BzZfqbrozfU5PvyQaK9GSmuEZ2ezZ1rpN32uTUA5wWhs1DU9kCrGJiWRajlDKbECMqJYTByuI+8eqFj/F1X2isfYNX9caFlKDXxpHtO7Vmu2YLyegKh4ACXXAQmXwMyqcJQwlClUajFPCZFdhdZcX69vnvBHdqW0zF5qeHX76/M7L2QZA8rTtouvzQM24scCDhQ0Q4+X4H1rorpoAY95kpoor2TrDtwqJQP9Lpedsp4rlqFLWvNXr5uyX/bN/F4aEkGxEdhNSGgBqCbiVfNM2OA3rWU/PFF+0hn4L3P7IGWdzJdp+BqDOMxCnjNd5nfKzhzLgtZrIBtpmAfZaCFqtBGqmCzbJ7GuUOGRHsJz8+uX9y+8+DsFYFtii9C5blBaM4i2IoDqavXkE4NwiiZxhHAMBfYYdgvG1nmQykvXTN9pu/vAc/z9e66pzYvaH2921a7eCkYK0cqup4wvi6OWr6srY4ARKKSVXZ8oaX1I4qipE3ZvQ+Z+fw1nMNRV8cwnN/Oe2fpM4UC9cnzSgvTx9kR600k2b2yTR5EElN/L+DDyvTgbuULS72hXHSXGqx8brqO34vwn+39A9u2aguAlsZkAAAAAElFTkSuQmCC");
}
.downloader-item[managerId="Mass-Downloader"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABhUlEQVQ4T72SzUsCQRjGH02LLgXRsYj6DyoIOlVEx7BDx+jQITqG4X/QoUMJ4knCCOkQfRBSUZCUCVGnoHNgipJJWu26yX7Nvu0Imp8oHRoYmJ15398+88xjQYvjKnNEM73zlurymo16vMv3fcozCTld8DEoyCopJIUYPCOnK00B68/LpLA8JFWAIulgqgFZVHHtj4YTwfhUUwBXtHQxTbm0jIeTZLhcYV1AIOmmxT5nDbjfMXDDm3lTOaSi8PbjjPyRTQTmwi0p46BSIW8WtU8c3vsxPjyBLlsPus1ps9phgKAyGd9MxKsShWvIU+orLHYSG0RgpstfELQsdNLQYe2E3dIOq7UNZJ7ChMimmduuUMG84jUKgNWnWTI0A0w3oOZ1aHkG/m0YMAG/OplGiOzFagEcsnA8Sbqs4+4gUeF0vVzUKCgWObxj9BhKV/yhWVDrPlf1U3GI+2WNnINbf4ty8G2XVJIhMdGnGQoyagopIQ7v6Pk/RZkbrOS01qLcyLRGUf4BUtDoEQLpHdwAAAAASUVORK5CYII=');
}
.downloader-item[managerId="Jdownloader"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAADhElEQVQ4T12Ta2hbBRTH//fevN+5aR4djQup9GHItAsTV2GUqu2gBZlTJyqFsq44oXNitSIKUYbCsKiruA9KfVCdHVgcswNlQsSWIWQ6terWJVlTtzQxaXKbx703uS/TSIvswDkfDuf8zuE8CNwmejO9lzLoH9dotcFHutX2E4eta99+n7nw0sf8p5lMpnJ7PLHl8Hg8TlFvmVZpdYManQoGcw20h8UOUo/pcRqnZpKZ32PV47PzmS//D2kATPVkb6dxIdSjbUunDODKJCRRhr+jiF8iBI72t+Cxbh5vf35DGep2PX/38JX3tiANgMPfcf7pMWrw0QEr5i+RiMdVSMa0YFI8KgUWZopFZLoLf16K4r4ulxB66ufdf8XLS5u5hJ6m9/YNORbHjzqJ1TUKKrWEUlXB2XM0Er8p4Jl1CCyLyRd3offOGzBbtNh/5MrZxcuFQw2Azet9540P6OO9uy3IMgoWr7nww08tyK3WUM7eApdfR61SQn93MybHFCi5IgYmljmm5LDHYrEq0dTmv7jvoO4Bj8uKbKkVaaajUZUvMqjk0uAKmx1U4LKxWPgkhJvRa+gLx5HPksFaubxE2He2Lty1T30/w3hhcdrBcjSkKodqeQMck0etVIRQ5RH0SfjsRCdyiQQGw0kUU9IelmWjhMnjPWOgbU+421QwWw3Irlkh1lCvWv5P+SoUgcUXJ31wW3RoUmXx0HhSuRljd1QqlTRhoJtGNGb7hx0hGQcPabHByvhunsLKH6o6SIAkVHF40IKxITcSV3l0tnIYfT2x9M3FbLAxRLfbbWRJfdx5h+Tu2U/AYqRQqshIr4m4lVDgpox4/xU//kkwmJor4tRrdnw9mzo5Orky0QBsGoPN8TBlMM85miVyV0iE1URCqMkwiWoc6fdBKvF49fQqzGYNPnrLj2KssLye5JYzBeXH7VM20s5hUmc8bTBL2vb2CvY0m9AbsNVnIOHdr/J4ZsiFvgebIBVrqKZYcGm+OjGbb98GBAIBTYZhhru84ssD96h3mgwU8Wv9FuaiilLitUWKlC+88KSlPHLANiJkWCIaLU8dePP6sW2AoiiE0+fzyIIcVFNyQBDRIiuUGpBzBKm6DlJcslD5XE+7/tnRfudzx6YS915eqV3dBmw9RzgcJmdmZtT1HVOSJBF6vV7y+XxiJBIRN2M2O91IJ5x/57gUQUD5FyLSlbNVZqIRAAAAAElFTkSuQmCC');
}
.downloader-item[managerId="Thunder"] {
    list-style-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABUUlEQVQ4T2NkAAL/5p9bGRgYvUBs4sH/bRtr2b0ZydMMs+b/NqABv/4Ta6uWPAODpxEzw4sP/xmW7v8H1gY2QFmSgeHuc9zGgDRG2TEz6MgzMTx6/Z8hb+YfuGK4C/SVGBlyfJgZRPkYGebs+sOw5dR/BkZGBobGaGYGPQUmuIYZ2/8w7DiLcDSKF0A2tcWyghXvvfSXwVaLmYGNBdVlSZN+M7z7hBDDCIMNNRADsIG+jX8YDl1GDTKSDJi85Q/D3gsUGABz1dm7/xjWHvvLcO0hNBaQnRvrzMQQbMmM4YPbz/4xnL7zn+Hn7/8M20//Z/gFjQis6SDLh4nBzQBhSNXi32DbsAGcCUlVmoEhxoGZQV+RieHyg38MtUv+kmYATLU2MGpbgVFbsfA3w43HmGYQlZRB6cPHlJmhaw2mK4jOTCBDMMMBmJlAjiIvR0KyMwB0zo+VR+VNTAAAAABJRU5ErkJggg==');
}
menuseparator:not([hidden=true])+#FlashGot-DownloadManagers-Separator,
#context-media-eme-learnmore:has(~ #FlashGot-ContextMenu[hide-eme-sep=true]) {
    display: none !important;
}
`, `
#downloadsContextMenu:not([needsgutter]) > .downloadPlus-menuitem > .menu-iconic-left {
    visibility: collapse;
}
`, `
#contentTypeImage {
    height: 24px !important;
    width: 24px !important;
    margin-top: 3px !important;
}
#location {
    padding: 3px 0;
}
#locationText {
    border: 1px solid var(--in-content-box-border-color, ThreeDDarkShadow);
    border-right-width: 0 !important;
    border-radius:var(--border-radius-small) 0 0 var(--border-radius-small) !important;
    padding-inline: 5px;
    flex: 1;
    appearance: none;
    padding-block: 2px !important;
    margin: 0;
    min-height: calc(var(--button-min-height-small, 28px) - 4px - 2px) !important;
    max-height: calc(var(--button-min-height-small, 28px) - 4px - 2px) !important;
}
#locationText.invalid {
    outline: 2px solid red !important;
    background-color: #ffc0c0 !important;
}
#locationHbox {
    display: flex;
}
#locationHbox[hidden="true"] {
    visibility: collapse;
}
#encodingConvertButton {
    margin-top: 0 !important;
    margin-bottom: 0 !important;
    margin-inline-start: 0 !important;
    min-height: var(--button-min-height-small, 28px) !important;
    max-height: var(--button-min-height-small, 28px) !important;
    min-width: unset !important;
    list-style-image: url(data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAxNiAxNiIgd2lkdGg9IjE2IiBoZWlnaHQ9IjE2IiBmaWxsPSJjb250ZXh0LWZpbGwiIGZpbGwtb3BhY2l0eT0iY29udGV4dC1maWxsLW9wYWNpdHkiPjxwYXRoIGQ9Ik0zLjYwMzUxNTYgMkwwIDEyLjc5Mjk2OUwwIDEzTDEgMTNMMSAxMi45NTcwMzFMMS45ODYzMjgxIDEwTDcuMDE5NTMxMiAxMEw4IDEyLjk1NTA3OEw4IDEzTDkgMTNMOSAxMi43OTQ5MjJMNS40MTYwMTU2IDJMNC41IDJMMy42MDM1MTU2IDIgeiBNIDQuMzIyMjY1NiAzTDQuNSAzTDQuNjk1MzEyNSAzTDYuNjg3NSA5TDIuMzIwMzEyNSA5TDQuMzIyMjY1NiAzIHogTSAxMSA1TDExIDZMMTMuNSA2QzE0LjMzNTAxNSA2IDE1IDYuNjY0OTg0OSAxNSA3LjVMMTUgOC4wOTM3NUMxNC44NDI3NSA4LjAzNzEzMzUgMTQuNjc1NjcgOCAxNC41IDhMMTEuNSA4QzEwLjY3NzQ2OSA4IDEwIDguNjc3NDY4NiAxMCA5LjVMMTAgMTEuNUMxMCAxMi4zMjI1MzEgMTAuNjc3NDY5IDEzIDExLjUgMTNMMTMuNjcxODc1IDEzQzE0LjE0NjI5NyAxMyAxNC42MDQ0ODYgMTIuODYwMDg0IDE1IDEyLjYxMTMyOEwxNSAxM0wxNiAxM0wxNiAxMS43MDcwMzFMMTYgOS41TDE2IDcuNUMxNiA2LjEyNTAxNTEgMTQuODc0OTg1IDUgMTMuNSA1TDExIDUgeiBNIDExLjUgOUwxNC41IDlDMTQuNzgxNDY5IDkgMTUgOS4yMTg1MzE0IDE1IDkuNUwxNSAxMS4yOTI5NjlMMTQuNzMyNDIyIDExLjU2MDU0N0MxNC40NTEwNzQgMTEuODQxODk1IDE0LjA2OTE3MSAxMiAxMy42NzE4NzUgMTJMMTEuNSAxMkMxMS4yMTg1MzEgMTIgMTEgMTEuNzgxNDY5IDExIDExLjVMMTEgOS41QzExIDkuMjE4NTMxNCAxMS4yMTg1MzEgOSAxMS41IDkgeiIvPjwvc3ZnPg==);
    border-radius: 0;
    margin-block: 0;
    margin-inline: 0 !important;
    outline: none;
    appearance: none !important;
    box-sizing: border-box;
    border: 1px solid var(--in-content-box-border-color, ThreeDDarkShadow) !important;
    border-radius: 0 var(--border-radius-small) var(--border-radius-small) 0  !important;
}
#basicBox {
    display: none;
}
#completeLinkDescription {
    max-width: 340px;
    cursor:pointer;
}
hbox.copied > #completeLinkDescription {
    text-decoration: underline;
}
#openHandler,
#flashgotHandler,
.dialog-button-box > .dialog-button {
    min-height: var(--button-min-height-small, 28px) !important;
    max-height: var(--button-min-height-small, 28px) !important;
}
.button-menu-dropmarker {
    appearance: none;
    content: url("chrome://global/skin/icons/arrow-down-12.svg");
    -moz-context-properties: fill;
    fill: currentColor;
}
`)