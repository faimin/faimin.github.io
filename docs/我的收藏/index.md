# 我的收藏


<!--more-->

## 简介

主要是个人平时收藏的一些`Mac`平台的工具，绝大部分都是开源免费的。

## 包管理

- [Homebrew](https://brew.sh/index_zh-cn)：`Mac`端的包管理工具，`PC`端的有`Scoop`、`Chocolate`、`Winget`，我个人推荐`Scoop`，因为可以指定路径


## 系统优化

- [Lemon Cleaner](https://github.com/Tencent/lemon-cleaner)
- [AppCleaner](https://freemacsoft.net/appcleaner/)


## 系统监控

- [Stats](https://github.com/exelban/stats)
- [eul](https://github.com/gao-sun/eul)
- [MenuMeters](https://github.com/yujitach/MenuMeters)


## 下载

- [Motrix](https://github.com/agalwood/Motrix)
- [Free Download Manager](https://www.freedownloadmanager.org/zh/)
- [you-get](https://github.com/soimort/you-get)


## Markdown

- [MarkText](https://github.com/marktext/marktext)


## 播放器

> 我愿称之为`Mac`端最强

- [IINA](https://iina.io/)


## 截图

- [shottr](https://shottr.cc/)

## 窗口管理

- [Rectangle](https://github.com/rxhanson/Rectangle)


## 屏幕保护

- [Brooklyn](https://github.com/pedrommcarrasco/Brooklyn)


## 防火墙

- [Lulu](https://github.com/objective-see/LuLu)


## 翻译

> `Bob`分为社区版和`AppStore`版，从社区第一个版本就开始用，后来有了商店版后我就买了。想白嫖的可以继续使用社区版，使用`homebrew`安装即可。

- [Bob](https://apps.apple.com/cn/app/bob-%E7%BF%BB%E8%AF%91%E5%92%8C-ocr-%E5%B7%A5%E5%85%B7/id1630034110?mt=12)


## 状态栏图标折叠

- [HiddenBar](https://github.com/dwarvesf/hidden)


## Xcode版本管理

- [xcodes](https://github.com/xcpretty/xcode-install)
- [xcodes](https://github.com/RobotsAndPencils/xcodes)
- [xcinfo](https://github.com/xcodereleases/xcinfo)


## VSCode插件

- Shades of Purple
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
- Swift
    > 1. 如果没有代码联想，可能是因为`sourcekit-lsp`与本机`Swift`不在同一目录下。在`/usr/local/bin`下建立一个`sourcekit-lsp`的软链接可以解决：`ls -s $(xcrun --find sourcekit-lsp) /usr/local/bin/sourcekit-lsp`。
    >
    > 2. 如果断点调试无法显示变量，检查下是否安装了`llvm`，如果是那可能默认用的是`llvm`的`lldb`。把`CodeLLDB`的`lldb`指定为`Xcode`的`lldb`，或者在`.zshrc`中用`Xcode`版本覆盖`llvm`版本： `export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"`

#### 函数参数没有代码提示的问题

> 关闭阻止选项

![](/images/treasure/snippets_prevent_suggestions.png "snippets_prevent_suggestions")

------

## 开发调试

- [Lookin](https://github.com/hughkli/Lookin)
- [Chisel](https://github.com/facebook/chisel)
- [ipsw](https://github.com/blacktop/ipsw)

## Git

- [Fork](https://git-fork.com)
- [GitUI](https://github.com/extrawurst/gitui)
- [LazyGit](https://github.com/jesseduffield/lazygit)

> 开源的还有[Xit](https://github.com/Uncommon/Xit)、[GitUp](https://github.com/git-up/GitUp)，收费的有Tower、Sublime Merge、GitKraken


## 逆向

> 比较有名的可能是`IDA`和`Hopper Disassembler`

- [Ghidra](https://github.com/NationalSecurityAgency/ghidra)
- [Frida](https://github.com/frida/frida)
- [Cutter](https://github.com/rizinorg/cutter)
- [Hashcat](https://handbrake.fr)


## Hex

- [HexFriend](https://github.com/ridiculousfish/HexFiend)


## 命令行

- [fig](https://fig.io/)
- [starship](https://github.com/starship/starship)
- [nushell](https://github.com/nushell/nushell)
- [atuin](https://github.com/ellie/atuin)
- [fd](https://github.com/sharkdp/fd)
- [lsd](https://github.com/Peltoche/lsd)
- [exa](https://github.com/ogham/exa)
- [bat](https://github.com/sharkdp/bat)
- [thefuck](https://github.com/nvbn/thefuck)


## JSON转Model

- [Json2Property](https://github.com/keepyounger/Json2Property)
- [quicktype-xcode](https://github.com/quicktype/quicktype-xcode)


## 快捷打开终端

- [OpenInTerminal)[https://github.com/Ji4n1ng/OpenInTerminal]
- [FinderGo)[https://github.com/onmyway133/FinderGo]
- [Go2Shell)[http://zipzapmac.com/Go2Shell]
- [Alfred插件)[http://www.packal.org/workflow/terminalfinder]


## 图片压缩

> `ImageSmith`是刚发布时我白嫖到的，现在已恢复原价，不过很好用；免费版推荐`Imagenie`

- [TinyPNG4Mac](https://github.com/kyleduo/TinyPNG4Mac)
- [Crunch](https://github.com/chrissimpkins/Crunch)
- [Imagenie](https://github.com/meowtec/Imagine)
- [ImageOptim](https://imageoptim.com/mac)
- [ImageSmith](https://apps.apple.com/cn/app/imagesmith-%E5%9B%BE%E7%89%87%E5%8E%8B%E7%BC%A9%E4%B8%93%E5%AE%B6/id1623828135?mt=12)


------

## 软件站

- [麦氪搜](https://www.imacso.com/)
- [MacWk](https://www.macwk.com/)
- [Xclient](http://xclient.info/s/)
