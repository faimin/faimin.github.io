# 工具


<!--more-->

## 简介

个人平时收藏的一些`Mac`平台开源免费的工具，基本都支持`homebrew`安装。


## 搜索引擎

- [SearX](https://searx.space/)
- [Neeva](https://neeva.com/)
- [Qwant](https://www.qwant.com/)
- [Yandex](https://yandex.com/)
- [grep.app](https://grep.app/)
- [phind](https://www.phind.com/)

------

## 软件

### 包管理

- [Homebrew](https://brew.sh/index_zh-cn)：`Mac`端的包管理工具，`PC`端的有`Scoop`、`Chocolate`、`Winget`


### 终端

- [iTerm2](https://iterm2.com/)
- [Alacritty](https://github.com/alacritty/alacritty)
- [WezTerm](https://github.com/wez/wezterm)
- [kitty](https://github.com/kovidgoyal/kitty)
- [WindTerm](https://github.com/kingToolbox/WindTerm)
- [Tabby](https://github.com/Eugeny/tabby)


### 效率

- [PopClip](https://apps.apple.com/cn/app/popclip/id445189367?mt=12)
- [Alfred](https://www.alfredapp.com/)
    - [alfred-workflows](https://github.com/zenorocha/alfred-workflows)
- [Hammerspoon](http://hammerspoon.org/)

    ```lua
    -------------- 输入法控制 -----------------

    local function Chinese()
        -- 搜狗输入法
        hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
        -- 简体拼音
        --hs.keycodes.currentSourceID("com.apple.inputmethod.SCIM.ITABC")
    end

    local function English()
        -- ABC
        hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
    end

    -- app to expected ime config
    -- app和对应的输入法
    local app2Ime = {
        { '/Applications/System Preferences.app', 'English' },
        { '/System/Library/CoreServices/Finder.app', 'Chinese' },
        { '/Applications/iTerm.app', 'Chinese' },
        { '/Applications/Visual Studio Code.app', 'Chinese' },
        { '/Applications/Xcode.app', 'Chinese' },
        { '/Applications/Microsoft Edge.app', 'Chinese' },
        { '/Applications/Kim.app', 'Chinese' },
        { '/Applications/WeChat.app', 'Chinese' },
        { '/Applications/QQ.app', 'Chinese' },
        { '/Applications/MarkText.app', 'Chinese' },
        { '/Applications/Bob.app', 'Chinese' },
        { '/Applications/NeteaseMusic.app', 'Chinese' },
    }

    function updateFocusAppInputMethod()
        local ime = 'Chinese'
        local focusAppPath = hs.window.frontmostWindow():application():path()
        for index, app in pairs(app2Ime) do
            local appPath = app[1]
            local expectedIme = app[2]

            if focusAppPath == appPath then
                ime = expectedIme
                break
            end
        end

        if ime == 'English' then
            English()
        else
            Chinese()
        end
    end

    -- helper hotkey to figure out the app path and name of current focused window
    -- 当选中某窗口按下ctrl+command+.时会显示应用的路径等信息
    hs.hotkey.bind({ 'ctrl', 'cmd' }, ".", function()
        hs.alert.show("App path:        "
            .. hs.window.focusedWindow():application():path()
            .. "\n"
            .. "App name:      "
            .. hs.window.focusedWindow():application():name()
            .. "\n"
            .. "IM source id:  "
            .. hs.keycodes.currentSourceID())
    end)

    -- Handle cursor focus and application's screen manage.
    -- 窗口激活时自动切换输入法
    function applicationWatcher(appName, eventType, appObject)
        if (eventType == hs.application.watcher.activated or eventType == hs.application.watcher.launched) then
            updateFocusAppInputMethod()
        end
    end

    appWatcher = hs.application.watcher.new(applicationWatcher)
    appWatcher:start()
    ```

- [xbar](https://github.com/matryer/xbar)
- [DevToys](https://github.com/ObuchiYuki/DevToysMac)
- [OnlySwitch](https://github.com/jacklandrin/OnlySwitch)


### 系统优化

- [Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)
- [AppCleaner](https://freemacsoft.net/appcleaner/)


### 系统监控

- [Stats](https://github.com/exelban/stats)
- [eul](https://github.com/gao-sun/eul)
- [MenuMeters](https://github.com/yujitach/MenuMeters)


### 下载

- [Motrix](https://github.com/agalwood/Motrix)
- [Free Download Manager](https://www.freedownloadmanager.org/zh/)
- [you-get](https://github.com/soimort/you-get) - 网站视频下载命令工具，如需视频合并，需额外安装`ffmpeg`


### Office

- [LibreOffice](https://zh-cn.libreoffice.org/)


### 流程图

- [Draw.io](https://app.diagrams.net/)
- [asciiflow](https://asciiflow.com/)
- [tlddraw](https://www.tldraw.com/)


### Markdown

- [MarkText](https://github.com/marktext/marktext)


### 阅读

- [WeRead](https://github.com/tw93/Pake/releases) - 利用`Rust Tauri`打包的APP
- [Legado](https://github.com/gedoor/legado) - Android
- [报纸/期刊](http://www.53bk.com/baokan)
- [十万个为什么](https://10why.net/)


### PDF

- [Skim](https://skim-app.sourceforge.io/)
- Edge
- Chrome
- Firefox


### 播放器

> 收费的可以试试`Movist Pro`、`Infuse Pro`

- [IINA](https://iina.io/)
- [MusicFree](https://github.com/maotoumao/MusicFree) - Flutter
- [Music站点](https://tools.liumingye.cn/music/#/)


### 截图

- [shottr](https://shottr.cc/)
- [Snipaste](https://zh.snipaste.com/)
- [flameshot](https://github.com/flameshot-org/flameshot)
- [eSearch](https://github.com/xushengfeng/eSearch)
- [Xnip](https://apps.apple.com/cn/app/xnip-%E6%88%AA%E5%9B%BE-%E6%A0%87%E6%B3%A8/id1221250572?mt=12)
- [iShot](https://apps.apple.com/cn/app/ishot-%E4%BC%98%E7%A7%80%E7%9A%84%E6%88%AA%E5%9B%BE%E8%B4%B4%E5%9B%BE%E5%BD%95%E5%B1%8F%E5%BD%95%E9%9F%B3ocr%E7%BF%BB%E8%AF%91%E5%8F%96%E8%89%B2%E6%A0%87%E6%B3%A8%E5%B7%A5%E5%85%B7/id1485844094?mt=12)


### 窗口管理

- [Rectangle](https://github.com/rxhanson/Rectangle)
- [yabai](https://github.com/koekeishiya/yabai)


### 压缩解压缩

- [The Unarchiver](https://apps.apple.com/cn/app/the-unarchiver/id425424353?mt=12)
- [Keka](https://www.keka.io/zh-cn/)
- [PeaZip](https://github.com/peazip/PeaZip)


### 屏幕保护

- [Brooklyn](https://github.com/pedrommcarrasco/Brooklyn)


### 防火墙

- [Lulu](https://github.com/objective-see/LuLu)


### 翻译

- [Bob](https://apps.apple.com/cn/app/bob-%E7%BF%BB%E8%AF%91%E5%92%8C-ocr-%E5%B7%A5%E5%85%B7/id1630034110?mt=12) - `Bob`分为社区版(已停止日常维护)和`AppStore`版，想白嫖的可以继续使用社区版，`homebrew`安装即可。
- [沉浸式双语网页翻译扩展](https://github.com/immersive-translate/immersive-translate/)


### 状态栏

- [HiddenBar](https://github.com/dwarvesf/hidden) - 折叠图标


### TouchBar

- [Pock](https://github.com/pigigaldi/Pock)
- [MTMR](https://github.com/Toxblh/MTMR)


### Quick Look

- [glance](https://github.com/chamburr/glance) - All-in-one Quick Look plugin
- [SouceCodeSyntaxHighlight](https://github.com/sbarex/SourceCodeSyntaxHighlight)
- [QLMarkdown](https://github.com/sbarex/QLMarkdown)
- [Mac-QuickLook](https://github.com/haokaiyang/Mac-QuickLook)


### 邮件

- [Spark](https://apps.apple.com/cn/app/spark-readdle-%E5%87%BA%E5%93%81%E7%9A%84%E9%82%AE%E7%AE%B1%E5%BA%94%E7%94%A8/id1176895641?mt=12)


### 键盘

- [KeyCastr](https://github.com/keycastr/keycastr) - 显示当前按键
- [Tickys](http://www.yingdev.com/projects/tickeys) - 模拟机械键盘的声音


### 输入法切换

- [KeyboardHolder](https://github.com/leaves615/KeyboardHolder)
- [搜狗输入法切换助手](https://apps.apple.com/cn/app/%E6%90%9C%E7%8B%97%E8%BE%93%E5%85%A5%E6%B3%95%E5%88%87%E6%8D%A2%E5%8A%A9%E6%89%8B/id6443621266?mt=12)


### 屏幕录制

- [LICEcap](http://www.cockos.com/licecap/)
- [Kap](https://github.com/wulkano/kap)
- [GIFCapture](https://github.com/onmyway133/GifCapture)


### 直播

- [obs-studio](https://github.com/obsproject/obs-studio)


### 视频编辑

- [shotcut](https://www.shotcut.org/)


### 格式转码

- [handbrake](https://handbrake.fr/)


### NTFS

- [NTFSTool](https://github.com/ntfstool/ntfstool)
- [mounty](https://mounty.app/)


### Hosts

- [iHosts](https://apps.apple.com/cn/app/ihosts-etc-hosts-%E7%BC%96%E8%BE%91%E5%99%A8/id1102004240?mt=12)
- [SwitchHosts](https://github.com/oldj/SwitchHosts)


### RSS

- [NetNewsWire](https://ranchero.com/netnewswire/)
- [Lettura](https://github.com/zhanglun/lettura)


### U盘系统制作

- [Rufus](https://github.com/pbatard/rufus)
- [etcher](https://github.com/balena-io/etcher)


### 数据恢复

- [KeychainCracker](https://github.com/macmade/KeychainCracker)


### 代理

- [ClashX](https://github.com/yichengchen/clashX)
- [Tunnelblick](https://github.com/Tunnelblick/Tunnelblick) - OpenVPN


### 收费软件推荐

> 可以到[这里](#软件站)找 特(破)别(解) 版

- [Xee](https://apps.apple.com/cn/app/xee-image-viewer-and-browser/id639764244?mt=12) - 图片浏览
- [Kaleidoscope](https://kaleidoscope.app/) - 文件`diff`


------


## 开发

### 调试

- [LLVM](https://github.com/llvm/llvm-project)
- [Lookin](https://github.com/hughkli/Lookin)
- [LLDB](https://github.com/DerekSelander/LLDB) -  `lldb`插件
- [Chisel](https://github.com/facebook/chisel) - `lldb`插件
- [injectionIII](https://github.com/johnno1962/InjectionIII) - hotreload
- [OpenSim](https://github.com/luosheng/OpenSim) - 读取模拟器沙盒


### Mach-O

- [MachOView](https://github.com/fangshufeng/MachOView)
- [MachO-Explorer](https://github.com/DeVaukz/MachO-Explorer)
- [XMachOViewer](https://github.com/horsicq/XMachOViewer)
- [MachOExplorer](https://github.com/everettjf/MachOExplorer)
- [MachO-Kit](https://github.com/DeVaukz/MachO-Kit)
- [LinkMap](https://github.com/huanxsd/LinkMap)
- [bloaty](https://github.com/google/bloaty) - 对比文件体积变化
- [ipsw](https://github.com/blacktop/ipsw)
- [dSYMTools](https://github.com/answer-huang/dSYMTools)
- [go-macho](https://github.com/blacktop/go-macho)


### 逆向

> 比较有名的可能是`IDA`和`Hopper Disassembler`

- [Ghidra](https://github.com/NationalSecurityAgency/ghidra)
- [Frida](https://github.com/frida/frida)
- [Cutter](https://github.com/rizinorg/cutter)
- [Hashcat](https://handbrake.fr)


### Hex

- [HexFriend](https://github.com/ridiculousfish/HexFiend)
- [ImHex](https://github.com/WerWolv/ImHex)


### 命令行

- [fig](https://fig.io/)
- [starship](https://github.com/starship/starship) - `prompt`
- [nushell](https://github.com/nushell/nushell)
- [atuin](https://github.com/ellie/atuin) - shell history
- [fd](https://github.com/sharkdp/fd) - 文件搜索
- [dust](https://github.com/bootandy/dust) - `du`
- [lsd](https://github.com/Peltoche/lsd) - `ls`
- [exa](https://github.com/ogham/exa) - `ls`
- [bat](https://github.com/sharkdp/bat) - `cat`
- [ugit](https://github.com/Bhupesh-V/ugit) - 撤销`git`操作
- [thefuck](https://github.com/nvbn/thefuck)
- [ipatool](https://github.com/majd/ipatool) - 下载`IPA`文件
- [HTTPie](https://github.com/jakubroztocil/httpie) - 查看网络
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [git-cliff](https://github.com/orhun/git-cliff) - changelog
- [erdtree](https://github.com/solidiquis/erdtree) - file-tree
- [onefetch](https://github.com/o2sh/onefetch) - Git information
- [zoxide](https://github.com/ajeetdsouza/zoxide) - jump


### 快捷打开终端

- [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal)
- [FinderGo](https://github.com/onmyway133/FinderGo)
- [Go2Shell](http://zipzapmac.com/Go2Shell)
- [Alfred插件](http://www.packal.org/workflow/terminalfinder)


### 图片压缩

- [ImageSmith](https://apps.apple.com/cn/app/imagesmith-%E5%9B%BE%E7%89%87%E5%8E%8B%E7%BC%A9%E4%B8%93%E5%AE%B6/id1623828135?mt=12) - 推荐，刚发布时白嫖到的😏
- [Imagenie](https://github.com/meowtec/Imagine)
- [Crunch](https://github.com/chrissimpkins/Crunch)
- [TinyPNG4Mac](https://github.com/kyleduo/TinyPNG4Mac)
- [ImageOptim](https://imageoptim.com/mac)
- [Pngyu](https://nukesaq88.github.io/Pngyu/)


### 检测无用资源和代码

> 无用资源

- [LSUnusedResources](https://github.com/tinymind/LSUnusedResources) 

> 无用代码

- [periphery](https://github.com/peripheryapp/periphery)
- [WBBlades](https://github.com/wuba/WBBlades)
- [Pecker](https://github.com/woshiccm/Pecker)
- [Stencil](https://github.com/stencilproject/Stencil)
- [Sitrep](https://github.com/twostraws/Sitrep)
- [czkawka](https://github.com/qarmin/czkawka)


### 推送

- [PushDeer](https://github.com/easychen/pushdeer)
- [Knuff](https://github.com/KnuffApp/Knuff)
- [Pusher](https://github.com/noodlewerk/NWPusher)
- [Easy APNs Provider](https://itunes.apple.com/cn/app/easy-apns-provider-%E6%8E%A8%E9%80%81%E6%B5%8B%E8%AF%95%E5%B7%A5%E5%85%B7/id989622350?mt=12)
- [PushNotifications](https://github.com/onmyway133/PushNotifications)


### Git

- [Fork](https://git-fork.com)
- [GitUI](https://github.com/extrawurst/gitui)
- [LazyGit](https://github.com/jesseduffield/lazygit)

> 开源的还有[Xit](https://github.com/Uncommon/Xit)、[GitUp](https://github.com/git-up/GitUp)，收费的有`Tower`、`Sublime Merge`、`GitKraken`


### 数据库

- [SQLiteBrowser](https://github.com/sqlitebrowser/sqlitebrowser)
- [DBeaver](https://github.com/dbeaver/dbeaver)


### WWDC

- [WWDC](https://github.com/insidegui/WWDC)


### 分辨率调整

- [RDM](https://github.com/avibrazil/RDM)


### Web打包成MacAPP

- [Pake](https://github.com/tw93/Pake)


### 网络

- [hoppscotch](https://github.com/hoppscotch/hoppscotch) - Postwomen
- [HTTPToolKit-Desktop](https://github.com/httptoolkit/httptoolkit-desktop)
- [Stream](https://apps.apple.com/cn/app/stream/id1312141691)
- [Knot](https://apps.apple.com/cn/app/knot-packet-capture/id1618651767)


### Xcode Plugin 

- [Json2Property](https://github.com/keepyounger/Json2Property)
- [quicktype-xcode](https://github.com/quicktype/quicktype-xcode)
- [CleverToolKit](https://apps.apple.com/us/app/clevertoolkit/id6443766349?l=zh&mt=12)
- [XCFormat](https://github.com/sugarmo/XCFormat)
- [EditKit Pro](https://apps.apple.com/cn/app/editkit-pro/id1659984546?mt=12)


### Xcode版本管理

- [xcodes](https://github.com/RobotsAndPencils/xcodes)
- [xcinfo](https://github.com/xcodereleases/xcinfo)
- [xcode-install](https://github.com/xcpretty/xcode-install)


### Xcode缓存清理

- [DevCleaner](https://github.com/vashpan/xcode-dev-cleaner)


### VSCode插件

- Shades of Purple - 主题
- Code Runner
- CodeLLDB
- clangd
- Error Lens
- GitLens
- Git Graph
- Path Intellisense
- Project Manager
- Thunder Client
- CodeSnap
- Comment Tranlate
- Markdown Editor
- Image Preview
- Paste JSON as Code
- Todo Tree
- shellman
- Hex Editor
- Better Comments
- [whatchanged](https://marketplace.visualstudio.com/items?itemName=axetroy.vscode-whatchanged) - changelog
- Swift
    > 1. 如果没有代码联想，可能是因为`sourcekit-lsp`与本机`Swift`不在同一目录下。在`/usr/local/bin`下建立一个`sourcekit-lsp`的软链接可以解决：`ls -s $(xcrun --find sourcekit-lsp) /usr/local/bin/sourcekit-lsp`。
    >
    > 2. 如果断点调试无法显示变量，检查下是否安装了`llvm`，如果是那可能默认用的是`llvm`的`lldb`。把`CodeLLDB`的`lldb`指定为`Xcode`的`lldb`，或者在`.zshrc`中用`Xcode`版本覆盖`llvm`版本： `export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"`


### Windows VC环境

- [VCRedist](https://github.com/abbodi1406/vcredist)


------


## 常见问题

- `VSCode` 函数参数没有代码提示

    > 关闭阻止选项

    ![](/images/treasure/snippets_prevent_suggestions.png "snippets_prevent_suggestions")

- 找回`IDEA`的`copy reference`

    ![](/images/treasure/idea_copy_reference_lose.png "lose copy reference")

------


## 软件站

- [AppStorrent](https://appstorrent.ru/)
- [麦氪搜](https://www.imacso.com/)
- [open-source-mac-os-apps](https://github.com/serhii-londar/open-source-mac-os-apps)
- [MacYY](https://www.macyy.cn/)
- [Xclient](http://xclient.info/s/)
- [MacBL](https://www.macbl.com/)
- [AlternativeTo](https://alternativeto.net/)
- [NSANE FORUMS](https://nsaneforums.com/)
- [TorrentMac](https://www.torrentmac.net/)
- [UUP dump](https://uupdump.net/?lang=zh-cn)
- ~~[MacWk（已关站）](https://www.macwk.com/)~~


## 参考

- [老胡的周刊](https://weekly.howie6879.cn/soft/mac.html)

