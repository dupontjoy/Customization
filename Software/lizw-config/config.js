// 全局常量配置
const PROXY_URL = '/proxy/';    // 适用于 Cloudflare, Netlify (带重写), Vercel (带重写)
// const HOPLAYER_URL = 'https://hoplayer.com/index.html';
const SEARCH_HISTORY_KEY = 'videoSearchHistory';
const MAX_HISTORY_ITEMS = 5;

// 密码保护配置
// 注意：PASSWORD 环境变量是必需的，所有部署都必须设置密码以确保安全
const PASSWORD_CONFIG = {
    localStorageKey: 'passwordVerified',  // 存储验证状态的键名
    verificationTTL: 90 * 24 * 60 * 60 * 1000  // 验证有效期（90天，约3个月）
};

// 网站信息配置
const SITE_CONFIG = {
    name: 'LibreTV',
    url: 'https://libretv.is-an.org',
    description: '免费在线视频搜索与观看平台',
    logo: 'image/logo.png',
    version: '1.0.3'
};

// API站点配置
const API_SITES = {
        "api_1": {
            "name": "TV-1080资源",
            "api": "https://api.1080zyku.com/inc/api_mac10.php",
            "detail": "https://api.1080zyku.com"
        },
        "api_3": {
            "name": "TV-360资源",
            "api": "https://360zy.com/api.php/provide/vod",
            "detail": "https://360zy.com"
        },
        "api_4": {
            "name": "TV-CK资源",
            "api": "https://ckzy.me/api.php/provide/vod",
            "detail": "https://ckzy.me"
        },
        "api_5": {
            "name": "TV-U酷资源",
            "api": "https://api.ukuapi.com/api.php/provide/vod",
            "detail": "https://api.ukuapi.com"
        },
        "api_6": {
            "name": "TV-U酷资源",
            "api": "https://api.ukuapi88.com/api.php/provide/vod",
            "detail": "https://api.ukuapi88.com"
        },
        "api_7": {
            "name": "TV-ikun资源",
            "api": "https://ikunzyapi.com/api.php/provide/vod",
            "detail": "https://ikunzyapi.com"
        },
        "api_8": {
            "name": "TV-wujinapi无尽",
            "api": "https://api.wujinapi.cc/api.php/provide/vod",
            "detail": ""
        },
        "api_9": {
            "name": "TV-丫丫点播",
            "api": "https://cj.yayazy.net/api.php/provide/vod",
            "detail": "https://cj.yayazy.net"
        },
        "api_11": {
            "name": "TV-卧龙点播",
            "api": "https://collect.wolongzyw.com/api.php/provide/vod",
            "detail": "https://collect.wolongzyw.com"
        },
        "api_12": {
            "name": "TV-卧龙资源",
            "api": "https://collect.wolongzy.cc/api.php/provide/vod",
            "detail": ""
        },
        "api_13": {
            "name": "TV-卧龙资源",
            "api": "https://wolongzyw.com/api.php/provide/vod",
            "detail": "https://wolongzyw.com"
        },
        "api_14": {
            "name": "TV-天涯资源",
            "api": "https://tyyszy.com/api.php/provide/vod",
            "detail": "https://tyyszy.com"
        },
        "api_15": {
            "name": "TV-如意资源",
            "api": "https://cj.rycjapi.com/api.php/provide/vod",
            "detail": ""
        },
        "api_16": {
            "name": "TV-小猫咪资源",
            "api": "https://zy.xmm.hk/api.php/provide/vod",
            "detail": "https://zy.xmm.hk"
        },
        "api_18": {
            "name": "TV-无尽资源",
            "api": "https://api.wujinapi.com/api.php/provide/vod",
            "detail": ""
        },
        "api_19": {
            "name": "TV-无尽资源",
            "api": "https://api.wujinapi.me/api.php/provide/vod",
            "detail": ""
        },
        "api_20": {
            "name": "TV-无尽资源",
            "api": "https://api.wujinapi.net/api.php/provide/vod",
            "detail": ""
        },
        "api_21": {
            "name": "TV-旺旺短剧",
            "api": "https://wwzy.tv/api.php/provide/vod",
            "detail": "https://wwzy.tv"
        },
        "api_22": {
            "name": "TV-旺旺资源",
            "api": "https://api.wwzy.tv/api.php/provide/vod",
            "detail": "https://api.wwzy.tv"
        },
        "api_23": {
            "name": "TV-暴风资源",
            "api": "https://bfzyapi.com/api.php/provide/vod",
            "detail": ""
        },
        "api_24": {
            "name": "TV-最大点播",
            "api": "http://zuidazy.me/api.php/provide/vod",
            "detail": "http://zuidazy.me"
        },
        "api_25": {
            "name": "TV-最大资源",
            "api": "https://api.zuidapi.com/api.php/provide/vod",
            "detail": "https://api.zuidapi.com"
        },
        "api_26": {
            "name": "TV-樱花资源",
            "api": "https://m3u8.apiyhzy.com/api.php/provide/vod",
            "detail": ""
        },
        "api_27": {
            "name": "TV-步步高资源",
            "api": "https://api.yparse.com/api/json",
            "detail": ""
        },
        "api_28": {
            "name": "TV-牛牛点播",
            "api": "https://api.niuniuzy.me/api.php/provide/vod",
            "detail": "https://api.niuniuzy.me"
        },
        "api_29": {
            "name": "TV-电影天堂资源",
            "api": "http://caiji.dyttzyapi.com/api.php/provide/vod",
            "detail": "http://caiji.dyttzyapi.com"
        },
        "api_31": {
            "name": "TV-百度云资源",
            "api": "https://api.apibdzy.com/api.php/provide/vod",
            "detail": "https://api.apibdzy.com"
        },
        "api_32": {
            "name": "TV-神马云",
            "api": "https://api.1080zyku.com/inc/apijson.php/",
            "detail": "https://api.1080zyku.com"
        },
        "api_33": {
            "name": "TV-索尼资源",
            "api": "https://suoniapi.com/api.php/provide/vod",
            "detail": ""
        },
        "api_34": {
            "name": "TV-红牛资源",
            "api": "https://www.hongniuzy2.com/api.php/provide/vod",
            "detail": "https://www.hongniuzy2.com"
        },
        "api_35": {
            "name": "TV-茅台资源",
            "api": "https://caiji.maotaizy.cc/api.php/provide/vod",
            "detail": "https://caiji.maotaizy.cc"
        },
        "api_37": {
            "name": "TV-豆瓣资源",
            "api": "https://caiji.dbzy.tv/api.php/provide/vod",
            "detail": "https://caiji.dbzy.tv"
        },
        "api_38": {
            "name": "TV-豆瓣资源",
            "api": "https://dbzy.tv/api.php/provide/vod",
            "detail": "https://dbzy.tv"
        },
        "api_40": {
            "name": "TV-速博资源",
            "api": "https://subocaiji.com/api.php/provide/vod",
            "detail": ""
        },
        "api_41": {
            "name": "TV-量子资源",
            "api": "https://cj.lziapi.com/api.php/provide/vod",
            "detail": ""
        },
        "api_44": {
            "name": "TV-閃電资源",
            "api": "https://sdzyapi.com/api.php/provide/vod",
            "detail": "https://sdzyapi.com"
        },
        "api_45": {
            "name": "TV-非凡资源",
            "api": "https://cj.ffzyapi.com/api.php/provide/vod",
            "detail": "https://cj.ffzyapi.com"
        },
        "api_46": {
            "name": "TV-飘零资源",
            "api": "https://p2100.net/api.php/provide/vod",
            "detail": "https://p2100.net"
        },
        "api_47": {
            "name": "TV-魔爪资源",
            "api": "https://mozhuazy.com/api.php/provide/vod",
            "detail": "https://mozhuazy.com"
        },
        "api_48": {
            "name": "TV-魔都动漫",
            "api": "https://caiji.moduapi.cc/api.php/provide/vod",
            "detail": "https://caiji.moduapi.cc"
        },
        "api_49": {
            "name": "TV-魔都资源",
            "api": "https://www.mdzyapi.com/api.php/provide/vod",
            "detail": "https://www.mdzyapi.com"
        },
        "api_50": {
            "name": "TV-黑木耳",
            "api": "https://json.heimuer.xyz/api.php/provide/vod",
            "detail": "https://json.heimuer.xyz"
        },
        "api_51": {
            "name": "TV-黑木耳点播",
            "api": "https://json02.heimuer.xyz/api.php/provide/vod",
            "detail": "https://json02.heimuer.xyz"
        },
        "ffzynew": {
            "api": "https://api.ffzyapi.com/api.php/provide/vod",
            "name": "非凡影视new",
            "detail": "http://ffzy5.tv"
        },
        "jisu": {
            "api": "https://jszyapi.com/api.php/provide/vod",
            "name": "极速资源",
            "detail": "https://jszyapi.com"
        },
        "mozhua": {
            "api": "https://mozhuazy.com/api.php/provide/vod",
            "name": "魔爪资源"
        },
        "mdzy": {
            "api": "https://www.mdzyapi.com/api.php/provide/vod",
            "name": "魔都资源"
        },
        "liangziziyuan": {
            "api": "https://cj.lziapi.com/api.php/provide/vod",
            "name": "量子资源"
        },
        "aiduanjucc": {
            "api": "https://www.aiduanju.cc/",
            "name": "爱短剧.cc"
        },
        "huaweiba": {
            "api": "https://huawei8.live/api.php/provide/vod",
            "name": "华为吧资源"
        },
        "taopian": {
            "api": "https://taopianapi.com/cjapi/sda/vod",
            "name": "淘片资源"
        },
        "hongniuziyuan": {
            "api": "https://www.hongniuzy3.com/api.php/provide/vod",
            "name": "红牛资源"
        },
        "suonisandian": {
            "api": "https://xsd.sdzyapi.com/api.php/provide/vod",
            "name": "索尼-闪电资源"
        },
        "yayaziyuan": {
            "api": "https://cj.yayazy.net/api.php/provide/vod",
            "name": "鸭鸭资源"
        },
        "fengchao": {
            "api": "https://api.fczy888.me/api.php/provide/vod",
            "name": "蜂巢片库"
        },
        "jinmaziyuan2": {
            "api": "https://api.jmzy.com/api.php/provide/vod",
            "name": "金马资源网"
        },
        "dadiziy": {
            "api": "https://dadiapi.com/api.php/provide/vod",
            "name": "大地资源网络"
        },
        "xiaojiziy": {
            "api": "https://api.xiaojizy.live/provide/vod",
            "name": "小鸡资源"
        },
        "kauicheziyuan": {
            "api": "https://caiji.kuaichezy.org/api.php/provide",
            "name": "快车资源阿"
        },
        "lajiaoziyu": {
            "api": "https://apilj.com/api.php/provide",
            "name": "辣椒资源黄黄"
        },
        "youzhidianying": {
            "api": "https://api.yzzy-api.com/inc/ldg_api_all.php/provide/vod",
            "name": "优质资源库1080zyk6.com高清"
        },
        "iqiyi": {
            "api": "https://www.iqiyizyapi.com/api.php/provide/vod",
            "name": "iqiyi资源"
        },
          "qiqiqiqi": {
            "api": "https://www.qiqidys.com/api.php/provide/vod/",
            "name": "七七影视"
        },
        "yingshigongchang": {
            "api": "https://cj.lziapi.com/api.php/provide/vod/",
            "name": "影视工厂"
        },
        "fantuanyingshi": {
            "api": "https://www.fantuan.tv/api.php/provide/vod/",
            "name": "饭团影视"
        },
    testSource: {
        api: 'https://www.example.com/api.php/provide/vod',
        name: '空内容测试源',
        adult: true
    },
};

// 定义合并方法
function extendAPISites(newSites) {
    Object.assign(API_SITES, newSites);
}

// 暴露到全局
window.API_SITES = API_SITES;
window.extendAPISites = extendAPISites;


// 添加聚合搜索的配置选项
const AGGREGATED_SEARCH_CONFIG = {
    enabled: true,             // 是否启用聚合搜索
    timeout: 8000,            // 单个源超时时间（毫秒）
    maxResults: 10000,          // 最大结果数量
    parallelRequests: true,   // 是否并行请求所有源
    showSourceBadges: true    // 是否显示来源徽章
};

// 抽象API请求配置
const API_CONFIG = {
    search: {
        // 只拼接参数部分，不再包含 /api.php/provide/vod/
        path: '?ac=videolist&wd=',
        pagePath: '?ac=videolist&wd={query}&pg={page}',
        maxPages: 50, // 最大获取页数
        headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            'Accept': 'application/json'
        }
    },
    detail: {
        // 只拼接参数部分
        path: '?ac=videolist&ids=',
        headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
            'Accept': 'application/json'
        }
    }
};

// 优化后的正则表达式模式
const M3U8_PATTERN = /\$https?:\/\/[^"'\s]+?\.m3u8/g;

// 添加自定义播放器URL
const CUSTOM_PLAYER_URL = 'player.html'; // 使用相对路径引用本地player.html

// 增加视频播放相关配置
const PLAYER_CONFIG = {
    autoplay: true,
    allowFullscreen: true,
    width: '100%',
    height: '600',
    timeout: 15000,  // 播放器加载超时时间
    filterAds: true,  // 是否启用广告过滤
    autoPlayNext: true,  // 默认启用自动连播功能
    adFilteringEnabled: true, // 默认开启分片广告过滤
    adFilteringStorage: 'adFilteringEnabled' // 存储广告过滤设置的键名
};

// 增加错误信息本地化
const ERROR_MESSAGES = {
    NETWORK_ERROR: '网络连接错误，请检查网络设置',
    TIMEOUT_ERROR: '请求超时，服务器响应时间过长',
    API_ERROR: 'API接口返回错误，请尝试更换数据源',
    PLAYER_ERROR: '播放器加载失败，请尝试其他视频源',
    UNKNOWN_ERROR: '发生未知错误，请刷新页面重试'
};

// 添加进一步安全设置
const SECURITY_CONFIG = {
    enableXSSProtection: true,  // 是否启用XSS保护
    sanitizeUrls: true,         // 是否清理URL
    maxQueryLength: 100,        // 最大搜索长度
    // allowedApiDomains 不再需要，因为所有请求都通过内部代理
};

// 添加多个自定义API源的配置
const CUSTOM_API_CONFIG = {
    separator: ',',           // 分隔符
    maxSources: 5,            // 最大允许的自定义源数量
    testTimeout: 5000,        // 测试超时时间(毫秒)
    namePrefix: 'Custom-',    // 自定义源名称前缀
    validateUrl: true,        // 验证URL格式
    cacheResults: true,       // 缓存测试结果
    cacheExpiry: 5184000000,  // 缓存过期时间(2个月)
    adultPropName: 'isAdult' // 用于标记成人内容的属性名
};

// 隐藏内置黄色采集站API的变量
const HIDE_BUILTIN_ADULT_APIS = false;
