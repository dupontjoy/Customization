//2025.08.10


/*
# pref(key,value) 会覆盖默认设置,在删除之后会恢复默认设置.
# user_pref(key,value)等同于从about:config修改,删除之后,修改的设置仍然有效.
*/

/*************************************************************************************
# Note:
- OurSticky扩展导致百度网盘离线下载添加BT种子时窗口无法弹出
- Don't Fuck with my Scrolling脚本会导致某些直播视频无法加载
- Https only模式会导致ic后台站点无法切换
- Firefox Beta版surfingkeys容易出问题
- Stylus选项>启用CSP补丁不要开启，会导致知乎等页面加载样式异常
 *************************************************************************************/

/******************************************************************************************
 *这里是通用设置。
 *******************************************************************************************/

//*==========选项卡里的设置==========*//
user_pref("sidebar.revamp", false);//显示侧栏（否）
user_pref("sidebar.visibility", "hide-sidebar");//显示侧栏按钮（否）
user_pref("privacy.userContext.enabled", true);//启用身份标签页
user_pref("signon.rememberSignons", false);//不保存密码
user_pref("browser.shell.checkDefaultBrowser", false);//总是检查是否为默认浏览器(否)
user_pref("browser.search.suggest.enabled", false);//禁用搜索建议
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);//使用推荐的性能设置（否），以启用硬件加速
user_pref("dom.private-attribution.submission.enabled", false);//允许网站进行隐私保护下的广告监测（否）
user_pref("privacy.globalprivacycontrol.enabled", true);//要求网站不许出售或共享我的数据（是）
user_pref("browser.preferences.moreFromMozilla", false);//更多Mozilla产品
user_pref("media.autoplay.default", 0);//自动播放默认值：阻止音频和视频
user_pref("datareporting.healthreport.uploadEnabled", false);//向 Mozilla 发送技术与交互数据
user_pref("datareporting.usage.uploadEnabled", false);//向 Mozilla 发送每日使用情况报告

//字体语言编码
user_pref("font.name.serif.zh-CN", "Arial");//衬线字体
user_pref("font.name.sans-serif.zh-CN", "Arial");//无衬线字体
user_pref("font.name.monospace.zh-CN", "Arial");//等宽字体
user_pref("layout.css.unicode-range.enabled", true);//简体(CN/SG)开启unicode-range


//*==========标签相关==========*//
user_pref("browser.tabs.loadBookmarksInTabs", true);//新标签打开书签
user_pref("browser.tabs.warnOnClose", false);//关闭多个标签时不提示
user_pref("browser.tabs.warnOnCloseOtherTabs", false);//关闭其它标签时不提示
user_pref("browser.tabs.closeWindowWithLastTab", false);//关闭最后一个标签时不关闭Firefox
user_pref("browser.link.open_newwindow.restriction", 0);//单窗口模式(弹出窗口用标签打开)


//*==========下载相关==========*//
user_pref("browser.download.useDownloadDir", false);//下载时每次讯问我要存到何处
user_pref("browser.download.always_ask_before_handling_new_types", true);//Firefox如何处理其他文件：询问要打开还是保存文件
user_pref("browser.download.manager.scanWhenDone", false);//关闭下载结束后扫描
user_pref("dom.block_download_in_sandboxed_iframes", false);//阻止下载功能（沙盒框架）[否]
user_pref("dom.block_download_insecure", false);//阻止下载功能（不安全，潜在风险）[否]

//safebrowsing相关
user_pref("browser.safebrowsing.downloads.enabled", false);//关闭下载安全检查，解决下载卡在最后一秒的问题
user_pref("browser.safebrowsing.downloads.remote.enabled", false);//关闭下载安全检查（远程）
user_pref("browser.safebrowsing.downloads.remote.url", "");//关闭下载安全检查（远程)
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);//关闭下载安全检查（远程）
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);//关闭下载安全检查（远程）
user_pref("browser.safebrowsing.malware.enabled", false);//关闭欺诈内容和危险软件防护（谷歌网站黑名单）
user_pref("browser.safebrowsing.phishing.enabled", false);//关闭欺诈内容和危险软件防护（谷歌网站黑名单）


//*==========网络相关==========*//
user_pref("security.enterprise_roots.enabled", true);//未连接：有潜在的安全问题
user_pref("security.insecure_field_warning.contextual.enabled", false);//未连接：有潜在的安全问题
user_pref("security.certerrors.permanentOverride", false);//未连接：有潜在的安全问题
user_pref("network.stricttransportsecurity.preloadlist", false);//未连接：有潜在的安全问题


//*==========FX其它类==========*//
//去除附加组中的"推荐扩展"
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.htmlaboutaddons.discover.enabled", false);

//书签相关
user_pref("browser.bookmarks.max_backups", 2);//书签最大备份数目

//自定义CSS（chrome文件夹）
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);//69以后自动加载 userChrome.ss 和 userContent.css

//禁用自带翻译
user_pref("browser.translations.automaticallyPopup", false);
user_pref("browser.translations.panelShown", false);

//画中画
user_pref("media.videocontrols.picture-in-picture.improved-video-controls.enabled", true);//画中画显示进度条

//全屏播放動画
user_pref("full-screen-api.warning.timeout", 0); //双击设置为 0，关闭视频进入全屏时的提示
user_pref("full-screen-api.transition-duration.enter", "0 0"); //双击设置为 0 0，去除全屏模式的过渡动画–进入
user_pref("full-screen-api.transition-duration.leave", "0 0"); //双击设置为 0 0，去除全屏模式的过渡动画–退出

//AI功能，導致CPU 占用显著升高、电量迅速消耗
user_pref("browser.ml.chat.enabled", false);//关闭 AI 聊天功能
user_pref("browser.tabs.groups.smart.enabled", false);//关闭智能标签分组

//单项, 未分类
user_pref("browser.promo.pin.enabled", false);//弹窗推广-固定标签页
user_pref("browser.promo.focus.enabled", false);//弹窗推广-歡迎页
user_pref("browser.startup.homepage_override.mstone", "ignore");//启动时不弹出"What's New"页面
user_pref("extensions.ui.lastCategory", "addons://list/extension");//默认打开“扩展”项
user_pref("browser.aboutConfig.showWarning", false);//AboutConfig警告
user_pref("browser.urlbar.trimURLs", false);//地址栏显示 http://
user_pref("ui.scrollToClick", 1); //点击滚动条将能够直接让你调转到页面上你想要查看的那点
user_pref("extensions.pocket.enabled", false);//自带pocket(禁用,功能太简略,无法离线查看列表)
user_pref("browser.sessionstore.interval", 3600000);//(单位: ms)限制recovery.js文件的写入操作: 默认15s, 改为1小時
user_pref("browser.menu.showViewImageInfo", true);//显示查看图像信息菜单
user_pref("security.insecure_field_warning.contextual.enabled", false);//隐藏输入框不安全提示（配合css）
user_pref("dom.ipc.processPriorityManager.backgroundUsesEcoQoS", false);//关闭win系统的效能模式
user_pref("intl.icu4x.segmenter.enabled", false);//双击是选取一个短句
user_pref("extensions.screenshots.disabled", true);//禁用自带截图
user_pref("layout.css.system-ui.enabled", false);//解決小红书emoji显示错误问题


/******************************************************************************************
 *这里是个人设置。
 *******************************************************************************************/

//downloadplus脚本设置
user_pref("userChromeJS.downloadPlus.enableFlashgotIntergention", true);//启用 Flashgot 集成
user_pref("userChromeJS.downloadPlus.enableRename", true);//下载对话框启用改名功能


//*==========主页==========*//
user_pref("browser.startup.page", 1);//启动Firefox时显示主页
user_pref("browser.startup.homepage", "about:newtab");//首页
//标签页固定的网站(16个)
user_pref("browser.newtabpage.pinned", "[{\"url\":\"https://t.bilibili.com/\"},{\"url\":\"https://tophub.today/c/news\"},{\"url\":\"https://momoyu.cc/\"},{\"url\":\"https://www.guancha.cn/\"},{\"url\":\"http://www.wyzxwk.com/\"},{\"url\":\"https://www.sciencenet.cn/\"},{\"url\":\"https://www.ithome.com/\"},{\"url\":\"https://bbs.kafan.cn/forum-215-1.html\"},{\"url\":\"https://tieba.baidu.com/\"},{\"url\":\"https://bbs.hupu.com/\"},{\"url\":\"https://www.jiemian.com/\"},{\"url\":\"https://www.zhihu.com/\"},{\"url\":\"https://www.youtube.com/\"},{\"url\":\"http://www.washingtonpost.com/\"},{\"url\":\"https://hbr.org/\"},{\"url\":\"https://www.reddit.com/\"}]");
user_pref("browser.newtabpage.activity-stream.topSitesRows", 2);//常用网站2行展示
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);//不展示只言片语
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);//不展示集锦
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);//不展示赞助商网站
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);//在您浏览时推荐扩展(否)
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);//在您浏览时推荐新功能(否)

