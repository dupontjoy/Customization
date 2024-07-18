//2024.07.16


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
user_pref("privacy.userContext.enabled", true);//启用身份标签页
user_pref("signon.rememberSignons", false);//不保存密码
user_pref("browser.shell.checkDefaultBrowser", false);//总是检查是否为默认浏览器(否)
user_pref("browser.search.suggest.enabled", false);//禁用搜索建议
user_pref("privacy.globalprivacycontrol.enabled", true);//要求网站不许出售或共享我的数据
user_pref("privacy.donottrackheader.enabled", true);//请勿跟踪(一律发送)
user_pref("dom.private-attribution.submission.enabled", false);//允许网站进行隐私保护下的广告监测（否）
user_pref("datareporting.healthreport.uploadEnabled", false);//允许 Firefox 向 Mozilla 发送技术信息及交互数据（否）
user_pref("browser.preferences.moreFromMozilla", false);//更多Mozilla产品
user_pref("media.autoplay.default", 0);//自动播放默认值：阻止音频和视频


//字体语言编码
user_pref("font.name.serif.zh-CN", "Arial");//衬线字体
user_pref("font.name.sans-serif.zh-CN", "Arial");//无衬线字体
user_pref("font.name.monospace.zh-CN", "Arial");//等宽字体

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
user_pref("browser.safebrowsing.downloads.enabled", false);//关闭下载安全检查，解决下载卡在最后一秒的问题
user_pref("browser.safebrowsing.downloads.remote.enabled", false);//关闭下载安全检查（远程）
user_pref("browser.safebrowsing.downloads.remote.url", "");//关闭下载安全检查（远程)
user_pref("browser.safebrowsing.downloads.remote.block_dangerous", false);//关闭下载安全检查（远程）
user_pref("browser.safebrowsing.downloads.remote.block_dangerous_host", false);//关闭下载安全检查（远程）
user_pref("dom.block_download_in_sandboxed_iframes", false);//阻止下载功能（沙盒框架）[否]
user_pref("dom.block_download_insecure", false);//阻止下载功能（不安全，潜在风险）[否]


//*==========网络相关==========*//
user_pref("security.enterprise_roots.enabled", true);//未连接：有潜在的安全问题
user_pref("security.insecure_field_warning.contextual.enabled", false);//未连接：有潜在的安全问题
user_pref("security.certerrors.permanentOverride", false);//未连接：有潜在的安全问题
user_pref("network.stricttransportsecurity.preloadlist", false);//未连接：有潜在的安全问题
user_pref("media.wmf.hevc.enabled", 1);//Enable HEVC support via the windows media foundation


//*==========FX其它类==========*//

//去除附加组中的"推荐扩展"
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("extensions.htmlaboutaddons.discover.enabled", false);

//书签相关
user_pref("browser.bookmarks.max_backups", 1);//书签最大备份数目


//自定义CSS（chrome文件夹）
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);//69以后自动加载 userChrome.ss 和 userContent.css

//禁用自带翻译
user_pref("browser.translations.automaticallyPopup", false);
user_pref("browser.translations.panelShown", false);

//實验性
user_pref("javascript.options.experimental.shadow_realms", true);//贴吧fx内存问题的回复，试一试
user_pref("javascript.options.experimental.weakrefs.expose_cleanupSome", true);
user_pref("browser.preferences.experimental", true);//设置中添加实验性标签


//单项, 未分类
user_pref("browser.promo.pin.enabled", false);//弹窗推广-固定标签页
user_pref("browser.promo.focus.enabled", false);//弹窗推广-歡迎页
user_pref("browser.startup.homepage_override.mstone", "ignore");//启动时不弹出"What's New"页面
user_pref("extensions.ui.lastCategory", "addons://list/extension");//默认打开“扩展”项
user_pref("browser.aboutConfig.showWarning", false);//AboutConfig警告
user_pref("browser.safebrowsing.malware.enabled", false);//关闭欺诈内容和危险软件防护（谷歌网站黑名单）
user_pref("browser.safebrowsing.phishing.enabled", false);//关闭欺诈内容和危险软件防护（谷歌网站黑名单）
user_pref("browser.urlbar.trimURLs", false);//地址栏显示 http://
user_pref("ui.scrollToClick", 1); //点击滚动条将能够直接让你调转到页面上你想要查看的那点
user_pref("extensions.pocket.enabled", false);//自带pocket(禁用,功能太简略,无法离线查看列表)
user_pref("browser.sessionstore.interval", 3600000);//(单位: ms)限制recovery.js文件的写入操作: 默认15s, 改为1小時
user_pref("browser.menu.showViewImageInfo", true);//显示查看图像信息菜单
user_pref("security.insecure_field_warning.contextual.enabled", false);//隐藏输入框不安全提示（配合css）
user_pref("media.videocontrols.picture-in-picture.improved-video-controls.enabled", true);//画中画显示进度条



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
user_pref("browser.newtabpage.pinned", "[{\"url\":\"https://hbr.org/\",\"title\":\"HBR\"},{\"url\":\"http://www.economist.com/\",\"title\":\"Economist\"},{\"url\":\"https://www.wsj.com/\",\"title\":\"wsj\"},{\"url\":\"https://www.reddit.com/\",\"title\":\"红迪\"},{\"url\":\"https://www.youtube.com/\",\"title\":\"Youtube\"},{\"url\":\"https://t.bilibili.com/\",\"title\":\"Bilibili\"},{\"url\":\"https://tophub.today/c/news\",\"title\":\"今日热榜\"},{\"url\":\"https://momoyu.cc/\",\"title\":\"摸摸鱼\"},{\"url\":\"https://www.guancha.cn/\",\"title\":\"观察者网\"},{\"url\":\"http://www.wyzxwk.com/\",\"title\":\"乌有之乡\"},{\"url\":\"https://www.zhihu.com/\",\"title\":\"知乎\"},{\"url\":\"http://bbs.kafan.cn/forum-215-1.html\",\"title\":\"卡饭\"},{\"url\":\"https://www.ithome.com/\",\"title\":\"IT之家\"},{\"url\":\"https://tieba.baidu.com/\",\"title\":\"贴吧\"},{\"url\":\"https://36kr.com/\",\"title\":\"36Kr\"},{\"url\":\"https://bbs.hupu.com/\",\"title\":\"虎扑\"}]");
user_pref("browser.newtabpage.activity-stream.topSitesRows", 2);//常用网站2行展示
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);//不展示只言片语
user_pref("browser.newtabpage.activity-stream.feeds.section.highlights", false);//不展示集锦
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);//不展示赞助商网站
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);//在您浏览时推荐扩展(否)
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);//在您浏览时推荐新功能(否)

