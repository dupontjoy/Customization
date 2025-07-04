---使用方法---

- 运行mpv-install.bat可设置格式关联。
- 运行update-mpv.bat更新mpv.exe主程序、ffmpege.exe和脚本。
- 自行修改Run_yt-dlp.bat和yt-dlp.conf中的浏览器路径。

---文件夹结构---

- installer文件夹：installer文件夹 放到 mpv.exe所在文件夹。运行 mpv-install.bat可设置格式关联。
- portable_config设置文件：portable_config文件夹。放到 mpv.exe所在文件夹。
- yt-dlp.exe：下载视频和在线看视频如B站必需。放到 mpv.exe所在文件夹。
- yt-dlp.conf：用yt-dlp在线看视频如B站时获取浏览器cookie和设置分辨率。放到 mpv.exe所在文件夹。
- ffmpeg.exe：下载视频和合并视频必需。放到 mpv.exe所在文件夹。
- Run_yt-dlp.bat：调用yt-dlp.exe下载视频，需输入视频链接和分辨率。放到 mpv.exe所在文件夹。

---文件结构---

主要设置文件带中文注释，可自行修改。使用记事本等文本编辑器打开，推荐notepad2

- 快捷键设置：mpv\portable_config\input.conf
- 播放器设置：mpv\portable_config\mpv.conf
- 脚本：mpv\portable_config\scripts\
- 脚本设置：mpv\portable_config\script-opts\
- 着色器：mpv\portable_config\shaders\
- 字体：mpv\portable_config\fonts\

portable_config预置脚本：

 - autoload 自动加载同级目录的文件
 - stats 统计数据
 - fix-avsync 修复切换音轨时伴随的视频冻结卡顿的问题
 - SmartCopyPaste ctrl+v粘贴链接在线播放，需配合yt-dlp
 - quality-menu.lua 切换 ytdl 视频/音频质量的 OSD 交互式菜单（视频v，音频a）
 - uosc：美化版UI
 
---常用快捷键---

 - space 播放/暂停
 - enter 切换全屏
 - INS   打开控制台并输入loadfile，便于之后使用shift+INS或ctrl+v粘贴链接
 - PgUp  上一个文件
 - PgDn  下一个文件
 - tab   切换统计信息
 - v     切换视频质量
 - a     切换音频轨道
 - m     切换静音
 - t     切换置顶
 - l     播放列表
 - s     切换字幕
 - c     切换章节
 - i     上移字幕
 - k     下移字幕
 - ` 	   打开控制台，ESC退出
 - \     显示播放进度
 - /     复原字幕位置&大小&延迟 与 音频延迟
 
---网站索引---

- mpv官网：https://mpv.io
- mpv windows版下载：https://github.com/shinchiro/mpv-winbuild-cmake
- mpv windows版下载：https://github.com/zhongfly/mpv-winbuild
- mpv wiki用户脚本：https://github.com/mpv-player/mpv/wiki/User-Scripts
- mpv-player/scripts：https://github.com/mpv-player/mpv/wiki/User-Scripts
- mpv-config/scripts：https://github.com/dyphire/mpv-config/tree/master/scripts
- 文档部分中文翻译1：https://hooke007.github.io/official_man/mpv.html
- 文档部分中文翻译2：https://www.bilibili.com/read/readlist/rl617174
- uosc：https://github.com/tomasklaen/uosc/releases
