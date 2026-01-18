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
userChromeJS.downloadPlus.showAllDrives 下载对话框显示所有驱动器
*/
// @note            20260118 改进文件操作大部分使用 IOUtils, 增加链接黑名单防止错误调用外部下载器，完成部分兼容新版 FlashGot 的代码（功能暂时无效）
// @note            20260113 Bug 1369833 Remove `alertsService.showAlertNotification` call once Firefox 147
// @note            20251105 新增静默调用 FlashGot下载（Firefox 应如何处理其他文件？选择保存文件(S)后生效）
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
            // 按钮和标签
            "download plus btn": "DownloadPlus",
            "download enhance click to switch default download manager": "下载增强，点击可切换默认下载工具",

            // FlashGot 相关
            "force reload download managers list": "刷新下载工具",
            "reload download managers list finish": "读取FlashGot 支持的下载工具完成，请选择你喜欢的下载工具",
            "download through flashgot": "使用 FlashGot 下载",
            "download by default download manager": "使用默认工具下载",
            "no supported download manager": "没有找到 FlashGot 支持的下载工具",
            "default download manager": "%s（默认）",
            "no download managers": "没有下载工具",
            "reloading download managers list": "正在重新读取下载工具列表，请稍后！",
            "set to default download manger": "设置 %s 为默认下载器",

            // URL 类型相关
            "unsupported url for external downloader": "此 URL 类型不支持外部下载器",
            "url not supported reason": "此 URL 不支持外部下载器：%s",

            // 文件操作
            "file not found": "文件不存在：%s",
            "about download plus": "关于 DownloadPlus",

            // 编码转换
            "original name": "默认编码: ",
            "encoding convert tooltip": "点击转换编码",

            // 复制链接
            "complete link": "链接：",
            "copy link": "复制链接",
            "copied": "复制完成",
            "dobule click to copy link": "双击复制链接",
            "successly copied": "复制成功",

            // 保存按钮
            "save and open": "保存并打开",
            "save as": "另存为",
            "save to": "保存到",

            // 目录名称
            "desktop": "桌面",
            "downloads folder": "下载",
            "disk %s": "%s 盘",

            // 通用
            "app name": "DownloadPlus",
            "error": "错误",
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

    /* ========================================
       URL 类型检查和处理工具函数

       使用正则数组配置不支持的 URL 模式，便于扩充
       ======================================== */

    /**
     * 支持外部下载器的 URL 协议列表
     */
    const SUPPORTED_EXTERNAL_PROTOCOLS = ['http', 'https', 'ftp', 'ftps'];

    /**
     * 不支持外部下载器的 URL 模式配置
     * 每个条目包含：正则表达式 和 原因说明
     */
    const URL_PATTERNS_NOT_SUPPORTED = [
        {
            pattern: /^blob:/i,
            reason: "Blob URL（浏览器内存数据）"
        },
        {
            pattern: /^data:/i,
            reason: "Data URL（内联数据）"
        },
        {
            pattern: /^(about|chrome|resource):/i,
            reason: "浏览器内部页面"
        },
        {
            pattern: /^file:/i,
            reason: "本地文件"
        },
        {
            pattern: /^(mailto|javascript|view-source):/i,
            reason: "特殊协议链接"
        },
        {
            pattern: /\.xpi$/i,
            reason: "XPI 扩展文件（需浏览器安装）"
        },
        {
            pattern: /xpinstall/i,
            reason: "扩展安装链接"
        }
    ];

    /**
     * 检查 URL 是否支持外部下载器
     * @param {nsIURI|string} urlOrUri - URL 字符串或 nsIURI 对象
     * @returns {boolean} 是否支持外部下载器
     */
    function isLinkSupportedByFlashgot (urlOrUri) {
        let uri;
        try {
            if (typeof urlOrUri === 'string') {
                uri = Services.io.newURI(urlOrUri);
            } else {
                uri = urlOrUri;
            }
        } catch (e) {
            return false;
        }

        const scheme = uri.scheme.toLowerCase();

        // 检查协议是否支持
        if (!SUPPORTED_EXTERNAL_PROTOCOLS.includes(scheme)) {
            return false;
        }

        // 检查是否匹配不支持的 URL 模式
        const spec = uri.spec;
        for (const { pattern } of URL_PATTERNS_NOT_SUPPORTED) {
            if (pattern.test(spec)) {
                return false;
            }
        }

        return true;
    }

    /**
     * 获取不支持外部下载器的原因说明
     * @param {nsIURI|string} urlOrUri - URL 字符串或 nsIURI 对象
     * @returns {string|null} 不支持的原因，如果支持则返回 null
     */
    function getUnsupportedReason (urlOrUri) {
        let uri;
        try {
            if (typeof urlOrUri === 'string') {
                uri = Services.io.newURI(urlOrUri);
            } else {
                uri = urlOrUri;
            }
        } catch (e) {
            return LANG.format("unsupported url for external downloader");
        }

        const spec = uri.spec;

        // 检查是否匹配不支持的 URL 模式
        for (const { pattern, reason } of URL_PATTERNS_NOT_SUPPORTED) {
            if (pattern.test(spec)) {
                return LANG.format("url not supported reason", reason);
            }
        }

        return null;
    }

    /* Do not change below 不懂不要改下边的 */
    const versionGE = (v) => {
        return Services.vc.compare(Services.appinfo.version, v) >= 0;
    }

    const processCSS = (css) => {
        if (versionGE("143a1")) {
            css = `#DownloadPlus-Btn { list-style-image: var(--menuitem-icon); }\n` + css.replaceAll('list-style-image', '--menuitem-icon');
        }
        return css;
    }

    const AlertNotification = Components.Constructor(
        "@mozilla.org/alert-notification;1",
        "nsIAlertNotification",
        "initWithObject"
    );

    if (window.DownloadPlus) return;

    window.DownloadPlus = {
        debug: false,
        // ========================================
        // 配置常量
        // ========================================
        PREF_FLASHGOT_PATH: 'userChromeJS.downloadPlus.flashgotPath',
        PREF_DEFAULT_MANAGER: 'userChromeJS.downloadPlus.flashgotDefaultManager',
        PREF_DOWNLOAD_MANAGERS: 'userChromeJS.downloadPlus.flashgotDownloadManagers',
        PREF_ALWAYS_OPEN_PANEL: 'browser.download.alwaysOpenPanel',
        SAVE_DIRS: [[Services.dirsvc.get('Desk', Ci.nsIFile).path, LANG.format("desktop")], [
            Services.dirsvc.get('DfltDwnld', Ci.nsIFile).path, LANG.format("downloads folder")
        ]],
        DOWNLOAD_MANAGERS: [],
        NEWER_FLASHGOT: false,
        DL_FILE_STRUCTURE: `{num};{download-manager};{is-private};;\n{referer}\n{url}\n{description}\n{cookies}\n{post-data}\n{filename}\n{extension}\n{download-page-referer}\n{download-page-cookies}\n\n\n{user-agent}`,
        USERAGENT_OVERRIDES: {},
        REFERER_OVERRIDES: {
            'aliyundrive.net': 'https://www.aliyundrive.com/'
        },
        // UI 常量
        BUTTON_FEEDBACK_DURATION: 1000,  // 按钮反馈持续时间(毫秒)
        DIALOG_RENDER_DELAY: 100,        // 对话框渲染延迟(毫秒)
        SECURITY_DIALOG_DELAY: 0,        // 安全对话框延迟(禁用)
        get FLASHGOT_PATH () {
            delete this.FLASHGOT_PATH;
            let flashgotPref = Services.prefs.getStringPref(this.PREF_FLASHGOT_PATH, "\\chrome\\UserTools\\FlashGot.exe");
            flashgotPref = handlePath(flashgotPref);
            const flashgotFile = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile);
            flashgotFile.initWithPath(flashgotPref);
            if (flashgotFile.exists()) {
                if ("cd2a6299e96f735e1dd35edb0f12ea2d" !== getMD5(flashgotFile.path)) {
                    this.NEWER_FLASHGOT = true;
                }
                return this.FLASHGOT_PATH = flashgotFile.path;
            } else {
                return this.FLASHGOT_PATH = false;
            }
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
            // Services.prefs.setBoolPref('browser.download.always_ask_before_handling_new_types', true);
            // 保存按钮无需等待即可点击
            Services.prefs.setIntPref('security.dialog_enable_delay', this.SECURITY_DIALOG_DELAY);

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

            this.URLS_FOR_OPEN = [];
            const { PREF_ALWAYS_OPEN_PANEL } = this;
            const alwaysOpenPanel = getBool(PREF_ALWAYS_OPEN_PANEL, true);
            const downloadView = {
                onDownloadChanged: function (dl) {
                    if (isTrue('userChromeJS.downloadPlus.enableSaveAndOpen')) {
                        if (dl.progress != 100) return;
                        const url = dl.source.url;
                        const index = window.DownloadPlus.URLS_FOR_OPEN.indexOf(url);
                        if (index > -1) {
                            let target = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
                            target.initWithPath(dl.target.path);
                            target.launch();
                            window.DownloadPlus.URLS_FOR_OPEN.splice(index, 1);
                        }
                    }
                },
                onDownloadAdded: async function (dl) {
                    const { DownloadPlus: dp, DownloadsCommon: dc } = window;
                    if (!isTrue('browser.download.always_ask_before_handling_new_types') && isTrue('userChromeJS.downloadPlus.enableFlashgotIntergention') && dp.FLASHGOT_PATH && dp.DEFAULT_MANAGER && isLinkSupportedByFlashgot(dl.source.url)) {
                        if (alwaysOpenPanel) {
                            setBool(PREF_ALWAYS_OPEN_PANEL, false);
                        }
                        dp._log("尝试使用 flashgot 下载 " + dl.source.url);
                        const url = dl.source.url;
                        const options = {
                            isPrivate: true
                        };
                        const refererUrl = dl.source.referrerInfo.originalReferrer.spec;
                        if (refererUrl) options.referer = refererUrl;
                        dp.downloadByManager("", url, options).then(_ => {
                            dp._log("downloadByManager 成功，准备删除下载任务");
                            dc.deleteDownloadFiles(dl, 2);
                            dp._log("deleteDownloadFiles 执行完成");
                        }).catch((ex) => {
                            dp._log("flashgot 下载失败: " + ex);
                        });
                    }
                },
                onDownloadRemoved: function (dl) {
                    setBool(PREF_ALWAYS_OPEN_PANEL, alwaysOpenPanel);
                },
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
            Downloads.getList(Downloads.ALL).then(list => { addDownloadView(list, downloadView) });
            window.addEventListener("beforeunload", () => {
                Downloads.getList(Downloads.ALL).then(list => { removeDownloadView(list, downloadView) });
            });

            if (isTrue('userChromeJS.downloadPlus.showAllDrives')) {
                getAllDrives().forEach(drive => {
                    this.SAVE_DIRS.push([drive, LANG.format("disk %s", drive.replace(':\\', ""))])
                });
            }
            if (isTrue('userChromeJS.downloadPlus.enableFlashgotIntergention')) {
                console.log("DownloadPlus: 尝试初始化 FlashGot 集成");
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
        /**
         * ========================================
         * 初始化下载对话框 (重构版)
         * ========================================
         * 将原 295 行的函数拆分为 25 个职责单一的小函数
         * 遵循 KISS、SRP、DRY 原则
         */

        /**
         * 初始化下载对话框 (主入口)
         * 协调各个子功能模块的初始化
         */
        initDownloadPopup: async function () {
            this._log("initDownloadPopup 开始");
            const dialogFrame = dialog.dialogElement('unknownContentType');

            // 按顺序初始化各个功能模块
            this._setupDialogAccessKeys(dialogFrame);
            await this._setupRenameFeature();
            this._setupCopyLinkFeature();
            this._setupDoubleClickSave();
            await this._setupFlashgotIntegration();
            this._setupQuickSaveButtons(dialogFrame);
            this._overrideDialogOKHandler();
            this._forceShowDialogOptions();

            this._log("initDownloadPopup 结束");
        },

        /**
         * 设置对话框按钮的访问键
         * @param {Element} dialogFrame - 对话框框架元素
         */
        _setupDialogAccessKeys (dialogFrame) {
            dialogFrame.getButton('accept').setAttribute('accesskey', 'c');
            dialogFrame.getButton('cancel').setAttribute('accesskey', 'x');
        },

        /**
         * 设置文件名重命名功能
         * 包括输入框和编码转换按钮
         */
        _setupRenameFeature: async function () {
            if (!isTrue('userChromeJS.downloadPlus.enableRename')) return;

            // 创建文件名输入框容器
            const locationHbox = createEl(document, 'hbox', {
                id: 'locationHbox',
                flex: 1,
                align: 'center',
            });

            // 隐藏原始 location 元素
            const location = $('#location');
            location.hidden = true;
            location.after(locationHbox);

            // 创建文件名输入框
            const locationText = this._createFilenameInput(locationHbox);

            // 如果启用编码转换,创建转换按钮
            if (isTrue('userChromeJS.downloadPlus.enableEncodeConvert')) {
                this._createEncodingConverter(locationHbox, locationText);
            }
        },

        /**
         * 创建文件名输入框并设置验证
         * @param {Element} container - 父容器元素
         * @returns {Element} 输入框元素
         */
        _createFilenameInput (container) {
            const locationText = container.appendChild(createEl(document, "html:input", {
                id: "locationText",
                value: dialog.mLauncher.suggestedFileName,
                flex: 1
            }));

            // 输入不能用于文件名的字符时输入框变红
            locationText.addEventListener('input', function () {
                if (this.value.match(invalidChars)) {
                    this.classList.add('invalid');
                } else {
                    this.classList.remove('invalid');
                }
            });

            // 回车键触发保存操作
            locationText.addEventListener('keydown', function (event) {
                if (event.key === 'Enter') {
                    dialog.onCancel = {};
                    dialog.dialogElement('unknownContentType').getButton("accept").click();
                }
            });

            return locationText;
        },

        /**
         * 创建编码转换按钮和菜单
         * @param {Element} container - 父容器元素
         * @param {Element} locationText - 文件名输入框
         */
        _createEncodingConverter (container, locationText) {
            const encodingConvertButton = container.appendChild(createEl(document, 'button', {
                id: 'encodingConvertButton',
                type: 'menu',
                size: 'small',
                tooltiptext: LANG.format("encoding convert tooltip")
            }));

            const converter = Cc['@mozilla.org/intl/scriptableunicodeconverter']
                .getService(Ci.nsIScriptableUnicodeConverter);

            const menupopup = createEl(document, 'menupopup', {
                position: 'after_end'
            });

            // 添加原始文件名选项
            menupopup.appendChild(createEl(document, 'menuitem', {
                value: dialog.mLauncher.suggestedFileName,
                label: LANG.format("original name") + dialog.mLauncher.suggestedFileName,
                selected: true,
                default: true,
            }));

            // 获取原始字符串(尝试从 localStorage 或 URL 获取)
            const originalString = this._getOriginalFilenameString();

            // 创建各种编码的菜单项
            ["GB18030", "BIG5", "Shift-JIS"].forEach(encoding => {
                this._createEncodingMenuItem(menupopup, converter, encoding, originalString);
            });

            // 点击菜单项时更新文件名
            menupopup.addEventListener('click', (event) => {
                if (event.target.localName === "menuitem") {
                    locationText.value = event.target.value;
                }
            });

            encodingConvertButton.appendChild(menupopup);
        },

        /**
         * 获取原始文件名字符串
         * @returns {string} 原始文件名
         */
        _getOriginalFilenameString () {
            try {
                const storedFilename = opener.localStorage.getItem(dialog.mLauncher.source.spec);
                const urlFilename = dialog.mLauncher.source.asciiSpec.substring(
                    dialog.mLauncher.source.asciiSpec.lastIndexOf("/")
                );
                const originalString = (storedFilename || urlFilename).replace(/[\/:*?"<>|]/g, "");
                opener.localStorage.removeItem(dialog.mLauncher.source.spec);
                return originalString;
            } catch (error) {
                this._log("从 localStorage 读取文件名失败:", error);
                return dialog.mLauncher.suggestedFileName;
            }
        },

        /**
         * 创建编码转换菜单项
         * @param {Element} menupopup - 菜单弹出容器
         * @param {Object} converter - Unicode 转换器
         * @param {string} encoding - 编码名称
         * @param {string} originalString - 原始字符串
         */
        _createEncodingMenuItem (menupopup, converter, encoding, originalString) {
            converter.charset = encoding;
            const menuitem = menupopup.appendChild(document.createXULElement("menuitem"));
            menuitem.value = converter.ConvertToUnicode(originalString).replace(/^"(.+)"$/, "$1");
            menuitem.label = `${encoding}: ${menuitem.value}`;
        },

        /**
         * 设置复制链接功能
         * 包括双击复制和复制按钮
         */
        _setupCopyLinkFeature () {
            const linkContainer = createEl(document, 'hbox', { align: 'center' });
            $("#source").parentNode.after(linkContainer);

            // 双击复制链接
            if (isTrue('userChromeJS.downloadPlus.enableDoubleClickToCopyLink')) {
                this._createDoubleClickCopyElements(linkContainer);
            }

            // 复制链接按钮
            if (isTrue('userChromeJS.downloadPlus.enableCopyLinkButton')) {
                this._createCopyLinkButton(linkContainer);
            }
        },

        /**
         * 创建双击复制链接的元素
         * @param {Element} container - 父容器元素
         */
        _createDoubleClickCopyElements (container) {
            const downloadUrl = dialog.mLauncher.source.spec;

            const label = container.appendChild(createEl(document, 'label', {
                innerHTML: LANG.format("complete link"),
                style: 'margin-top: 1px'
            }));

            const description = container.appendChild(createEl(document, 'description', {
                id: 'completeLinkDescription',
                class: 'plain',
                flex: 1,
                crop: 'center',
                value: downloadUrl,
                tooltiptext: LANG.format("dobule click to copy link"),
            }));

            // 为 label 和 description 添加双击复制事件
            [label, description].forEach(el => {
                el.addEventListener("dblclick", () => copyText(downloadUrl));
            });
        },

        /**
         * 创建复制链接按钮
         * @param {Element} container - 父容器元素
         */
        _createCopyLinkButton (container) {
            const downloadUrl = dialog.mLauncher.source.spec;
            const self = this;

            container.appendChild(createEl(document, 'button', {
                id: 'copy-link-btn',
                label: LANG.format("copy link"),
                size: 'small',
                onclick: function () {
                    copyText(downloadUrl);
                    this.setAttribute("label", LANG.format("copied"));
                    this.parentNode.classList.add("copied");

                    setTimeout(() => {
                        this.setAttribute("label", LANG.format("copy link"));
                        this.parentNode.classList.remove("copied");
                    }, self.BUTTON_FEEDBACK_DURATION);
                }
            }));
        },

        /**
         * 设置双击保存功能
         */
        _setupDoubleClickSave () {
            if (!isTrue('userChromeJS.downloadPlus.enableDoubleClickToSave')) return;

            $('#save').addEventListener('dblclick', (event) => {
                const { dialog } = event.target.ownerGlobal;
                dialog.dialogElement('unknownContentType').getButton("accept").click();
            });
        },

        /**
         * 设置 FlashGot 集成功能
         */
        _setupFlashgotIntegration: async function () {
            if (!isTrue('userChromeJS.downloadPlus.enableFlashgotIntergention')) return;

            const browserWindow = Services.wm.getMostRecentWindow("navigator:browser");
            const downloadPlus = browserWindow.DownloadPlus;

            if (!downloadPlus.FLASHGOT_PATH || !downloadPlus.DOWNLOAD_MANAGERS.length) {
                return;
            }

            // 检查当前下载 URL 是否支持外部下载器
            if (!isLinkSupportedByFlashgot(dialog.mLauncher.source)) {
                this._log("URL 不支持外部下载器，跳过 FlashGot 集成");
                return;
            }

            // 创建 FlashGot UI 元素
            const flashgotUI = this._createFlashgotUI(browserWindow, downloadPlus);

            // 设置选择事件监听
            this._setupFlashgotSelectionHandler();

            // 添加到对话框
            $('#mode').appendChild(flashgotUI);
        },

        /**
         * 创建 FlashGot UI 元素
         * @param {Window} browserWindow - 浏览器窗口
         * @param {Object} downloadPlus - DownloadPlus 对象
         * @returns {Element} FlashGot UI 容器
         */
        _createFlashgotUI (browserWindow, downloadPlus) {
            const createElem = (tag, attrs, children = []) => {
                const elem = createEl(document, tag, attrs);
                children.forEach(child => elem.appendChild(child));
                return elem;
            };

            const triggerDownload = () => {
                const { mLauncher, mContext } = dialog;
                const { source } = mLauncher;

                // 检查 URL 是否支持外部下载器
                if (!isLinkSupportedByFlashgot(source)) {
                    const reason = getUnsupportedReason(source);
                    alerts(reason, LANG.format("error"));
                    return;
                }

                const sourceContext = mContext.BrowsingContext.get(mLauncher.browsingContextId);
                const fileName = $("#locationText")?.value?.replace(invalidChars, '_') ||
                    dialog.mLauncher.suggestedFileName;

                downloadPlus.downloadByManager(
                    $('#flashgotHandler').getAttribute('manager'),
                    source.spec,
                    {
                        fileName,
                        mLauncher,
                        mSourceContext: sourceContext.parent || sourceContext,
                        isPrivate: browserWindow.PrivateBrowsingUtils.isWindowPrivate(window)
                    }
                );
                close();
            };

            // 创建 FlashGot 选项容器
            return createElem('hbox', { id: 'flashgotBox' }, [
                createElem('radio', {
                    id: 'flashgotRadio',
                    label: LANG.format("download through flashgot"),
                    accesskey: 'F',
                    ondblclick: triggerDownload
                }),
                createElem('deck', { id: 'flashgotDeck', flex: 1 }, [
                    createElem('hbox', { flex: 1, align: 'center' }, [
                        createElem('menulist', {
                            id: 'flashgotHandler',
                            label: LANG.format('default download manager', downloadPlus.DEFAULT_MANAGER),
                            manager: downloadPlus.DEFAULT_MANAGER,
                            flex: 1,
                            native: true
                        }, [
                            this._createFlashgotManagerPopup()
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
        },

        /**
         * 创建 FlashGot 下载管理器选择弹出菜单
         * @returns {Element} 弹出菜单元素
         */
        _createFlashgotManagerPopup () {
            const menupopup = createEl(document, 'menupopup', {
                id: 'DownloadPlus-Flashgot-Handler-Popup',
            });
            menupopup.addEventListener('popupshowing', this, false);
            return menupopup;
        },

        /**
         * 设置 FlashGot 选择处理器
         * 当选择 FlashGot 时禁用"记住选择"复选框
         */
        _setupFlashgotSelectionHandler () {
            $('#mode').addEventListener("select", () => {
                const flashgotRadio = $('#flashgotRadio');
                const rememberChoice = $('#rememberChoice');

                if (flashgotRadio?.selected) {
                    rememberChoice.disabled = true;
                    rememberChoice.checked = false;
                } else {
                    rememberChoice.disabled = false;
                }
            });
        },

        /**
         * 设置快速保存按钮
         * 包括"保存并打开"、"另存为"、"保存到"
         * @param {Element} dialogFrame - 对话框框架元素
         */
        _setupQuickSaveButtons (dialogFrame) {
            if (isTrue('userChromeJS.downloadPlus.enableSaveAndOpen')) {
                this._createSaveAndOpenButton(dialogFrame);
            }

            if (isTrue('userChromeJS.downloadPlus.enableSaveAs')) {
                this._createSaveAsButton(dialogFrame);
            }

            if (isTrue('userChromeJS.downloadPlus.enableSaveTo')) {
                this._createSaveToButton(dialogFrame);
            }
        },

        /**
         * 创建"保存并打开"按钮
         * @param {Element} dialogFrame - 对话框框架元素
         */
        _createSaveAndOpenButton (dialogFrame) {
            const saveAndOpen = createEl(document, 'button', {
                id: 'save-and-open',
                label: LANG.format("save and open"),
                accesskey: 'P',
                size: 'small',
                part: 'dialog-button'
            });

            saveAndOpen.addEventListener('click', () => {
                const browserWindow = Services.wm.getMostRecentWindow("navigator:browser");
                browserWindow.DownloadPlus.URLS_FOR_OPEN.push(dialog.mLauncher.source.asciiSpec);
                dialog.dialogElement('save').click();
                dialogFrame.getButton("accept").disabled = 0;
                dialogFrame.getButton("accept").click();
            });

            dialogFrame.getButton('extra2').before(saveAndOpen);
        },

        /**
         * 创建"另存为"按钮
         * @param {Element} dialogFrame - 对话框框架元素
         */
        _createSaveAsButton (dialogFrame) {
            const self = this;
            const saveAs = createEl(document, 'button', {
                id: 'save-as',
                label: LANG.format("save as"),
                accesskey: 'E',
                oncommand: function () {
                    self._triggerSaveAsDialog();
                    close();
                }
            });

            dialogFrame.getButton('extra2').before(saveAs);
        },

        /**
         * 触发"另存为"对话框
         */
        _triggerSaveAsDialog () {
            const mainWindow = Services.wm.getMostRecentWindow("navigator:browser");
            const fileName = $("#locationText")?.value?.replace(invalidChars, '_') ||
                dialog.mLauncher.suggestedFileName;

            // 感谢 ycls006 / alice0775
            Cu.evalInSandbox(
                "(" + mainWindow.internalSave.toString()
                    .replace("let ", "")
                    .replace("var fpParams", "fileInfo.fileExt=null;fileInfo.fileName=aDefaultFileName;var fpParams") + ")",
                mainWindow.DownloadPlus.sb
            )(
                dialog.mLauncher.source.asciiSpec, null, null, fileName,
                null, null, false, null, null, null, null, null, false, null,
                mainWindow.PrivateBrowsingUtils.isBrowserPrivate(mainWindow.gBrowser.selectedBrowser),
                Services.scriptSecurityManager.getSystemPrincipal()
            );
        },

        /**
         * 创建"保存到"按钮及菜单
         * @param {Element} dialogFrame - 对话框框架元素
         */
        _createSaveToButton (dialogFrame) {
            const saveTo = createEl(document, 'button', {
                id: 'save-to',
                part: 'dialog-button',
                size: 'small',
                label: LANG.format("save to"),
                type: 'menu',
                accesskey: 'T'
            });

            const saveToMenu = this._createSaveToMenu();
            saveTo.appendChild(saveToMenu);
            dialogFrame.getButton('cancel').before(saveTo);
        },

        /**
         * 创建"保存到"菜单
         * @returns {Element} 菜单元素
         */
        _createSaveToMenu () {
            const saveToMenu = createEl(document, 'menupopup');

            // 添加样式表
            saveToMenu.appendChild(createEl(document, "html:link", {
                rel: "stylesheet",
                href: "chrome://global/skin/global.css"
            }));
            saveToMenu.appendChild(createEl(document, "html:link", {
                rel: "stylesheet",
                href: "chrome://global/content/elements/menupopup.css"
            }));

            // 为每个保存目录创建菜单项
            const browserWindow = Services.wm.getMostRecentWindow("navigator:browser");
            browserWindow.DownloadPlus.SAVE_DIRS.forEach(([dirPath, dirName]) => {
                this._createSaveToMenuItem(saveToMenu, dirPath, dirName);
            });

            return saveToMenu;
        },

        /**
         * 创建"保存到"菜单项
         * @param {Element} menu - 菜单容器
         * @param {string} dirPath - 目录路径
         * @param {string} dirName - 目录名称
         */
        _createSaveToMenuItem (menu, dirPath, dirName) {
            const menuitem = createEl(document, "menuitem", {
                label: dirName || (dirPath.match(/[^\\/]+$/) || [dirPath])[0],
                dir: dirPath,
                image: "moz-icon:file:///" + dirPath + "\\",
                class: "menuitem-iconic",
                onclick: function () {
                    const targetDir = this.getAttribute('dir');
                    const file = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);

                    // 处理相对路径
                    let fullPath = targetDir.replace(/^\./,
                        Cc["@mozilla.org/file/directory_service;1"]
                            .getService(Ci.nsIProperties)
                            .get("ProfD", Ci.nsIFile).path
                    );

                    // 确保路径以反斜杠结尾
                    fullPath = fullPath.endsWith("\\") ? fullPath : fullPath + "\\";

                    // 获取文件名
                    const fileName = $("#locationText")?.value?.replace(invalidChars, '_') ||
                        dialog.mLauncher.suggestedFileName;

                    file.initWithPath(fullPath + fileName);

                    // 设置 MIME 信息
                    if (dialog.mLauncher.MIMEInfo) {
                        dialog.mLauncher.MIMEInfo.preferredAction = Ci.nsIMIMEInfo.saveToDisk;
                        dialog.mLauncher.MIMEInfo.alwaysAskBeforeHandling = false;
                    }

                    dialog.mLauncher.saveDestinationAvailable(file);
                    dialog.onCancel = function () { };
                    close();
                }
            });

            menu.appendChild(menuitem);
        },

        /**
         * 重写对话框 OK 处理器
         * 支持 FlashGot 下载和自定义文件名
         */
        _overrideDialogOKHandler () {
            const originalOKHandler = dialog.onOK;
            const self = this;

            dialog.onOK = async function (...args) {
                const flashgotRadio = $('#flashgotRadio');
                const locationText = $('#locationText');

                // 如果选择了 FlashGot,触发 FlashGot 下载
                if (flashgotRadio?.selected) {
                    return $('#Flashgot-Download-By-Default-Manager').click();
                }

                // 如果修改了文件名
                const hasCustomFilename = locationText?.value &&
                    locationText.value !== dialog.mLauncher.suggestedFileName;

                if (hasCustomFilename) {
                    return await self._handleCustomFilename(locationText.value);
                }

                // 使用原始处理器
                return originalOKHandler.apply(this, args);
            };
        },

        /**
         * 处理自定义文件名的保存
         * @param {string} customFilename - 自定义文件名
         */
        _handleCustomFilename: async function (customFilename) {
            // 如果使用默认下载目录
            if (isTrue('browser.download.useDownloadDir')) {
                dialog.onCancel = function () { };
                const downloadDir = await Downloads.getPreferredDownloadsDirectory();
                const file = await IOUtils.getFile(downloadDir);
                file.append(customFilename);
                return dialog.mLauncher.saveDestinationAvailable(file);
            }

            // 否则显示另存为对话框
            this._triggerSaveAsDialog();
            close();
        },

        /**
         * 强制显示对话框选项
         * 确保打开/保存/FlashGot 选项可见
         */
        _forceShowDialogOptions () {
            const self = this;
            setTimeout(() => {
                document.getElementById("normalBox")?.removeAttribute("collapsed");
                window.sizeToContent();
            }, self.DIALOG_RENDER_DELAY);
        },
        handleEvent: async function (event) {
            this._log("handleEvent", event.type, event.target.id);
            const { button, type, target } = event;
            if (type === 'popupshowing') {
                if (target.id === "DownloadPlus-Btn-Popup" || target.id === "DownloadPlus-ContextMenu-Popup") {
                    this.populateDynamicItems(target);
                } else if (target.id === "DownloadPlus-Flashgot-Handler-Popup") {
                    const dropdown = event.target;
                    const browserWindow = Services.wm.getMostRecentWindow("navigator:browser");
                    dropdown.querySelectorAll('menuitem[manager]').forEach(e => e.remove());
                    browserWindow.DownloadPlus.DOWNLOAD_MANAGERS.forEach(manager => {
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
                const button = target.ownerDocument.querySelector('#DownloadPlus-Btn');
                if (!button) return;
                const menuPopup = button.querySelector("#DownloadPlus-Btn-Popup");
                if (!menuPopup) return;
                // 获取按钮的位置信息
                const rect = button.getBoundingClientRect();
                // 获取窗口的宽度和高度
                const windowWidth = target.ownerGlobal.innerWidth;
                const windowHeight = target.ownerGlobal.innerHeight;

                const x = rect.left + rect.width / 2;  // 按钮的水平中心点
                const y = rect.top + rect.height / 2;  // 按钮的垂直中心点

                if (x < windowWidth / 2 && y < windowHeight / 2) {
                    menuPopup.removeAttribute("position");
                } else if (x >= windowWidth / 2 && y < windowHeight / 2) {
                    menuPopup.setAttribute("position", "after_end");
                } else if (x >= windowWidth / 2 && y >= windowHeight / 2) {
                    menuPopup.setAttribute("position", "before_end");
                } else {
                    menuPopup.setAttribute("position", "before_start");
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
                    alerts(LANG.format("file not found", path), LANG.format("error"));
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
                let self = this;
                const resultPath = handlePath('{TmpD}\\.flashgot.dm.' + Math.random().toString(36).slice(2) + '.txt');
                const args = this.NEWER_FLASHGOT ? ["--silent", "-f", "txt", "-o", resultPath] : ["-o", resultPath];
                if (this.debug) args.push("--debug");
                this._log("强制刷新，生成临时文件", resultPath);
                await new Promise((resolve, reject) => {
                    // read download managers list from flashgot.exe
                    this.exec(this.FLASHGOT_PATH, this.NEWER_FLASHGOT ? ["--silent", "-f", "txt", "-o", resultPath] : ["-o", resultPath], {
                        processObserver: {
                            observe (subject, topic) {
                                switch (topic) {
                                    case "process-finished":
                                        self._log("FlashGot.exe 执行完毕，准备读取结果");
                                        try {
                                            // Wait 1s after process to resolve
                                            setTimeout(resolve, 1000);
                                        } catch (ex) {
                                            reject(ex);
                                        }
                                        break;
                                    default:
                                        self._log("FlashGot.exe 异常结束", topic);
                                        reject(topic);
                                        break;
                                }
                            }
                        },
                    });
                });
                let resultString = await readText(resultPath, FLASHGOT_OUTPUT_ENCODING);

                if (resultString) {
                    if (resultString.startsWith('[ { "available"')) {
                        // Newer FlashGot version outputs JSON 还没做完
                        resultString = await IOUtils.readUTF8(resultPath);
                        // 懒得研究为啥多了些没用的字符
                        const lastBracket = resultString.lastIndexOf(']');
                        if (lastBracket !== -1) {
                            resultString = resultString.slice(0, lastBracket + 1);
                        }
                        this._log("读取到下载器列表结果", resultString);
                        let resultJson = JSON.parse(resultString);
                        this.NEWER_FLASHGOT = true;
                        this.DOWNLOAD_MANAGERS = resultJson.filter(m => m.available).map(m => m.name);
                    } else {
                        this._log("读取到下载器列表结果", resultString);
                        this.DOWNLOAD_MANAGERS = resultString.split("\n").filter(l => l.includes("|OK")).map(l => l.replace("|OK", ""));
                    }
                    await IOUtils.remove(resultPath, { ignoreAbsent: true });
                    this._log("解析后下载器列表", this.DOWNLOAD_MANAGERS);
                    Services.prefs.setStringPref(this.PREF_DOWNLOAD_MANAGERS, this.DOWNLOAD_MANAGERS.join(","));
                }
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

            // 检查 URL 是否支持外部下载器
            if (!isLinkSupportedByFlashgot(url)) {
                const reason = getUnsupportedReason(url);
                alerts(reason, LANG.format("error"));
                return;
            }

            const uri = Services.io.newURI(url);
            const { FLASHGOT_PATH, DL_FILE_STRUCTURE, REFERER_OVERRIDES, USERAGENT_OVERRIDES } = this;
            const { description, mBrowser, isPrivate } = options;
            let userAgent = (function (o, u, m, c) {
                for (let d of Object.keys(o)) {
                    // need to implement regex / subdomain process
                    if (u.host.endsWith(d)) return o[d];
                }
                return m?.browsingContext?.customUserAgent || c["@mozilla.org/network/protocol;1?name=http"].getService(Ci.nsIHttpProtocolHandler).userAgent;
            })(USERAGENT_OVERRIDES, uri, mBrowser, Cc);
            let referer = '', postData = '', fileName = '', extension = '', downloadPageReferer = '', downloadPageCookies = '';
            if (options.referer) {
                referer = options.referer;
            } else if (options.mBrowser) {
                const { mBrowser, mContentData } = options;
                referer = mBrowser.currentURI.spec;
                downloadPageReferer = mContentData.referrerInfo.originalReferrer.spec
            } else if (options.mLauncher) {
                const { mLauncher, mSourceContext } = options;
                downloadPageReferer = mSourceContext.currentURI.spec;
                downloadPageCookies = await gatherCookies(downloadPageReferer);
                fileName = options.fileName || mLauncher.suggestedFileName;
                try { extension = mLauncher.MIMEInfo.primaryExtension; } catch (e) { }
            }
            if (downloadPageReferer) {
                downloadPageCookies = await gatherCookies(downloadPageReferer);
            }
            let refMatched = domainMatch(uri.host, REFERER_OVERRIDES);
            if (refMatched) {
                referer = refMatched;
            }
            let uaMatched = domainMatch(uri.host, USERAGENT_OVERRIDES);
            if (uaMatched) {
                userAgent = uaMatched;
            }
            let initData, initArgs = [];
            if (this.NEWER_FLASHGOT) {
                // 新版的 JSON 格式，还没做完
                initData = {
                    dlcount: 1,
                    dmName: manager,
                    optype: "download", // 需要继续看源码
                    referer: referer,
                    dlpageReferer: downloadPageReferer,
                    dlpageCookies: downloadPageCookies,
                    userAgent: userAgent,
                    links: [
                        {
                            url: uri.spec,
                            desc: description || '',
                            cookies: await gatherCookies(uri.spec),
                            postData: postData,
                            filename: fileName,
                            extension: extension
                        }
                    ]
                }
                initData = JSON.stringify(initData);
            } else {
                // 旧版本 FlashGot 使用原有格式
                initData = replaceArray(DL_FILE_STRUCTURE, [
                    '{num}', '{download-manager}', '{is-private}', '{referer}', '{url}', '{description}', '{cookies}', '{post-data}',
                    '{filename}', '{extension}', '{download-page-referer}', '{download-page-cookies}', '{user-agent}'
                ], [
                    1, manager, isPrivate, referer, uri.spec, description || '', await gatherCookies(uri.spec), postData,
                    fileName, extension, downloadPageReferer, downloadPageCookies, userAgent
                ]);
            }
            this._log("生成 .dl.properties 内容", initData);
            const initFilePath = handlePath(`{TmpD}\\${hashText(uri.spec)}.dl.properties`);
            this._log("写入临时文件", initFilePath);
            await IOUtils.writeUTF8(initFilePath, initData);
            initArgs = [initFilePath];

            await new Promise((resolve, reject) => {
                this.exec(FLASHGOT_PATH, initArgs, {
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
            if (this.debug) {
                Services.wm.getMostRecentWindow("navigator:browser").console.log("DownloadPlus", ...args);
            }
        }
    }

    function isTrue (pref, defaultValue = true) {
        return Services.prefs.getBoolPref(pref, defaultValue) === true;
    }

    function getBool (pref, defaultValue = false) {
        return Services.prefs.getBoolPref(pref, defaultValue);
    }

    function setBool (pref, value) {
        Services.prefs.setBoolPref(pref, value);
    }

    /**
     * 获取所有盘符，用到 dll 调用，只能在 windows 下使用
     *
     * @system windows
     * @returns {Array<string>} 所有盘符数组
     */
    function getAllDrives () {
        if (!AppConstants.platform.startsWith("win")) {
            return [];
        }
        const lib = ctypes.open("kernel32.dll");
        const GetLogicalDriveStringsW = lib.declare('GetLogicalDriveStringsW', ctypes.winapi_abi, ctypes.unsigned_long, ctypes.uint32_t, ctypes.char16_t.ptr);
        const buffer = new (ctypes.ArrayType(ctypes.char16_t, 1024))();
        const returnValue = GetLogicalDriveStringsW(buffer.length, buffer);
        const resultLen = parseInt(returnValue.toString() || "0");
        let driveArray = [];
        if (!resultLen) {
            lib.close();
            return driveArray;
        }
        for (let i = 0; i < resultLen; i++) {
            driveArray[i] = buffer.addressOfElement(i).contents;
        }
        driveArray = driveArray.join('').split('\0').filter(item => item.length);
        lib.close();
        return driveArray;
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
     * @returns {Element}
     */
    function createEl (doc, type, attrs = {}) {
        const element = type.startsWith('html:') ? doc.createElementNS('http://www.w3.org/1999/xhtml', type) : doc.createXULElement(type);
        for (const key of Object.keys(attrs)) {
            if (key === 'innerHTML') {
                element.innerHTML = attrs[key];
            } else if (key.startsWith('on')) {
                element.addEventListener(key.slice(2).toLocaleLowerCase(), attrs[key]);
            } else {
                element.setAttribute(key, attrs[key]);
            }
        }
        return element;
    }

    /**
     * 复制文本到剪贴板
     *
     * @param {string} text 需要复制的文本
     */
    function copyText (text) {
        Cc["@mozilla.org/widget/clipboardhelper;1"].getService(Ci.nsIClipboardHelper).copyString(text);
    }

    /**
     * 从文件读取内容（使用 IOUtils）
     *
     * @param {Ci.nsIFile|string} fileOrPath 文件实例或路径
     * @param {string} encoding 编码 (支持 UTF-8, GBK, BIG5 等)
     * @returns {Promise<string>} 文件内容
     */
    async function readText (fileOrPath, encoding = "UTF-8") {
        let path;
        if (typeof fileOrPath == "string") {
            path = fileOrPath;
        } else {
            path = fileOrPath.path;
        }

        try {
            if (encoding.toUpperCase() === "UTF-8") {
                // IOUtils.readUTF8 专门用于 UTF-8 编码
                return await IOUtils.readUTF8(path);
            } else {
                // 对于其他编码，先读取字节再使用 TextDecoder 转换
                const bytes = await IOUtils.read(path);
                return new TextDecoder(encoding).decode(bytes);
            }
        } catch (e) {
            // 文件不存在或读取失败返回空字符串
            return "";
        }
    }

    /**
     * 弹出右下角提示
     *
     * @param {string} message 提示信息
     * @param {string} title 提示标题
     * @param {Function} callback 提示回调，可以不提供
     */
    function alerts (message, title, callback) {
        const alertsService = Cc["@mozilla.org/alerts-service;1"].getService(Ci.nsIAlertsService);
        const mTitle = title || LANG.format("app name");
        const mMessage = message + "";
        const callbackObject = callback ? {
            observe: function (subject, topic, data) {
                if ("alertclickcallback" != topic)
                    return;
                callback.call(null);
            }
        } : null;
        if (versionGE('147a1')) {
            let alert = new AlertNotification({
                imageURL: 'chrome://global/skin/icons/info.svg',
                title: mTitle,
                text: mMessage,
                textClickable: !!callbackObject,
            });
            alertsService.showAlert(alert, callbackObject?.observe);
        } else {
            alertsService.show(
                "chrome://global/skin/icons/info.svg", mTitle,
                mMessage, !!callbackObject, "", callbackObject);
        }
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
     * @returns {string} 哈希值
     */
    function hashText (text, type) {
        if (!(typeof text == 'string' || text instanceof String)) {
            text = "";
        }

        // Bug 1851797 - Remove nsIScriptableUnicodeConverter convertToByteArray and convertToInputStream
        const data = new TextEncoder("utf-8").encode(text);

        if (Ci.nsICryptoHash[type]) {
            type = Ci.nsICryptoHash[type]
        } else {
            type = 2;
        }
        const hasher = Cc["@mozilla.org/security/hash;1"].createInstance(
            Ci.nsICryptoHash
        );

        hasher.init(type);
        hasher.update(data, data.length);
        const hash = hasher.finish(false);

        function toHexString (charCode) {
            return ("0" + charCode.toString(16)).slice(-2);
        }

        return Array.from(hash, (c, i) => toHexString(hash.charCodeAt(i))).join("");
    }

    function getMD5 (filePath) {
        try {
            var file = Cc["@mozilla.org/file/local;1"].createInstance(Ci.nsIFile);
            file.initWithPath(filePath);

            if (!file.exists() || !file.isFile()) {
                return "檔案不存在或不是檔案";
            }

            // 開啟檔案輸入流
            var fis = Cc["@mozilla.org/network/file-input-stream;1"]
                .createInstance(Ci.nsIFileInputStream);
            fis.init(file, 0x01, 0x04, 0);  // 唯讀 + 正常權限

            // 用 scriptable 包裝，才能呼叫 read()
            var sis = Cc["@mozilla.org/scriptableinputstream;1"]
                .createInstance(Ci.nsIScriptableInputStream);
            sis.init(fis);

            // 初始化 MD5 hasher
            var ch = Cc["@mozilla.org/security/hash;1"]
                .createInstance(Ci.nsICryptoHash);
            ch.init(ch.MD5);

            const CHUNK_SIZE = 8192;  // 8KB 一塊，記憶體友好

            while (true) {
                let available = sis.available();
                if (available <= 0) break;

                let toRead = Math.min(available, CHUNK_SIZE);
                let chunk = sis.read(toRead);  // ← 這裡用 sis.read()，返回 string (binary safe)

                // 轉成 byte array 給 hasher
                let bytes = new Uint8Array(toRead);
                for (let i = 0; i < toRead; i++) {
                    bytes[i] = chunk.charCodeAt(i) & 0xff;
                }

                ch.update(bytes, toRead);
            }

            sis.close();
            fis.close();

            let rawHash = ch.finish(false);
            let hex = "";
            for (let i = 0; i < rawHash.length; i++) {
                let c = rawHash.charCodeAt(i) & 0xff;
                hex += ("0" + c.toString(16)).slice(-2);
            }

            return hex.toLowerCase();

        } catch (ex) {
            return "錯誤：" + ex;
        }
    }

    /**
     * 文本串替换
     *
     * @param {string} replaceString 需要处理的文本串
     * @param {Array} find 需要被替换的文本串
     * @param {Array} replace 替换的文本串
     * @returns {string} 替换后的文本串
     */
    function replaceArray (replaceString, find, replace) {
        for (let i = 0; i < find.length; i++) {
            const regex = new RegExp(find[i], "g");
            replaceString = replaceString.replace(regex, replace[i]);
        }
        return replaceString;
    }

    /**
     * 收集 cookie 并保存到文件（使用 IOUtils）
     *
     * @param {string} link 链接
     * @param {boolean} saveToFile 是否保存到文件
     * @param {Function|string|undefined} filter Cookie 过滤器
     * @returns {Promise<string>} Cookie 字符串或文件路径
     */
    async function gatherCookies (link, saveToFile = false, filter) {
        if (!link || !/^https?:\/\//.test(link)) return "";

        const uri = Services.io.newURI(link, null, null);
        let cookies = Services.cookies.getCookiesFromHost(uri.host, {});

        // Apply filter if specified and valid
        if (Array.isArray(filter) && filter.length > 0) {
            cookies = cookies.filter(cookie => cookie && cookie.name && filter.includes(cookie.name));
        }

        if (saveToFile) {
            const cookieSavePath = handlePath("{TmpD}");
            const cookieString = cookies.map(formatCookie).join('');
            const filePath = `${cookieSavePath}\\${uri.host}.txt`;

            try {
                // 使用 IOUtils 写入文件，自动处理文件创建和覆盖
                await IOUtils.writeUTF8(filePath, cookieString);
                return filePath;
            } catch (e) {
                console.error("保存 Cookie 文件失败:", e);
                return "";
            }
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