# fishhook查找过程


fishhook实现原理

<!--more-->

C语言是门静态语言，在编译的时候就已经确定了函数地址，而系统的函数由于存放在了共享缓存库中，必须在 dyld 加载的时候（运行时）才能确定。
为了解决这个问题，苹果针对 Mach-O 文件提供了一种 PIC 技术，即在 Mach-O 的 _Data 段中添加懒加载表 （Lazy Symbol Pointers） 和非懒加载表 （Non-Lazy Symbol Pointers） 这两个表，让系统的函数在编译时先指向懒加载表(Lazy Symbol Pointers)或非懒加载表(Non-Lazy Symbol Pointers)中的符号地址； 这2个符号表的地址指向0（ 在编译的时候并没有指向任何地方），app启动时被 dyld 加载到内存，然后在这个时候进行链接，给这2个表赋值动态缓存库的地址，进行符号绑定。

![](/images/fishhook/fishhook_find_process.png "fishhook查找过程")

## 详细查找过程

`Lazy Symbol Pointer Table --> Indirect Symbol Table --> Symbol Table --> String Table` 
如果字符串表中的value与传进来的相同，说明是我们要替换的函数，那么我们就把`__DATA`段中的函数地址替换成我们自己的函数地址。

外部的函数存在于共享库中，不是在编译期就固定的，而是在第一次调用时，比如 `NSLog`。这里我们就拿它举例(它存在于懒加载符号表中)。

1、首先从懒加载符号表中找到它，记录它的`index`（在这个表中第几个位置，类似数组的下标，后面会用到）

![](/images/fishhook/fishhook_1.webp "懒加载表中查找nslog")

2、然后去`动态符号表`中的`间接符号表`中根据先前的`index`去查找，`懒加载符号表`和`间接符号表`的顺序是一一对应的；把`间接符号表`中找到的那一块数据中的`data （0x00007749）`换算成十进制，即`30537`，根据这个十进制数到`符号表`中去查找；

![](/images/fishhook/fishhook_2.webp "符号表中查找nslog")

3、符号表中的位置

![](/images/fishhook/fishhook_3.webp "符号表中的位置")

4、最后字符串表中查找，这里需要用`字符串表的首地址（0x00245528）+ 符号表中的地址（0x0000C02E）`作为`NSLog`在`字符串表`中位置

![](/images/fishhook/fishhook_4.webp "字符串表中查找")

## 参考

- [mach-o got表介绍](https://mp.weixin.qq.com/s/zIlYqfx99xK7QQUJCGUQ_g)
- [图解fishhook原理](https://mp.weixin.qq.com/s/dcQrR4knN0aGDPy2hsrgmg)


