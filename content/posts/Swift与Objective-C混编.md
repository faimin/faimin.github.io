---
title: "Swift与Objective-C混编"
date: 2020-11-04T18:21:55+08:00
lastmod: 2022-09-07T19:40:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: "CocoaPods组件中Swift与Objective-C混编"
tags: ["iOS", "swift"]
categories: ["混编"]

images: []
featuredImage: ""
featuredImagePreview: "/images/swiftocmix/cover_luoxiaohei.png"
---


<!--more-->

## 前言

> 本文是笔者在解决混编时的一些记录，有些东西可能已经发生了变化。而且由于只是随手记录，写的比较乱，各位看官见谅~~~
> 
> 笔者负责的业务是以`pod模块`的形式存在于工程中的，所以以下调研的方案只针对于`pod`中的混编场景，在MM主工程混编几乎是无缝，没什么可说的。。。
> 
> 推荐大家浏览下 `CocoaPods（podfile & podspec）` 的 `API`，没几个，花费不了几分钟，但是却能帮助大家少踩很多的坑，一本万利~


## 前期方案

暂时采用折中方案，把`Swift`独立成一个`pod`，然后业务`pod`再引用`Swift pod`。目的是减少依赖，避免引用不规范的`repo`。

> 如果打算在同一`pod`中混编，只要把你依赖的库都支持`module`即可，而且需要修改一下你们引用外部`repo`头文件的形式，比如 `#import "SDWebImage.h"` 改为 `#import <SDWebImage/SDWebImage.h>`

1. 在MM主工程中创建个新的`Swift`文件（空文件即可），让`Xcode`自动生成一个`bridge-header`，目的是营造一个`Swift`环境（之前一直想不修改主工程而只在pod中营造，但是很遗憾，最后以失败告终）；

2. 由于混编`pod`中依赖的`repo`需要支持`module`，但是MM中的`pod`水平参差不齐，大部分都没有支持`module`，这就限制我们在业务`pod`中混编时编译失败。而让`pod`一下子都支持`module`是一个不太现实的要求，所以我们暂时采用了一种折中的方案；

3. 把`Swift`单独放一个`pod`中去，让`Swift`尽量少的依赖其他`repo`，然后业务`pod`再依赖`Swift repo`来调用`Swift`代码；


## 踩坑记录

- `pod`中不支持`bridging-header`，所以混编`pod`中要想引用`OC`类，`pod`需要支持`module`
- ~~混编的`Swift`库需要打成`framework`形式才可以编译成功，比如`RxCocoa`、`PromiseKit`~~
- 限于苹果本身机制和现有二进制方案实现问题，不支持 `:modular_headers => true`，所以使用`:modular_headers => true` 时临时需要添加参数`:use_source_code => true`，切换为代码编译；
- ~~`Swift`与`OC`混编的`pod`所依赖的库需要改为动态库，比如`ZDFlexLayout`内部为Swift与OC混编的，依赖了`Yoga`，需要把`Yoga`编为动态库。~~ 报错如下图

![undefine_symbol](/images/swiftocmix/undefine_symbol.png "undefine_symbol")

> 实际操作

1. 跨模块引用时需要把要暴露给外部的类或者函数的访问权限设置为 `public`，并标记为 `@objc`，同时需要继承自`NSObject`类

2. `pod` 中引用其他`pod`都是通过 `@import` 语法

3. `Swift`依赖的`repo`需要`module`化，
   
   > 有3种方式：
   >
   > i: 在`podfile`中让所有的`repo`开启`modular`: `use_modular_headers!`
   >
   > ii: 只给某几个repo开启modular，举个例子：`pod 'SDWebImage', :modular_headers => true`
   >
   > iii: 让repo自己开启module支持，需要在podspec中修改下设置：`spec.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }` , 这个设置不管你开不开启`modular`开关，都会自动创建`module`

4. 如果`podspec`中不设置`DEFINES_MODULE=true`，默认是不会生成`module`的，哪怕你在`podspec`中设置了`module_map`也不行，除非你在`podfile`中手动开启`modular_hear`你自己的`modulemap`才会生效

5. 如果你手动创建了`modulemap`就不要设置`DEFINES_MODULE=true`了，因为笔者发现开启`DEFINES_MODULE`后它还会自己再生成一份`xxx-umbraller`文件。
   
   > 推荐让`CocoaPods`帮我们创建`modulemap`，如非你特别懂`modulemap`，不建议自己手动创建。

6. 只需要把`Swift`用到的`OC`类放到`umbrella`中（后面说控制方法）


## 同一混编pod内OC调用Swift

在头文件中引入 `#import <module-name>-Swift.h"`，然后就可以调用`Swift`类了

![image.png](/images/swiftocmix/oc_import_swift.png "oc_import_swift")

## 同一混编pod内Swift调用OC

同一`pod`中，把`oc`类引用放入`umbrella`中（默认就有了），然后需要这个文件能被找到。

1. 一种方式是修改此文件的`membership`为`public`，目的是为了把它移到`public header`中去（静态库形式`pod`中的文件默认都是`project`的，动态库形式的`pod`才会区分`public`、`private`、`project`）
   
   > 修改起来成本比较高，不推荐

    ![image.png](/images/swiftocmix/member_ship.png "member_ship")  

    ![image.png](/images/swiftocmix/header.png "header")    

2. 第二种方式是把这个文件的路径包含搜索路径中，可以通过设置`podspec`中的 `spec.header_dir`参数
   
   > `header_dir` 可以是任意名字, 笔者一般会设置为`./`，即当前文件夹
   > 
   > ----
   > 
   > **这个选项也不是万能的，你会发现就算设置了这个选项，也会出现报错的问题。建议业务方的pod如无必要，把类都放到`private_header_files` 中，减少`umbrella` 中的头文件数量。**
   
    如下设置

    ![image.png](/images/swiftocmix/header_dir_set.png "header_dir_set")

> 静态库中的`import`需要是全路径的，而动态库中的搜索路径会被`flatten`，所以动态库不会出现此问题

**不过这里有点需要注意的是，设置 `header_dir` 后需要同时设置 `module_name`，否则 `modulename` 默认会取 `header_dir` 的值。。。** 

其实官方文档上都有提到，惭愧

![image.png](/images/swiftocmix/module_name.png "module_name")


## 解惑

#### 为什么能够混编？

> 能够互相调用的类都需要继承`NSObject`
>
> `Swift`中的类和`Objective-C`中的类底层元数据（`class metadata`）是共用的

```cpp
// objc4-818.2
// objc-runtime-new.h

typedef struct objc_class *Class;
typedef struct objc_object *id;

struct objc_object {
private:
    isa_t isa;

    // ...
};

struct objc_class : objc_object {
    // Class ISA;
    Class superclass;
    cache_t cache;             // formerly cache pointer and vtable
    class_data_bits_t bits;    // class_rw_t * plus custom rr/alloc flags

    // ...
};

struct swift_class_t : objc_class {
    uint32_t flags;
    uint32_t instanceAddressOffset;
    uint32_t instanceSize;
    uint16_t instanceAlignMask;
    uint16_t reserved;

    uint32_t classSize;
    uint32_t classAddressOffset;
    void *description;
    // ...

    void *baseAddress() {
        return (void *)((uint8_t *)this - classAddressOffset);
    }
};
```

#### 1. XCode9 & Cocopoads 1.5 之后，不是已经支持把Swift编译为静态库了吗，为什么会报错呢？

第三方库对于把混编pod编译为静态库支持的不好，这不是苹果的锅，而是三方库未进行及时的适配，~~像`Kingfisher`、`RxCocoa`都有问题~~

> 这两个库笔者已经提了`pr` 来解决这个问题，现已合入主分支，从 `RxCocoa 6.1.0`、`Kingfisher 6.1.0` 开始都已支持编译为静态库;
> 
> - [RxCocoa #2281](https://github.com/ReactiveX/RxSwift/pull/2281)
> - [Kingfisher #1608](https://github.com/onevcat/Kingfisher/pull/1608)

#### 2. 为什么改为动态库就可以正常编译通过了？

静态库需要使用绝对路径引用，而动态库强制把头文件平铺了，所以动态库能引到，静态库引不到
    
可以自己验证一下，改成 `#import "<module-name>/xxxx.h"` 之后你再编译一下

#### 3. 为什么设置 header_dir 编译就不报错了？

默认情况下使用的是普通的`header` ，设置`header_dir`之后，`pod`会以`header_dir`为名称创建一个文件夹，然后把所有`public`出来的头文件引用放里面，`umbrella`引用头文件的时候其实指向的都是这里；

> 见源码

![image.png](/images/swiftocmix/header_dir_code.png "header_dir_code")

#### 4. `pod`中没有`bridging-header`为什么`Swift`还能引用`Objective-C`类？

`pod`中`umbrella`文件其实就相当于是主工程中的`bridging-header`。

#### 5. 为什么`Xcode`生成的`hmap`对我们的项目并没起到什么作用？

上面已经提到静态库的形式下我们的类文件的`membership`是`project`，`hmap`生成的是`#import "xx.h"`形式的引用路径的`cache`，而我们通常引用库文件的方式为`#import <A/B.h>`，这就导致我们的引用根本就没办法命中`hmap`中的映射缓存（`pcm`），所以最终还是会走`search_path`的查找逻辑。而且由于`Xcode`中的`USE_HEADERMAP`设置默认是开启的，`Xcode`在编译期还会自动创建对我们用处不大的`hmap`，而这个过程间接拖慢了我们的编译速度。


#### 6. `public`、`private`、`project`区别

- **Public**: The interface is finalized and meant to be used by your product’s clients. A public header is included in the product as readable source code without restriction. 

- **Private**: The interface isn’t intended for your clients or it’s in early stages of development. A private header is included in the product, but it’s marked “private”. Thus the symbols are visible to all clients, but clients should understand that they’re not supposed to use them. 

- **Project**: The interface is for use only by implementation files in the current project. A project header is not included in the target, except in object code. The symbols are not visible to clients at all, only to you.

`Project`和`Private`的权限或者说是作用基本一致，都是私有化的一种方式，只是`Project`权限的**头文件**是不会放到编译产物中的，**注意说的是头文件**，而`Private`头文件会放到编译产物中，只是告诉编译器不要暴漏给外界。`CocoaPods`是通过`Pods->Headers->Public/Private`目录管理头文件的引用，来控制对某一文件的访问权限的。


## 推荐设置

`podspec`中在不指定`private_header_files`或`project_header_files`的时候`source_files`路径下的文件默认全都是`public`的，而`public`的头文件默认都会放到`umbrella`中，这样很容易导致`umbrella`中头文件爆炸，尤其是业务`pod`（比如我们的直播业务有2300多个头文件），特别影响编译速度。

解决办法：把那些暴露给`swift`的头文件放到`public_header_files`中，其他的头文件则默认变成`project`类型。或者是把全部头文件默认指定为`private_header_files`或`project_header_files`，然后把需要公开的放到`public_header_files`中，尽量减少`umbrella`中头文件的数量。


贴一下供参考的`Swift podspec`，请按需修改

```ruby
Pod::Spec.new do |spec|
  spec.name         = "foo"
  spec.version      = "0.0.1"
  spec.summary      = "foo"
  spec.description  = <<-DESC
    我是一只小柯基
                   DESC
  spec.homepage     = "https://foo/bar/abc"
  spec.license      = "MIT"
  spec.platform     = :ios, "12.0"
  spec.source       = { 
    :git => "https://foo/bar/abc.git", 
    :tag => "#{spec.version}" 
  }
  spec.swift_versions = ['5.1']

  publicHeaders = Dir["Source/Room/PublicHeaders/*.h"]
  privateHeaders = Dir["Source/Room/**/*.{h}"] - publicHeaders
  spec.source_files = 'Source/Room/**/*.{h,m,swift}'
  spec.public_header_files = publicHeaders
  # 下面这行可有可无，设置的话会放到private中，不设置则等价于 `spec.project_header_files = privateHeaders`，会放到project中
  # spec.private_header_files = privateHeaders

  spec.module_name = spec.name
  spec.header_dir = "./"

  spec.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
  }

  spec.dependency 'RxCocoa'
  spec.dependency 'Cartography', '~> 4.0.0'
  spec.dependency 'ZDFlexLayoutKit'
end
```

> CocoaPods 骚操作：

用踩坑中提到的`RxCocoa`做例子，为了编译成功，我们需要把它指定为动态库，而其他的保持不变，这种需求我们可以在 `pre_install` 阶段动态修改编译模式：把`dynamic_framework`数组中的`repo`编译为`framework`，其他未指定的默认还是静态库。

```ruby
pre_install do |installer|    
    #以framework形式存在的pod
    dynamic_frameworks = ['RxSwift', 'RxCocoa', 'RxRelay'] 
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
    installer.pod_targets.each do |pod|
      if dynamic_frameworks.include?(pod.name)
        def pod.build_type;
          Pod::BuildType.dynamic_framework
        end
      end
    end
end
```

```ruby 
pre_install do |installer|
    #以静态库形式存在的pod
    static_library = ['Masonry', 'SDWebImage']
    Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
    installer.pod_targets.each do |pod|
      if static_library.include?(pod.name)
        def pod.build_type;
          Pod::BuildType.static_library
        end
      end
    end
end
```

## 参考

- [importing_objective-c_into_swift](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift)

- [importing_swift_into_objective-c](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_swift_into_objective-c)

- [https://www.rubydoc.info/gems/cocoapods-core/Pod/BuildType](https://www.rubydoc.info/gems/cocoapods-core/Pod/BuildType)

- [https://github.com/CocoaPods/CocoaPods/pull/7724](https://github.com/CocoaPods/CocoaPods/pull/7724)

- [PromiseKit.podspec 6.15.3](https://github.com/mxcl/PromiseKit/blob/6.15.3/PromiseKit.podspec)

- [从预编译的角度理解Swift与Objective-C及混编机制](https://tech.meituan.com/2021/02/25/swift-objective-c.html)