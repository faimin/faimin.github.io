---
title: "CocoaPods笔记"
date: 2016-11-21T11:40:00+08:00
lastmod: 2025-11-11T18:48:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: ""
tags: ["iOS", "CocoaPods", "tips"]
categories: ["Tips"]

images: []
featuredImage: ""
featuredImagePreview: "/images/cocoapods/sanqianyuanzhi.jpeg"
---

`CocoaPods`笔记

<!--more-->


## 1、The `master` repo requires CocoaPods 1.0.0 - (currently using 0.38.2)

> 参考：http://blog.cocoapods.org/Sharding/

安装1.0之前（e.g：v0.38.2）版本的pod

```ruby
sudo gem install cocoapods -v 0.38.2
```

之后在执行`pod setup`时，由于`pod`工具已经升级到`1.xx`版本了，`pod`算法以及`Specs`库中的文件结构已经改变，所以它会默认拉取新版本的`Specs`库，这样就会出现旧版本`pod`新版本`Specs`库的情况，当执行`pod install`的时候会发生找不到`xxx`第三方库的情况。

解决此问题的方案是需要在`Podfile`中指定`source`源地址：

```
source "https://github.com/CocoaPods/Old-Specs"
```

并把本地的`Specs`库切换到旧版本：

```git
cd ~/.cocoapods/repos/master/
git fetch origin master
git checkout v0.32.1
```

最后，在执行`pod install`的时候需要添加上`--no-repo-update`标识，因为`1.0`之前的`pod`版本在执行`pod install`的时候会默认先更新升级本地`Specs`库文件。

以下2张图分别是旧版本的`spec`库和新版本`spec`库的结构，大家可以对比一下二者的结构：
![OldSpec](/images/cocoapods/pods_oldSpec.png "oldSpec")
![NewSpec](/images/cocoapods/pods_newSpec.png "newSpec")

## 2、File not found with <angled> include; use "quoates" instead

在`target`中手动设置**Always Search User Paths**为**YES**，也可以通过`pod`动态设置（推荐）

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'YES'
    end
  end
end
```

## 3、Cannot create `__weak reference` in file using manual reference counting

> + https://github.com/ReactiveCocoa/ReactiveCocoa/issues/2761
> + @mdiep 对出现此问题的原因的解释：In Xcode 7.3, __weak causes errors in files compiled as -fno-objc-arc. Since RAC uses __weak, you cannot use it in those files without setting the Weak References in Manual Retain Release setting to YES. If you're using a .pch that imports RAC, you're more likely to see this error.

错误样式如下图所示
![ReactiveCocoa issue 2761](/images/cocoapods/pods_reactiveCocoa_issue_2761.png "reactiveCocoa_issue_2761")

**有3种解决办法：**

1）修改源码：把`.h`文件中报错的`__weak`标识删除（不能删除`.m`文件中的，否则会发生内存问题）

2）在引入`ReactiveCocoa`的地方添加`macro`判断标识：

```objectivec
#if __has_feature(objc_arc)
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif
```

3）设置工程文件：设置`Weak References in Manual Retain Release`为`YES`
![weak reference in manual](/images/cocoapods/pods_weak_reference_setting.png "weak reference in manual")

## 4、"The validator for Swift projects uses Swift 3.0 by default, if you are using a different version of swift you can use a `.swift-version    ` file to set the version for you Pod. For example to use Swift 2.3, run: `echo "2.3" > .swift-version`:"

如下图所示：
![SwiftVersionError](/images/cocoapods/pods_swift_versionError.png "SwiftVersionError")

**解决办法：**

把`pod`的引用方式由`:git`方式改为指定版本号的方式。

## 5、在`pod`的`pch`文件中添加引用时，比如

```objectivec
s.prefix_header_contents = '#import "DDDefine.h"'
```

不能添加自己工程中的文件，执行`pod lib lint`时，它会一直报找不到你想引入的文件的错误。

但是你可以在这里添加其他`pod`中的文件，或者`iOS`自己`API`中的库文件。

## 6、`CocoaPods`卸载

有的时候不小心把`podSpec`升级到了`1.x` 版本，然后`pod search`就不能用了，然后通过切换分支`checkout`到`v0.32.1`，但是`pod search`还是报错：

```ruby
$ pod search ZDTableView
[!] Unable to load a specification for the plugin `~/.rvm/gems/ruby-2.2.1/gems/cocoapods-deintegrate-1.0.0.beta.1`

――― MARKDOWN TEMPLATE ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

 Command

~/.rvm/gems/ruby-2.2.1/bin/pod search ZDTableView


 Report

* What did you do?

* What did you expect to happen?

* What happened instead?

 Stack

   CocoaPods : 0.38.2
        Ruby : ruby 2.2.1p85 (2015-02-26 revision 49769) [x86_64-darwin14]
    RubyGems : 2.4.8
        Host : Mac OS X 10.12.2 (16C67)
       Xcode : 8.2.1 (8C1002)
         Git : git version 2.11.0
Ruby lib dir : ~/.rvm/rubies/ruby-2.2.1/lib
Repositories : cocoapods - https://github.com/CocoaPods/Old-Specs @ 6e256ccc84aad851d401fabb79b2c0f9e09bb875
               DDSpec - http://10.255.223.213/ios-code/DDSpec.git @ 941bed4b0c03090e13ecb7ee16a1eafa77969785
               master - https://github.com/CocoaPods/Specs.git @ 2d939ca0abb4172b9ef087d784b43e0696109e7c

Plugins

cocoapods-keys        : 1.7.0
cocoapods-playgrounds : 0.1.0
cocoapods-plugins     : 0.4.2
cocoapods-search      : 1.0.0.beta.1
cocoapods-stats       : 0.5.3
cocoapods-trunk       : 0.6.4
cocoapods-try         : 0.4.5

Error

NoMethodError - undefined method `all' for Pod::Platform:Class
~/.rvm/gems/ruby-2.2.1/gems/cocoapods-search-1.0.0.beta.1/lib/cocoapods-search/command/search.rb:34:in `initialize'
~/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:334:in `new'
~/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:334:in `parse'
~/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:330:in `parse'
~/.rvm/gems/ruby-2.2.1@global/gems/claide-0.9.1/lib/claide/command.rb:308:in `run'
~/.rvm/gems/ruby-2.2.1/gems/cocoapods-0.38.2/lib/cocoapods/command.rb:48:in `run'
~/.rvm/gems/ruby-2.2.1/gems/cocoapods-0.38.2/bin/pod:44:in `<top (required)>'
~/.rvm/gems/ruby-2.2.1/bin/pod:23:in `load'
~/.rvm/gems/ruby-2.2.1/bin/pod:23:in `<main>'
~/.rvm/gems/ruby-2.2.1/bin/ruby_executable_hooks:15:in `eval'
~/.rvm/gems/ruby-2.2.1/bin/ruby_executable_hooks:15:in `<main>'

――― TEMPLATE END ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

[!] Oh no, an error occurred.

Search for existing GitHub issues similar to yours:
https://github.com/CocoaPods/CocoaPods/search?q=undefined+method+%60all%27+for+Pod%3A%3APlatform%3AClass&type=Issues

If none exists, create a ticket, with the template displayed above, on:
https://github.com/CocoaPods/CocoaPods/issues/new

Be sure to first read the contributing guide for details on how to properly submit a ticket:
https://github.com/CocoaPods/CocoaPods/blob/master/CONTRIBUTING.md

Don't forget to anonymize any private data!
```

这时候我的做法通常就是卸载`pod`，然后重新安装。

```ruby
$ which pod //得到path
$ sudo rm -rf <path>
// 循环遍历卸载pod组件（如果是安装在了用户目录下，那就去掉命令中的sudo）
$ for i in `gem list | grep pod | awk '{print $1}'`; do sudo gem uninstall  $i; done
```

有的时候对于新系统直接调用`gem install cocoapods` 是不行的，提示错误，此种情况就用下面的命令：

```ruby
// 安装指定版本的pod
sudo gem install -n /usr/local/bin cocoapods -v 1.2.0
// 卸载
sudo gem uninstall -n /usr/local/bin cocoapods -v 1.2.0
```

## 7、Library not found for -lAFNetworking

这种情况的解决方案是设置`project` -> `build setting` -> `library search patchs` 里添加 `$(inherited)` 标识。

## 8、Cannot synthesize weak property because the current deployment target does not support weak refernces

refer: [http://stackoverflow.com/questions/37160688/set-deployment-target-for-cocoapodss-pod](http://stackoverflow.com/questions/37160688/set-deployment-target-for-cocoapodss-pod)

解决方案：

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == 'DDKit'
                config.build_settings['ENABLE_STRICT_OBJC_MSGSEND'] = 'NO'
            elsif target.name == 'PulsingHalo'
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '9.2'
            end
        end
    end
end
```

或者错误提示为：`Cannot synthesize weak property in file using manual reference counting`

```ruby
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == 'ReactiveCocoa'
                config.build_settings['CLANG_ENABLE_OBJC_WEAK'] = 'YES'
            end
        end
    end
end
```

## 9、`Cocoapods` debug

我们可以用 `pry` 来调试 `podfile` ，即调试 `ruby`，使用之前先安装

```ruby
gem install pry
```

接下来在 `podfile` 中导入 `require 'pry'`，然后在你想打断点调试的地方添加一行代码 `binding.pry`，这样就可以在每次执行`pod install` or `pod update` 的时候断在这句代码的位置，我们就可以调试了；

## 10、自动添加`modulemap`的支持

如果我们想以`@import`的方式引用一个不支持`modulemap`的`repo`，那么我们可以让`CocoaPods`自动生成`modulemap`，语法如下：

```ruby
pod 'MLFilterKit', '1.9.705', :modular_headers => true
```

这个可以解决部分`repo`中 `@import` 报错的问题；

## 11、为`CocoaPods`开启增量编译模式：

> 开启增量编译模式后，`post_install、pre_install` 中的某些设置会报错，因为工程配置的层级结构发生了变化；

```ruby
install! 'cocoapods',
         :generate_multiple_pod_projects => true,
         :incremental_installation => true
```

## 12、静态库和动态库共存的设置：

```ruby
# https://www.rubydoc.info/gems/cocoapods/Pod
# https://github.com/facebook/flipper/issues/254
# https://github.com/facebook/flipper/blob/master/docs/getting-started.md
$dynamic_framework = ['LayoutInspector', 'PromiseKit', 'Yoga', 'YogaKit']
pre_install do |installer|
#    installer.pod_targets.each do |pod|
#        if $dynamic_framework.include?(pod.name)
#            pod.instance_variable_set(:@host_requires_frameworks, true)
#        end
#    end

  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
  installer.pod_targets.each do |pod|
     if not $dynamic_framework.include?(pod.name)
       def pod.build_type;
          #Pod::Target::BuildType.static_library
          Pod::BuildType.static_library
       end
     end
  end
end


pre_install do |installer|
  $dynamic_framework = ['RxSwift']
  Pod::Installer::Xcode::TargetValidator.send(:define_method,:verify_no_static_framework_transitive_dependencies) {}
  installer.pod_targets.each do |pod|
    if $dynamic_framework.include?(pod.name)
      def pod.build_type;
        Pod::BuildType.dynamic_framework
      end
    end
  end
end
```

## 13、使用`Ruby`函数快捷处理source文件

  > https://github.com/mxcl/PromiseKit/blob/6.15.3/PromiseKit.podspec

```ruby
s.subspec 'CorePromise' do |ss|
    hh = Dir['Sources/*.h'] - Dir['Sources/*+Private.h']

    cc = Dir['Sources/*.swift'] - ['Sources/SwiftPM.swift']
    cc << 'Sources/{after,AnyPromise,GlobalState,dispatch_promise,hang,join,PMKPromise,when,race}.m'
    cc += hh

    ss.source_files = cc
    ss.public_header_files = hh
    ss.preserve_paths = 'Sources/AnyPromise+Private.h', 'Sources/PMKCallVariadicBlock.m', 'Sources/NSMethodSignatureForBlock.m'
end
```

## 14、创建文件软链接实现解耦

`cocoapods`插件文件，在`pod install`时创建文件软链

```ruby
require 'zd/core' #伪代码
require 'zd/abc/core' #伪代码

require 'cocoapods'
require 'json'
require 'pathname'
require 'fileutils'

module ZD # 伪代码
  module ABC # 伪代码
    module Service
      class AppDefineIntegration
        def before_all
          remove_not_exist_soft_link
        end

        def prepare_install
          create_soft_link
        end

        def remove_unused_files(dir, used_files)
          dir = Pathname.new(dir)
          dir.children.each do |child|
            next if used_files.include?(child.to_s)
            FileUtils.rm_rf(child)
          end
        end

        def remove_not_exist_soft_link
          Dir.glob("#{soft_link_destination_dir}/*.h").each do |file_path|
            FileUtils.rm_rf(file_path) unless File.exist?(file_path) # 真身不存在时，需要删除软连
          end
        end

        def create_soft_link
          FileUtils.mkdir_p(soft_link_destination_dir) unless File.exist?(soft_link_destination_dir)
          
          # 目标文件名
          service_name = "MyAppDefine"

          # 遍历所有本地pod，查找`myappdefine.h`
          pod_local_path_map.each do |pod_name, pod_path|
            # 如果当前目录下已经存在此文件则不需要做软链，跳过，避免陷入死循环
            next if File.exist?(File.join(soft_link_destination_dir, "#{service_name}.h"))

            pod_dir = File.expand_path("#{root_dir}/#{pod_path}")
            file_path = Dir.glob("#{pod_dir}/**/#{service_name}.h").first

            # 不存在则跳过
            next if file_path.nil?

            source_file_path = Pathname.new(File.expand_path(file_path))
            dest_file_path = Pathname.new(File.join(soft_link_destination_dir, File.basename(file_path)))
            dest_dir_path =  Pathname.new(File.dirname(dest_file_path.to_s))
            # 创建软链
            FileUtils.ln_sf(source_file_path.relative_path_from(dest_dir_path), dest_file_path)
          end
        end

        def root_dir
          @root_dir ||= Pod::Config.instance.project_root.to_s
        end

        def pod_root_dir
          @pod_root_dir ||= Pod::Config.instance.project_pods_root.to_s
        end

        def current_dir
          @current_dir ||= File.expand_path(File.dirname(__FILE__))
        end

        def soft_link_destination_dir
          # 路径可以自己指定
          @soft_link_destination_dir = File.join(current_dir, "Core", "Link")
        end

        def podfile_info
          @podfile_info ||= ABC.pod_file_info # 伪代码
        end

        def pod_local_path_map
          @pod_local_path_map ||= begin
            podfile_info.local_root_pod_deps.each_with_object({}) do |dep, hash|
              next unless dep.external? && dep.external_source.include?(:path)
              hash[dep.root_name] = dep.external_source[:path]
            end
          end
        end

      end

    end
  end
end
```

## 15、使用自定义的Podspec代替原仓库的Podspec

用以方便的解决原仓库`Podspec`配置错误或者想使用`fork`版本的问题

```ruby
# Local Podspec
pod 'CombineCocoa', :podspec => './CustomPodspecs/CombineCocoa.podspec'

# Remote Podspec
pod 'CombineCocoa', :podspec => 'https://example.com/CombineCocoa.podspec'
```

## 16、通过pod hook修改源代码

```ruby
# 通过pod修改代码
post_install do |installer|
    installer.pods_project.targets.each do |target|
      if target.name == 'Flipper'
        file_path = 'Pods/Flipper/xplat/Flipper/FlipperTransportTypes.h'
        contents = File.read(file_path)
        unless contents.include?('#include <functional>')
          File.chmod(0755, file_path)
          File.open(file_path, 'w') do |file|
            file.puts('#include <functional>')
            file.puts(contents)
          end
        end
      end
    end
end
```

## 17、在`podspec`中添加编译宏

> 在`podspec`中添加编译宏，在`Objective-C`中添加编译宏使用`GCC_PREPROCESSOR_DEFINITIONS`，在`Swift`中添加编译宏使用`SWIFT_ACTIVE_COMPILATION_CONDITIONS`
> 
> 参考：[https://guides.cocoapods.org/syntax/podspec.html#pod_target_xcconfig](https://guides.cocoapods.org/syntax/podspec.html#pod_target_xcconfig)

```ruby
spec.pod_target_xcconfig = {
  'DEFINES_MODULE' => 'YES',
  'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES',
  # Objective-C中添加编译宏
  'GCC_PREPROCESSOR_DEFINITIONS' => 'ZDFL=1',   
  # Swift中添加编译宏(注意宏变量后面没有=1)    
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'ZDFL',  
  # Swift中开启实验性功能
  ## 参考： https://github.com/reers/ReerRouter/blob/main/ReerRouter.podspec
  'OTHER_SWIFT_FLAGS' => '-enable-experimental-feature NoncopyableGenerics -enable-experimental-feature Lifetimes',
}
```

## 18. 使用bundler统一管理团队`pod`版本

```ruby
# 初始化bundle
bundle init
# 在Gemfile中添加依赖

# 安装依赖
bundle install
# 执行命令
bundle exec pod install
```

## 19. 判断是否是本地`pod`

```ruby
post_install do |installer|
  # 方法1: 检查Podfile.lock
  # Podfile.lock 文件记录了每个 Pod 的来源信息。如果一个 Pod 是本地 Pod，它的路径会以 :path 指定。可以在 post_install 钩子中读取 Podfile.lock 文件并解析这些信息。
  require 'yaml'
  require 'set'
  podfile_lock_path = File.join(installer.sandbox.root.parent, 'Podfile.lock')
  podfile_lock = YAML.load_file(podfile_lock_path)

  local_pods = Set["Pods"] # 本地Pod列表, 由于cocoapods创建的总target工程命名规则是Pods-XXX, 所以这里加上Pods避免误判
  handled_remote_pods = Set.new # 已处理的Pod列表
  podfile_lock['EXTERNAL SOURCES'].each do |pod|
    next if pod.is_a?(Array) == false
    pod_name = pod[0]
    pod_options = pod[1]
    if pod_options && pod_options[:path]
      local_pods << pod_name
    end
  end

  # 方法2: 检查 Pods/Local Podspecs 目录
  # 当安装本地 Pod 时，CocoaPods 会将本地 Pod 的 podspec 文件复制到 Pods/Local Podspecs 目录。可以通过检查这个目录来判断是否有本地 Pod。
  local_podspecs_dir = File.join(installer.sandbox.root, 'Local Podspecs')
  Dir.glob(File.join(local_podspecs_dir, '*.podspec*')).each do |podspec_path|
    # 去掉扩展名取文件名
    podspec_name = File.basename(podspec_path, '.podspec')
    podspec_name = File.basename(podspec_name, '.json') if podspec_name.end_with?('.json')
    puts "#{podspec_name} is a local pod"
  end

  # 方法 3：检查 Pods 目录中的文件
  # 如果本地 Pod 的文件是直接从本地路径复制到 Pods 目录的，可以通过检查 Pods 目录中的文件来判断。
  pods_dir = installer.sandbox.root
  Dir.glob(File.join(pods_dir, '*')).each do |pod_dir|
    pod_name = File.basename(pod_dir)
  end

  ##########################################################

  installer.pods_project.targets.each do |target|
    # 带resource的pod会自动生成同名的pod，格式大概如下：podname-xxxx
    # 所以这里简单处理下，只截取"-"前面的pod名字，避免多次处理
    real_name = target.name.split('-').first

    # 方法 4: 检查pod的源码路径
    pod_root_path = installer.sandbox.pod_dir(target.name)
    is_local_path = !pod_root_path.to_s.include?('Pods') # 如果路径中不包含 Pods，则认为这是一个本地路径
  end
end
```

## 20. 区分`Debug`和`Release`环境

```ruby
# Debug环境
pod 'CombineCocoa', :podspec => './CustomPodspecs/CombineCocoa.podspec', :configurations => ['Debug']

# Release环境
pod 'CombineCocoa', :podspec => './CustomPodspecs/CombineCocoa.podspec', :configurations => ['Release']
```

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      # Debug环境开启编译缓存
      if config.name == 'Debug'
        config.build_settings['COMPILATION_CACHE_ENABLE_CACHING'] = 'YES'
      elsif config.name == 'Release'
        config.build_settings['COMPILATION_CACHE_ENABLE_CACHING'] = 'NO'
      end
    end
  end
end
```

## 21. 使用`pod`安装本地`podspec`

```ruby

---

### 参考：

- [podspec 语法指南](http://guides.cocoapods.org/syntax/podspec.html)

- [podfile 语法指南](https://guides.cocoapods.org/syntax/podfile.html)

- [开启 Cocoapods 新选项，加快项目索引速度](https://kemchenj.github.io/2019-05-31/)

- [Flipper](https://fbflipper.com/docs/getting-started/ios-native/)
