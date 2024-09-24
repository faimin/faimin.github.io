# 差生文具多


<!--more-->

## 简介

个人平时收藏的一些`Mac`平台开源免费工具，基本都支持`homebrew`安装。

## 搜索引擎

- [kimi](https://kimi.moonshot.cn/)
- [phind](https://www.phind.com/)
- [Yandex](https://yandex.com/)
- [Qwant](https://www.qwant.com/)
- [grep.app](https://grep.app/)
- [startpage](https://www.startpage.com/)
- [SearX](https://github.com/searxng/searxng)

---

## 软件

### 包管理

- [Homebrew](https://brew.sh/index_zh-cn)：`Mac`端的包管理工具，`PC`端的有`Scoop`、`Chocolate`、`Winget`
  - [Cork](https://github.com/buresdv/Cork) : Homebrew GUI
- [UniGetUI](https://github.com/marticliment/WingetUI) : PC包管理GUI

### 终端

- [iTerm2](https://iterm2.com/)
- [Alacritty](https://github.com/alacritty/alacritty)
- [WezTerm](https://github.com/wez/wezterm)
- [kitty](https://github.com/kovidgoyal/kitty)
- [WindTerm](https://github.com/kingToolbox/WindTerm)
- [Tabby](https://github.com/Eugeny/tabby)
- [Warp](https://www.warp.dev/)

### nvim

- [LazyVim](https://github.com/LazyVim/LazyVim)
- [Neovim](https://github.com/neovide/neovide) - GUI
- [vimr](https://github.com/qvacua/vimr) - GUI
- [NvChad](https://github.com/NvChad/NvChad)

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

- [SwiftBar](https://github.com/swiftbar/SwiftBar)
- [xbar](https://github.com/matryer/xbar)
- [DevToys](https://github.com/ObuchiYuki/DevToysMac)
- [OnlySwitch](https://github.com/jacklandrin/OnlySwitch)
- [NotchDrop](https://github.com/Lakr233/NotchDrop)

### 输入法切换

- [KeyboardHolder](https://github.com/leaves615/KeyboardHolder)
- [搜狗输入法切换助手](https://apps.apple.com/cn/app/%E6%90%9C%E7%8B%97%E8%BE%93%E5%85%A5%E6%B3%95%E5%88%87%E6%8D%A2%E5%8A%A9%E6%89%8B/id6443621266?mt=12)

### 系统优化

- [Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)
- [Pearcleaner](https://github.com/alienator88/Pearcleaner) - Uninstall
- [UninstallPKG](https://www.corecode.io/uninstallpkg/)
- [AppCleaner](https://freemacsoft.net/appcleaner/)

### 系统监控

- [Stats](https://github.com/exelban/stats)
- [eul](https://github.com/gao-sun/eul)
- [MenuMeters](https://github.com/yujitach/MenuMeters)

### 下载

- [Motrix](https://github.com/agalwood/Motrix)
- [imfile-desktop](https://github.com/imfile-io/imfile-desktop) - Motrix fork版本
- [Free Download Manager](https://www.freedownloadmanager.org/zh/)
- [gopeed](https://github.com/GopeedLab/gopeed)
- [lux](https://github.com/iawia002/lux) - 下载网站视频
- [you-get](https://github.com/soimort/you-get) -
  下载网站视频，如需视频合并需额外安装`ffmpeg`

### Office

- [LibreOffice](https://zh-cn.libreoffice.org/)

### 流程图

- [Draw.io](https://app.diagrams.net/)
- [asciiflow](https://asciiflow.com/)
- [tlddraw](https://www.tldraw.com/)

### Markdown

- [MarkText](https://github.com/marktext/marktext)
- [typst](https://github.com/typst/typst)

### 阅读

- [WeRead](https://github.com/tw93/Pake/releases) - 利用`Rust Tauri`打包的 APP
- [Legado](https://github.com/gedoor/legado) - Android
- [报纸/期刊](http://www.53bk.com/baokan)
- [十万个为什么](https://10why.net/)

### PDF浏览器

- [Skim](https://skim-app.sourceforge.io/)
- Edge
- Firefox
- Chrome

### 播放器

> 收费的可以试试`Movist Pro`、`Infuse Pro`

- [IINA](https://iina.io/)
- [MPC-BE](https://github.com/Aleksoid1978/MPC-BE)
- [MusicFree](https://github.com/maotoumao/MusicFree) - ReactNative


- [Music 站点](https://tools.liumingye.cn/music/#/)
- [网易云音乐 MAC 云盘上传工具](https://github.com/lulu-ls/cloud-uploader)

### 截图

- [Snipaste](https://zh.snipaste.com/)
- [pixpin](https://pixpinapp.com)
- [shottr](https://shottr.cc/)
- [flameshot](https://github.com/flameshot-org/flameshot)
- [eSearch](https://github.com/xushengfeng/eSearch)
- [Xnip](https://apps.apple.com/cn/app/xnip-%E6%88%AA%E5%9B%BE-%E6%A0%87%E6%B3%A8/id1221250572?mt=12)
- [iShot](https://apps.apple.com/cn/app/ishot-%E4%BC%98%E7%A7%80%E7%9A%84%E6%88%AA%E5%9B%BE%E8%B4%B4%E5%9B%BE%E5%BD%95%E5%B1%8F%E5%BD%95%E9%9F%B3ocr%E7%BF%BB%E8%AF%91%E5%8F%96%E8%89%B2%E6%A0%87%E6%B3%A8%E5%B7%A5%E5%85%B7/id1485844094?mt=12)

### 窗口管理

- [Loop](https://github.com/MrKai77/Loop)
- [Rectangle](https://github.com/rxhanson/Rectangle)
- [yabai](https://github.com/koekeishiya/yabai)

### 文件压缩

- [The Unarchiver](https://apps.apple.com/cn/app/the-unarchiver/id425424353?mt=12)
- [Keka](https://www.keka.io/zh-cn/)
- [PeaZip](https://github.com/peazip/PeaZip)
- [NanaZip](https://github.com/M2Team/NanaZip) - windows

### 屏幕保护

- [Brooklyn](https://github.com/pedrommcarrasco/Brooklyn)

### 防火墙

- [Lulu](https://github.com/objective-see/LuLu)

### 翻译

- [Bob](https://apps.apple.com/cn/app/bob-%E7%BF%BB%E8%AF%91%E5%92%8C-ocr-%E5%B7%A5%E5%85%B7/id1630034110?mt=12)
- [EasyDict](https://github.com/tisfeng/Easydict)
- [沉浸式双语网页翻译扩展](https://github.com/immersive-translate/immersive-translate/)
- [kiss-translator](https://github.com/fishjar/kiss-translator)
- [TTime](https://github.com/inkTimeRecord/TTime)
- [pot-desktop](https://github.com/pot-app/pot-desktop)
- [tran](https://github.com/Borber/tran)

### 剪切板

- [EcoPaste](https://github.com/ayangweb/EcoPaste)
- [Lanaya](https://github.com/ChurchTao/Lanaya)
- [crosspaste-desktop](https://github.com/CrossPaste/crosspaste-desktop) - kotlin

### QR

- [Viz](https://github.com/alienator88/Viz)

### MenuBar

- [HiddenBar](https://github.com/dwarvesf/hidden) - 折叠图标
- [Ice](https://github.com/jordanbaird/Ice)
- [Dozer](https://github.com/Mortennn/Dozer)

### 日历

- [LunarBar](https://github.com/LunarBar-app/LunarBar)
- [CalendarX](https://github.com/ZzzM/CalendarX)
- [Calendr](https://github.com/pakerwreah/Calendr)

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

### 屏幕录制

- [QuickRecorder](https://github.com/lihaoyun6/QuickRecorder)
- [LICEcap](http://www.cockos.com/licecap/)
- [Kap](https://github.com/wulkano/kap)
- [GIFCapture](https://github.com/onmyway133/GifCapture)

### 直播

- [obs-studio](https://github.com/obsproject/obs-studio)

### 视频编辑

- [shotcut](https://www.shotcut.org/)
- [lossless-cut](https://github.com/mifi/lossless-cut)

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
- [mdSilo-app](https://github.com/mdSilo/mdSilo-app)

### 文件传输

- [localsend](https://github.com/localsend/localsend)
- [FlyingCarpet](https://github.com/spieglt/FlyingCarpet)
- [sharing](https://github.com/parvardegr/sharing)
- [sharedrop](https://github.com/szimek/sharedrop)

### U盘系统制作

- [Rufus](https://github.com/pbatard/rufus)
- [Ventoy](https://github.com/ventoy/Ventoy)
- [etcher](https://github.com/balena-io/etcher)

### 数据恢复

- [KeychainCracker](https://github.com/macmade/KeychainCracker)

### 代理

- [clash-verge-rev](https://github.com/clash-verge-rev/clash-verge-rev)
- [Tunnelblick](https://github.com/Tunnelblick/Tunnelblick) - OpenVPN
- [whistle](https://github.com/avwo/whistle)

### 图片浏览器

- [Xee](https://apps.apple.com/cn/app/xee-image-viewer-and-browser/id639764244?mt=12)
- [Picture View](https://apps.apple.com/tt/app/picture-view-image-browser/id1606275031?mt=12)
- [FlowVision](https://github.com/netdcy/FlowVision)


---

## 开发

### 版本管理

#### Python

- [pyenv](https://github.com/pyenv/pyenv)
- [uv](https://github.com/astral-sh/uv)
- [pixi](https://github.com/prefix-dev/pixi)

#### WebEnv/Node

- [volta](https://github.com/volta-cli/volta)
- [fnm](https://github.com/Schniz/fnm)
- [nvm](https://github.com/nvm-sh/nvm)
- [mise](https://github.com/jdx/mise)

#### Ruby

- [rbenv](https://github.com/rbenv/rbenv)
- [rvm](https://github.com/rvm/rvm)

#### Java

- [sdkman](https://github.com/sdkman/sdkman-cli)
- [jenv](https://github.com/jenv/jenv)

#### Flutter

- [fvm](https://github.com/fluttertools/fvm)

#### Swift

- [swiftly](https://github.com/swift-server/swiftly)

### 换源

- [chsrc](https://github.com/RubyMetric/chsrc)

### 调试

- [LLVM](https://github.com/llvm/llvm-project)
- [Lookin](https://github.com/hughkli/Lookin)
- [LLDB](https://github.com/DerekSelander/LLDB) - `lldb`插件
- [Chisel](https://github.com/facebook/chisel) - `lldb`插件
- [injectionIII](https://github.com/johnno1962/InjectionIII) - hotreload
- [OpenSim](https://github.com/luosheng/OpenSim) - 读取模拟器沙盒
- [flx](https://github.com/itome/flx) - 终端调试flutter

### CI

- [maestro](https://github.com/mobile-dev-inc/maestro)
- [xcbeautify](https://github.com/cpisciotta/xcbeautify)

### Mach-O

- [MachOView](https://github.com/gdbinit/MachOView)
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
- [Hashcat](https://github.com/hashcat/hashcat)
- [icertools](https://github.com/codematrixer/icertools) - 重签名

### Hex

- [HexFriend](https://github.com/ridiculousfish/HexFiend)
- [ImHex](https://github.com/WerWolv/ImHex)
- [hexyl](https://github.com/sharkdp/hexyl)

### 命令行

- [fig](https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-getting-started-installing.html)
- [inshellisense](https://github.com/microsoft/inshellisense)
- [starship](https://github.com/starship/starship) - `prompt`
- [nushell](https://github.com/nushell/nushell)
- [atuin](https://github.com/ellie/atuin) - shell history
- [fd](https://github.com/sharkdp/fd) - file search
- [ripgrep](https://github.com/BurntSushi/ripgrep) - grep
- [dust](https://github.com/bootandy/dust) - `du`
- [lsd](https://github.com/Peltoche/lsd) - `ls`
- [eza](https://github.com/eza-community/eza) - `ls`
- [bat](https://github.com/sharkdp/bat) - `cat`
- [ugit](https://github.com/Bhupesh-V/ugit) - 撤销`git`操作
- [thefuck](https://github.com/nvbn/thefuck)
- [ipatool](https://github.com/majd/ipatool) - 下载`IPA`文件
- [HTTPie](https://github.com/jakubroztocil/httpie) - 查看网络
- [zsh-autocomplete](https://github.com/marlonrichert/zsh-autocomplete)
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [git-cliff](https://github.com/orhun/git-cliff) - changelog
- [erdtree](https://github.com/solidiquis/erdtree) - file-tree
- [tokei](https://github.com/XAMPPRocky/tokei) - 统计代码行数
- [onefetch](https://github.com/o2sh/onefetch) - Git information
- [zoxide](https://github.com/ajeetdsouza/zoxide) - jump
- [ios-deploy](https://github.com/ios-control/ios-deploy)
- [joshuto](https://github.com/kamiyaa/joshuto) - file manager
- [yazi](https://github.com/sxyazi/yazi) - file manager

### 快捷打开终端

- [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal)
- [FinderGo](https://github.com/onmyway133/FinderGo)
- [Go2Shell](http://zipzapmac.com/Go2Shell)
- [Alfred 插件](http://www.packal.org/workflow/terminalfinder)

### 图片压缩

- [ImageSmith](https://apps.apple.com/cn/app/imagesmith-%E5%9B%BE%E7%89%87%E5%8E%8B%E7%BC%A9%E4%B8%93%E5%AE%B6/id1623828135?mt=12)
- [Imagenie](https://github.com/meowtec/Imagine)
- [Crunch](https://github.com/chrissimpkins/Crunch)
- [pic-smaller](https://github.com/joye61/pic-smaller)
- [recompressor](https://zh.recompressor.com/)
- [TinyPNG4Mac](https://github.com/kyleduo/TinyPNG4Mac)
- [ImageOptim](https://imageoptim.com/mac)
- [Pngyu](https://nukesaq88.github.io/Pngyu/)
- [rimage](https://github.com/SalOne22/rimage)
- [oxipng](https://github.com/shssoichiro/oxipng)
- [imagecompressor](https://www.websiteplanet.com/zh-hans/webtools/imagecompressor/)

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
- [gitbutler](https://github.com/gitbutlerapp/gitbutler)

> 开源的还有[Xit](https://github.com/Uncommon/Xit)、[GitUp](https://github.com/git-up/GitUp)，收费的有`Tower`、`Sublime Merge`、`GitKraken`

- [dura](https://github.com/tkellogg/dura) - 防止代码丢失

### 文件diff

- [Kaleidoscope](https://kaleidoscope.app/) - 文件`diff`

### 数据库

- [SQLiteBrowser](https://github.com/sqlitebrowser/sqlitebrowser)
- [DBeaver](https://github.com/dbeaver/dbeaver)

### WWDC

- [WWDC](https://github.com/insidegui/WWDC)

### Docker

- [OrbStack](https://orbstack.dev/)

### 分辨率调整

- [RDM](https://github.com/avibrazil/RDM)

### Web 打包成 MacAPP

- [Pake](https://github.com/tw93/Pake)

### 网络

- [thunder-client](https://marketplace.visualstudio.com/items?itemName=rangav.vscode-thunder-client)
- [hoppscotch](https://github.com/hoppscotch/hoppscotch) - Postwomen
- [RapidAPI / Paw](https://paw.cloud/)
- [HTTPToolKit-Desktop](https://github.com/httptoolkit/httptoolkit-desktop)
- [cocoa-reset-client](https://github.com/mmattozzi/cocoa-rest-client)
- [Stream](https://apps.apple.com/cn/app/stream/id1312141691)
- [Knot](https://apps.apple.com/cn/app/knot-packet-capture/id1618651767)

### 爬虫

- [EasySpider](https://github.com/NaiboWang/EasySpider)

### Xcode Plugin

- [Json2Property](https://github.com/keepyounger/Json2Property)
- [quicktype-xcode](https://github.com/quicktype/quicktype-xcode)
- [CleverToolKit](https://apps.apple.com/us/app/clevertoolkit/id6443766349?l=zh&mt=12)
- [XCFormat](https://github.com/sugarmo/XCFormat)
- [EditKit Pro](https://apps.apple.com/cn/app/editkit-pro/id1659984546?mt=12)

### Xcode 版本管理

- [xcodes](https://github.com/RobotsAndPencils/xcodes)
- [xcinfo](https://github.com/xcodereleases/xcinfo)
- [xcode-install](https://github.com/xcpretty/xcode-install)

### Xcode 缓存清理

- [DevCleaner](https://github.com/vashpan/xcode-dev-cleaner)

### VSCode 插件

- Shades of Purple - 主题
- [Dracula](https://draculatheme.com/) - 主题
- Code Runner
- CodeLLDB
- clangd
- Error Lens
- GitLess
- Git Blame
- GitLens
- Git Graph
- Path Intellisense
- Thunder Client
- CodeSnap
- Comment Tranlate
- Markdown Editor
- Image Preview
- Paste JSON as Code
- Project Manager
- Bookmarks
- Todo Tree
- shellman
- Hex Editor
- Doxygen Documentation Generator
- Better Comments
- [whatchanged](https://marketplace.visualstudio.com/items?itemName=axetroy.vscode-whatchanged)
- Swift
  > 1. 如果没有代码联想，可能是因为`sourcekit-lsp`与本机`Swift`不在同一目录下。在`/usr/local/bin`下建立一个`sourcekit-lsp`的软链接可以解决：`ls -s $(xcrun --find sourcekit-lsp) /usr/local/bin/sourcekit-lsp`。
  > 2. 如果断点调试无法显示变量，检查下是否安装了`llvm`，如果是那可能默认用的是`llvm`的`lldb`。把`CodeLLDB`的`lldb`指定为`Xcode`的`lldb`，或者在`.zshrc`中用`Xcode`版本覆盖`llvm`版本：
     > `export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"`

### Windows VC 环境

- [VCRedist](https://github.com/abbodi1406/vcredist)

### Windows 激活

- [HEU_KMS_Activator](https://github.com/zbezj/HEU_KMS_Activator)

---

## 常见问题

- `VSCode` 函数参数没有代码提示

  > 关闭阻止选项

  ![](/images/treasure/snippets_prevent_suggestions.png "snippets_prevent_suggestions")

- 找回`IDEA`的`copy reference`

  ![](/images/treasure/idea_copy_reference_lose.png "lose copy reference")

- 旧版`Xcode`调试新`iOS`系统

  执行如下命令：

  ```bash
  defaults write com.apple.dt.Xcode DVTEnableCoreDevice enabled
  ```

  如果想恢复，请执行如下命令：

  ```bash
  defaults delete com.apple.dt.Xcode DVTEnableCoreDevice
  ```

---

## 软件站

- [AppStorrent](https://appstorrent.ru/)
- [macked](https://macked.app/)
- [imacso](https://www.imacso.com/)
- [open-source-mac-os-apps](https://github.com/serhii-londar/open-source-mac-os-apps)
- [Xclient](http://xclient.info/s/)
- [MacBL](https://www.macbl.com/)
- [AlternativeTo](https://alternativeto.net/)
- [NSANE FORUMS](https://nsaneforums.com/)
- [TorrentMac](https://www.torrentmac.net/)
- [UUP dump](https://uupdump.net/?lang=zh-cn)

## 参考

- [HellGithub](https://hellogithub.com/)
- [老胡的周刊](https://weekly.howie6879.cn/soft/mac.html)

