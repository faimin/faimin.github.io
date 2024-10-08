---
weight: 10
title: "iOS源码阅读笔记"
date: 2022-06-09T17:06:35+08:00
lastmod: 2022-10-12T15:42:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: ""
tags: ["iOS", "runtime", "面试"]
categories: ["实现原理"]

images: []
featuredImage: ""
featuredImagePreview: "/logo/welcome.jpg"
---

源码学习笔记

<!--more-->

## 平台宏

```cpp
// TargetConditionals.h

/*
 *  TARGET_OS_*
 *
 *  These conditionals specify in which Operating System the generated code will
 *  run.  Indention is used to show which conditionals are evolutionary subclasses.
 *
 *  The MAC/WIN32/UNIX conditionals are mutually exclusive.
 *  The IOS/TV/WATCH/VISION conditionals are mutually exclusive.
 *
 *    TARGET_OS_WIN32              - Generated code will run on WIN32 API
 *    TARGET_OS_WINDOWS            - Generated code will run on Windows
 *    TARGET_OS_UNIX               - Generated code will run on some Unix (not macOS)
 *    TARGET_OS_LINUX              - Generated code will run on Linux
 *    TARGET_OS_MAC                - Generated code will run on a variant of macOS
 *      TARGET_OS_OSX                - Generated code will run on macOS
 *      TARGET_OS_IPHONE             - Generated code will run on a variant of iOS (firmware, devices, simulator)
 *        TARGET_OS_IOS                - Generated code will run on iOS
 *          TARGET_OS_MACCATALYST        - Generated code will run on macOS
 *        TARGET_OS_TV                 - Generated code will run on tvOS
 *        TARGET_OS_WATCH              - Generated code will run on watchOS
 *        TARGET_OS_VISION             - Generated code will run on visionOS
 *        TARGET_OS_BRIDGE             - Generated code will run on bridge devices
 *      TARGET_OS_SIMULATOR          - Generated code will run on an iOS, tvOS, watchOS, or visionOS simulator
 *      TARGET_OS_DRIVERKIT          - Generated code will run on macOS, iOS, tvOS, watchOS, or visionOS
 *
 *    TARGET_OS_EMBEDDED           - DEPRECATED: Use TARGET_OS_IPHONE and/or TARGET_OS_SIMULATOR instead
 *    TARGET_IPHONE_SIMULATOR      - DEPRECATED: Same as TARGET_OS_SIMULATOR
 *    TARGET_OS_NANO               - DEPRECATED: Same as TARGET_OS_WATCH
 *
 *    +--------------------------------------------------------------------------------------+
 *    |                                    TARGET_OS_MAC                                     |
 *    | +-----+ +------------------------------------------------------------+ +-----------+ |
 *    | |     | |                  TARGET_OS_IPHONE                          | |           | |
 *    | |     | | +-----------------+ +----+ +-------+ +--------+ +--------+ | |           | |
 *    | |     | | |       IOS       | |    | |       | |        | |        | | |           | |
 *    | | OSX | | | +-------------+ | | TV | | WATCH | | BRIDGE | | VISION | | | DRIVERKIT | |
 *    | |     | | | | MACCATALYST | | |    | |       | |        | |        | | |           | |
 *    | |     | | | +-------------+ | |    | |       | |        | |        | | |           | |
 *    | |     | | +-----------------+ +----+ +-------+ +--------+ +--------+ | |           | |
 *    | +-----+ +------------------------------------------------------------+ +-----------+ |
 *    +--------------------------------------------------------------------------------------+
 */
 ```

## Runtime

一个类最多能添加`64`个分类。

~~`AutoreleasePoolPage`~~ 、`SideTableMap`、`AssociationsManager` 是在`map_images->map_images_nolock->arr_init()` 函数中初始化的；

```cpp
void arr_init(void) 
{
    SideTablesMap.init();
    _objc_associations_init();

#if !TARGET_OS_EXCLAVEKIT
    if (DebugScanWeakTables)
        startWeakTableScan();
#endif
}
```

### dyld加载流程

> 引自飘云的[dyld详解](https://www.dllhook.com/post/238.html)

- 第一步：设置运行环境
- 第二步：加载共享缓存
- 第三步：实例化主程序
- 第四步：加载插入的动态库
- 第五步：链接主程序
- 第六步：链接插入的动态库
- 第七步：执行弱符号绑定
- 第八步：执行初始化方法（runtime和类的加载是在这一步）
- 第九步：查找入口点并返回

##### 叙述一下：

1. 配置环境变量，开启共享缓存，接下来把主程序的可执行文件（`macho`）加载进内存，检测`macho`内的`magic`、`cpu`等属性以及兼容性，如果通过则创建一个`imageLoader`，然后插入动态库，链接主程序（加载进所有依赖库，然后`rebase`修正偏移、`rebind`绑定符号地址）和插入的动态库，然后执行弱符号绑定，接下来就是进入真正的初始化方法，如下图，当`dyld`加载到开始链接主程序的时候，递归调用`recursiveInitialization`函数；

![](/images/opensource/ios/Runtime_objc_init.png "_objc_init")
![](/images/opensource/ios/Runtime_recursiveInitialization.png "recursiveInitialization")

2. 这个函数第一次执行，会走到 `doInitialization` -> `doModInitFunctions` -> l`ibSystemInitialized`，进行`libsystem`的初始化；
3. `libsystem` 的初始化，它会调用起 `libdispatch_init`，`libdispatch` 的 `init` 会调用 `_os_object_init`，这个函数里面调用了 `_objc_init`；
4. `_objc_init`中注册并保存了`map_images`、`load_images`、`unmap_image`函数地址；
5. 注册完毕继续回到 `recursiveInitialization` 递归下一次调用，例如 `libobjc`，当 `libobjc` 来到 `recursiveInitialization` 调用时会触发`libsystem`，调用到`_objc_init`里注册好的回调函数进行调用，就来到了`libobjc`，调用`load_images`。

### 类的加载

1. `read_image`： 初始化`gdb_objc_realized_classes`表，容量是类总数量的 `4/3` 倍，这个表用来存放不在共享缓存中并且非懒加载类。接下来从`mach-o`中读取非懒加载类，把从`mach-o`中读取的类指针转换成类名，变成可识别的类（地址 -> 类名），然后加入前面创建的`gdb_objc_realized_classes` map表中（这个表的作用是在后面处理类有没有被正确的处理），同时也会加入 `allocatedClasses` 这个`set`表中（这个表是在 `_objc_init` 中的 `runtime_init` 函数中初始化的，存储的是已经初始化过的类）。总的来说，这一步就是把类读取到内存；
2. 接下来就是重点方法`realizeClassWithoutSwift`：创建`rw（class_rw_t）`，把从`class`中获取`(ro = cls->safe_ro()）`到的`ro（class_ro_t）`放到`rw`中（方法列表是在后面放的），递归执行`realizeClassWithoutSwift`，即递归设置`rw`；
3. 设置类、父类和元类，其实就是生成一个双向链表；
4. `methodizeClass` ：获取`class`的`ro`中的`baseMethods`，通过`prepareMethodLists`函数进行方法升序排序，然后 `unttachedCategories::attachToClass` ，这里是重头戏，`attachToClass`中会执行`attachCategories`，在这里面会初始化`rwe（class_rw_ext_t）`，在这过程中会把`ro`中的**方法列表、属性列表、协议列表**都复制到`rwe`中，然后接着会把`category`中的**方法列表、属性列表、协议列表**也会吸纳进去，此时类才算加载完成；
5. 方法排序的这里有几个细节：在`methodizeClass`中首次从`class_ro_w`中拿到`basemethods`后就立即做了升序排序处理，而分类中的方法排序发生在`attachCategory`方法中，也就是说他们是分开并各自独立排序的。
    > 疑问：没有整合到一起后再排序，那怎么用的二分查找？
    > 
    > 解答：
    >
    > 只有类和分类都实现`load`方法，才会存在`load_image`阶段分类方法整合到所属类的方法列表中的操作，也就是说只有类或者分类中实现`load`方法的情况，类的方法列表和分类方法列表都是直接在编译期存放在`class_ro_t`中的`baseMethods`中的。</br>
    > 那这种情况怎么能保证分类方法在原始类方法前面呢？应该是编译器自己在编译期做的处理：让分类方法地址比原始类的方法地址要低。而对于二分查找，整合后的方法列表其实是个二维数组，内部存的是排好序的一维方法列表（`methodizeClass`阶段`preparemethod`进行方法排序），方法查找先是顺序遍历二维数组，再在有序的一维方法列表中进行二分查找。
    >
6. 方法添加顺序：新建个数组，先把类中`class_ro_w`的`basemethods`放到数组后面，然后把分类方法放到数组前面。

#### 为什么`category`会覆盖原来的方法？

在`map_images`函数的 `attachCategories -> attachLists` 分类附加到原来的类的方法列表时，会先重新开辟一个新的数组，把原来的方法列表倒序遍历添加到新数组的后面，接着再正序遍历，把分类的方法添加到新数组的前面（方法列表的顺序与原来的顺序一致）；

![methodLists](/images/opensource/ios/Runtime_AttackMethodLists.png "methodLists")

#### 类和`category`实现`load`对加载的影响

只有类和分类都实现`load`方法，才会发生在`load_image`阶段分类方法整合到所属类的方法列表中的操作; 只有类或者分类中实现`load`的时候，类的方法和分类方法都是直接在编译期存放到`class_ro_t`中的`baseMethods`中的。那这种情况怎么能保证分类方法在原始类方法前面的？这应该是编译器自己在编译期做的处理，让分类方法地址比原始类的方法地址要低（方法排序用的是升序排序）。

而对于类和分类都实现`load`的场景，即在`load_image`阶段把分类方法整合到类的方法列表中的情况是如何进行二分查找的呢？其实整合后的方法列表是个二维数组，内部存的是排好序的一维方法列表（`methodizeClass`阶段`preparemethod`进行的方法升序排序），方法查找时先是顺序遍历二维数组，再在有序的一维方法列表中进行二分查找。

综上所述，不要在类和分类中同时实现`load`方法也是提升启动速度的一个点，当然，不用`load`最好了。

#### 为什么会有CleanMemory和DirtyMemory呢？

- `iOS`运行过程中会涉及对内存进行增删改查，为了防止对原始数据的修改，所以把原来的`CleanMemory` `copy`一份到`rw`中。
- 有了`rw`为什么还要`rwe`（`DirtyMemory`）？因为并不是所有的类加载进内存时都需要进行动态的插入、删除，我们添加一个属性、一个方法会对内存改动很大，对内存的占用也有一定影响，所以我们只要对类进行动态处理了（比如把`category`的方法、属性、协议合并到类中），就会生成一个`rwe`。

#### 为什么执行`load`方法时没有触发`initialize`？

一定要明确一个概念：`initialize`在首次发消息时才会触发，而`load`的执行是通过函数指针的方式调用的，并没有走消息发送机制，所以也就不会触发`initialize`。

#### 如何判断一个类是否已经初始化？

```cpp
// objc-runtime-new.h
struct objc_class : objc_object {
    uint32_t getMetaFlags() const {
        ASSERT(!isStubClass());

        uint32_t flags = bits.flags();
        if (flags & RW_META)
            return flags;
        return this->ISA()->bits.flags();
    }

    // 类是否已经初始化完成
    bool isInitialized() const {
        return getMetaFlags() & RW_INITIALIZED;
    }
}
```

参考`objc_class`的结构构造一个相同的数据结构，然后模仿原实现获取到是否已经初始化的标识。可以参考[SLMClassCoverage](https://github.com/HarrisonXi/SLMClassCoverage/blob/main/SLMClassCoverage.m)中的实现。

#### 为什么在对象释放过程中通过`weak`变量获取不到这个对象？

在关联的场景中，比如`A`关联`B`，`B`弱持有`A`，`A`释放时会释放其关联的`B`，导致`B`的`dealloc`执行，然后我们在`B`的`dealloc`方法中通过`weak`变量读取`A`，却发现获取到的是`nil`（根据释放流程此时`A`还没有`free`掉），这是为什么？

分析如下：

读取`weak`变量时执行的是`objc_loadWeak`函数，内部执行大概流程为：`objc_loadWeak` -> `objc_loadWeakRetained` -> `obj->rootTryRetain()` -> `rootRetain(true, RRVariant::Fast)` ，在`rootRetain`中如果当前对象正在处于释放流程中，则返回`nil`。具体代码如下：

```cpp
id
objc_loadWeakRetained(id *location)
{
    id obj;
    id result;
    Class cls;

    SideTable *table;
    
 retry:
    obj = *location;
    if (_objc_isTaggedPointerOrNil(obj)) return obj;
    
    table = &SideTables()[obj];
    
    table->lock();
    if (*location != obj) {
        table->unlock();
        goto retry;
    }
    
    result = obj;

    cls = obj->ISA();
    if (! cls->hasCustomRR()) {
        // 执行此逻辑
        if (! obj->rootTryRetain()) {
            result = nil;
        }
    }
    else {
        // 执行不到的逻辑，删掉
    }
        
    table->unlock();
    return result;
}

ALWAYS_INLINE bool 
objc_object::rootTryRetain()
{
    return rootRetain(true, RRVariant::Fast) ? true : false;
}

ALWAYS_INLINE id
objc_object::rootRetain(bool tryRetain, objc_object::RRVariant variant)
{
    if (slowpath(isTaggedPointer())) return (id)this;

    bool sideTableLocked = false;
    bool transcribeToSideTable = false;

    isa_t oldisa;
    isa_t newisa;

    oldisa = LoadExclusive(&isa().bits);

    // ...

    do {
        transcribeToSideTable = false;
        newisa = oldisa;

        // 关键逻辑：
        // 如果正在释放中，并且tryRetain=true，则返回nil
        // don't check newisa.fast_rr; we already called any RR overrides
        if (slowpath(newisa.isDeallocating())) {
            ClearExclusive(&isa().bits);
            if (sideTableLocked) {
                ASSERT(variant == RRVariant::Full);
                sidetable_unlock();
            }
            if (slowpath(tryRetain)) {
                return nil;
            } else {
                return (id)this;
            }
        }
        uintptr_t carry;
        newisa.bits = addc(newisa.bits, RC_ONE, 0, &carry);  // extra_rc++

        if (slowpath(carry)) {
            // newisa.extra_rc++ overflowed
            if (variant != RRVariant::Full) {
                ClearExclusive(&isa().bits);
                return rootRetain_overflow(tryRetain);
            }
            // Leave half of the retain counts inline and 
            // prepare to copy the other half to the side table.
            if (!tryRetain && !sideTableLocked) sidetable_lock();
            sideTableLocked = true;
            transcribeToSideTable = true;
            newisa.extra_rc = RC_HALF;
            newisa.has_sidetable_rc = true;
        }
    } while (slowpath(!StoreExclusive(&isa().bits, &oldisa.bits, newisa.bits)));

    if (variant == RRVariant::Full) {
        if (slowpath(transcribeToSideTable)) {
            // Copy the other half of the retain counts to the side table.
            sidetable_addExtraRC_nolock(RC_HALF);
        }

        if (slowpath(!tryRetain && sideTableLocked)) sidetable_unlock();
    } else {
        ASSERT(!transcribeToSideTable);
        ASSERT(!sideTableLocked);
    }

    return (id)this;
}
```

既然没释放，那我们怎么拿到这个对象呢？通过`unsafe_unretained`或者`assign`标记就可以获取到了。


### 对象释放流程

调用`release` -> `rootRelease`，引用计数`-1`，当引用计数变为`0`时，就会通过`objc_msgSend`调用`Objective-C`对象的`dealloc`方法，然后进入到`objc_object::rootDealloc()`函数，函数内部会读取当前对象的`isa`中存储的信息，包括是否是非指针、有没有弱引用、成员变量、关联对象、`has_sidetable_rc`，如果都没有会直接释放（`free`），否则会执行`objc_destructInstance(obj)`，这个函数的逻辑为：先释放成员变量，接着移除关联对象，再移除弱引用，把弱引用指针置为`nil`，最后再从`SideTable`的`RefcountMap refcnts`成员变量中 把存储当前对象引用计数的记录（`key-value`）从引用计数表中移除，类似于从字典中把这条`key-value`都删除（疑问：此时引用计数已经是0了，那最后这个引用计数表的处理是不是多余的，什么情况下会执行进来？？？）。

```cpp
/***********************************************************************
* objc_destructInstance
* Destroys an instance without freeing memory.
* Calls C++ destructors.
* Calls ARC ivar cleanup.
* Removes associative references.
* Returns `obj`. Does nothing if `obj` is nil.
**********************************************************************/
void *objc_destructInstance(id obj)
{
    if (obj) {
        // Read all of the flags at once for performance.
        bool cxx = obj->hasCxxDtor();
        bool assoc = obj->hasAssociatedObjects();

        // This order is important.
        if (cxx) object_cxxDestruct(obj);
        if (assoc) _object_remove_associations(obj, /*deallocating*/true);
        obj->clearDeallocating();
    }

    return obj;
}
```

什么场景下才会有`cxxdtor`？

```cpp
// class has .cxx_construct/destruct implementations
#define RO_HAS_CXX_STRUCTORS  (1<<2)

static Class realizeClassWithoutSwift(Class cls, Class previously) {
    ...
    
    // Copy some flags from ro to rw
    if (ro->flags & RO_HAS_CXX_STRUCTORS) {
        cls->setHasCxxDtor();
        if (! (ro->flags & RO_HAS_CXX_DTOR_ONLY)) {
            cls->setHasCxxCtor();
        }
    }

    ...
}
```

![](/images/runtime/cxx_construct.png "cxx_construct.png")


在`dealloc`方法中如果有对`self`的引用，比如`- (void)dealloc { id obj = self; }`，是不会发生引用计数`+1`的，`runtime`处理如下：

```cpp
// 是否正在释放
bool isDeallocating() {
    return extra_rc == 0 && has_sidetable_rc == 0;
}

ALWAYS_INLINE id 
objc_object::rootRetain()
{
    return rootRetain(false, RRVariant::Fast);
}

// retain最终执行的函数
ALWAYS_INLINE id
objc_object::rootRetain(bool tryRetain, objc_object::RRVariant variant)
{
    // 省略代码
    ... 

    // 在dealloc中这里的执行结果是true, tryRetain是false，
    // 所以会直接返回this
    if (slowpath(newisa.isDeallocating())) {
        ClearExclusive(&isa.bits);
        if (sideTableLocked) {
            ASSERT(variant == RRVariant::Full);
            sidetable_unlock();
        }
        if (slowpath(tryRetain)) {
            return nil;
        } else {
            return (id)this;
        }
    }

    // 省略代码
    ...
}
```

## Weak

`weak_table_t` 是全局保存弱引用的哈希表，它是通过对`object`地址做`hash`计算，然后从`8`个`SideTable`数组中取出其中一张，然后再从`SideTable`中读取到`weak_table`。`weak_table_t` 是以 `object` 地址为 `key`，以 `weak_entry_t` 为 `value`。

`weak_entry_t` 是用来存储所有指向某个对象的弱引用变量的地址的，里面有个`weak_referrer_t`数组，它存储的其实是弱引用的指针，即指针的指针，这么做的目的是可以把弱引用置为`nil`。

`weak_entry_t` 中有`2`种结构，当存储的弱引用数量`<= 4`个的时候用的其实是个定长数组，`> 4`的时候才会转为哈希数组。（这里使用哈希数组的原因应该是为了处理B弱引用A，然后B先释放了，这时那个弱引用可能也要置为nil，用hash数组的话查询速度会比较快）。往`weak_entry_t` 中添加弱引用变量时，即更新`weak_referrer_t`采用的是定向寻址法；

往`weak_table` 中插入`weak_entry_t`时，先是对`object`地址取`hash`作为它的`index`，如果这个`index`下的位置不为空，则通过一个算法（`index = (index+1) & weak_table->mask`）重新计算生成一个新的`index`再读取对应的位置，直到找到一个空位置，然后把`weak_entry_t`放进去，同时更新元素数量。这种插入方式其实也是定向寻址法。

> hash 函数，与 mask 做与操作，防止 index 越界;

```c
size_t begin = hash_pointer(referent) & weak_table->mask;
```

![weak_hash_insert](/images/opensource/ios/Runtime_WeakHashInsert.png "weak_hash_insert")

`weak_table_t` 还有一个扩容和缩容的处理，当前使用容量占到总容量（`mask + 1`)的 `3/4` 的时候会进行扩容处理，扩大到现有总容量的`2`倍。 当总容量超过`1024`，而实际使用的空间低于总空间的 `1/16` 时则会进行容量压缩，缩到现有总容量的`1/8` （为什么是八分之一？是为了保证总容量是现有使用容量的`2`倍）。

## @synchronized原理

1. 先从当前线程的`TLS`中尝试获取`SyncData`（本身是个单向链表），如果存在并且`SyncData`中的`object`与传进来的`object`相同，则说明找到对应的`SyncData`了。更新锁数量（`lockCount`），并返回`SyncData`。

   （注意：一条线程的`TLS`中只能存唯一一个`SyncData`，假如已经存在了但是`object`并不与自己传进来的一致，则创建新的`SyncData`后并不会更新到`TLS`中，而是保存到 `pthread_data` 中，有点先入为主的意思）
2. 从`pthread_data`中获取`SyncCache`（里面存着一个`SyncCacheItem`数组，`SyncCacheItem`存的是`SyncData`），如果存在则遍历`SyncCacheItem`数组，如果`cacheItem`中的`syncData`中的`object`与传进来的`object`相同，则更新 `item->lockCount` ，然后返回`SyncData`。
3. 走到这里就说明没有从`thread cache`中找到合适的`SyncData`。这时就会从全局`StripMap<SyncList> sDataLists` 表中读取，先通过对象`object`的`hash`值取出一个`SyncList`，接着拿到`SyncList`中的`SyncData`链表，然后遍历整个链表。

   a. 如果发现与`object`匹配的`SyncData`则更新`SyncData`中的`threadCount`数量，然后把找到的这个`SyncData`保存到`TLS`或者`pthread_data`中的`SyncCache`里面；

   b. 如果遍历到最后也没发现匹配的，则找到链表中第一个未使用（`SyncData`中的`threadCount = 0`）的`SyncData`，进行复用。这个`SyncData`也会和上面一样进行缓存；

   c. 如果没找到匹配的，也没找到未使用的，则创建一个新的`SyncData`。这个新的`SyncData`会先保存到`SyncList`中，然后也会和上面一样保存到`TLS`或者`pthread_data`中一份，即新创建的有2份缓存。

   ![@synchronized关系图](/images/opensource/ios/Runtime_Synchronized.png "synchronized")

## Associate 原理

所有的关联对象都是由`AssociationsManager`管理的，`AssociationsManager`里面是由一个静态`AssociationsHashMap`来存储所有的关联对象。这相当于把所有对象的关联对象都存在一个全局`hashMap`里面，`hashMap`的`key`是这个对象的`指针地址`（任意两个不同对象的指针地址一定是不同的），而这个`hashMap`的`value`又是一个`ObjectAssociationsMap`，里面保存了关联对象的`key`和对应的`value`值。`runtime`的销毁对象函数`objc_destructInstance`里面会判断这个对象有没有关联对象，如果有，则会调用`_object_remove_assocations`做关联对象的清理工作。

在`set`和`get`时，即对内部的`map`进行操作时都会用`manager`中的`spinlock`（底层其实还是`unfair_lock`），所以`set`、`get`时一般情况下是线程安全的。但是可能是为了追求性能，`set`时把旧对象的释放放到了锁外，`atomic get`时为了保证线程安全，会`retain`一下访问对象，在锁外又`autorelease`了一下，如果不执行`retain`操作可能会出现数据竞争。可以参考下这篇文章: [AssociatedObject 源码分析：如何实现线程安全？](https://juejin.cn/post/7124943924308738061)

![Associate](/images/opensource/ios/Runtime_Associate.png "Associate")

---

## Runloop

> 推荐：[029：runloop](https://www.cnblogs.com/zyzmlc/p/14087616.html)

> 摘自 `ibireme` 的 [深入理解runloop](https://blog.ibireme.com/2015/05/18/runloop/)

```cpp
{
    /// 1. 通知Observers，即将进入RunLoop
    /// 此处有Observer会创建AutoreleasePool: _objc_autoreleasePoolPush();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopEntry);
    do {
 
        /// 2. 通知 Observers: 即将触发 Timer 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeTimers);
        /// 3. 通知 Observers: 即将触发 Source (非基于port的,Source0) 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeSources);
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);
 
        /// 4. 触发 Source0 (非基于port的) 回调。
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__(source0);
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_BLOCK__(block);
 
        /// 6. 通知Observers，即将进入休眠
        /// 此处有Observer释放并新建AutoreleasePool: _objc_autoreleasePoolPop(); _objc_autoreleasePoolPush();
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopBeforeWaiting);
 
        /// 7. sleep to wait msg.
        mach_msg() -> mach_msg_trap();
        
 
        /// 8. 通知Observers，线程被唤醒
        __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopAfterWaiting);
 
        /// 9. 如果是被Timer唤醒的，回调Timer
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__(timer);
 
        /// 9. 如果是被dispatch唤醒的，执行所有调用 dispatch_async 等方法放入main queue 的 block
        __CFRUNLOOP_IS_SERVICING_THE_MAIN_DISPATCH_QUEUE__(dispatched_block);
 
        /// 9. 如果如果Runloop是被 Source1 (基于port的) 的事件唤醒了，处理这个事件
        __CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE1_PERFORM_FUNCTION__(source1);
 
 
    } while (...);
 
    /// 10. 通知Observers，即将退出RunLoop
    /// 此处有Observer释放AutoreleasePool: _objc_autoreleasePoolPop();
    __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__(kCFRunLoopExit);
}
```

### Source0与Source1的区别

Source有两个版本：Source0 和 Source1：

- `Source0` 只包含了一个回调（函数指针），它并不能主动触发事件。使用时，你需要先调用 `CFRunLoopSourceSignal(source)`，将这个 `Source` 标记为待处理，然后手动调用 `CFRunLoopWakeUp(runloop)` 来唤醒 `RunLoop`，让其处理这个事件。
- `Source1` 包含了一个 `mach_port` 和一个回调（函数指针），被用于通过内核和其他线程相互发送消息。这种 Source 能主动唤醒 RunLoop 的线程。

## GCD

可创建的最大线程数是 `255`

```c
thread_pool_size = DISPATCH_WORKQ_MAX_PTHREAD_COUNT     255 
```

1. 自定义串行队列是`overcommit`的，并行队列不是`overcommit`的
2. 自定义队列的目标队列在初始化时传参为`NULL`，然后会为其从`_dispatch_root_queues` 中获取一个根目标队列；当 `tq` 为 `NULL`，即入参目标队列为 `DISPATCH_TARGET_QUEUE_DEFAULT`（值是` NULL`） 时， 根据 `qos` 和 `overcommit` 从 `_dispatch_root_queues` 全局的根队列数组中获取一个根队列作为新队列的目标队列

   ```cpp
   if (!tq) {
       tq = _dispatch_get_root_queue(
               qos == DISPATCH_QOS_UNSPECIFIED ? DISPATCH_QOS_DEFAULT : qos,
               overcommit == _dispatch_queue_attr_overcommit_enabled)->_as_dq;

       if (unlikely(!tq)) {
           // 如果未取得目标队列则 crash
           DISPATCH_CLIENT_CRASH(qos, "Invalid queue attribute");
       }
   }
   ```

---

#### dispatch_sync

a. 首先将任务加入队列

b. 在当前线程执行任务`block`，没有切换线程的操作

c. 将任务移出队列

d. `sync`中对串行队列的处理最终执行的是`barrier`的内部函数: `_dispatch_barrier_sync_f_inline`

e. 会死锁的原因：执行时会检查当前队列的状态（是否正在等待），得到一个状态值，然后队列的状态值与当前所在线程的`ID`（`_dispatch_tid_self()`存在了`dispatch_sync_context_s`的`dsc_waiter`属性中）做比较，相等（线程属于队列）的话则判定为死锁。（相关处理在 `__DISPATCH_WAIT_FOR_QUEUE__` 函数中）

---

#### dispatch_async

a. 将异步任务（`dispatch_queue 、 block`）封装为 `dispatch_continuation_t` 类型

b. 然后执行 `_dispatch_continuation_async -> dx_push`递归重定向到根队列，接着执行`_dispatch_root_queue_poke`进行出队操作，通过创建线程执行`dx_invoke` 进行 `block`回调；

---

#### dispatch_barrier_async

a. 和`dispatch_async` 流程一样，只是里面有一个`while`循环，等队列中的`barrier`前面的任务执行完，才执行后面的；

b. 这里有个优化是：封装成 `dispatch_continuation_s` 结构时，会先从当前线程的`TLS`中获取一下，获取不到再从堆上创建新的

---

#### dispatch_group

a. `dispatch_group`内部维护着一个数值，初始值为`0`，`enter`时减`4`，`leave`时加`4`   https://juejin.cn/post/6902346229868019719#heading-4

b. 等待用的是`while`循环，而不是信号量

---

#### dispatch_semaphore_t

a. `dispatch_semaphore_wait` 时里面其实是起了一个`do-while` 循环，不断的去查询原子变量的值，不满足条件时会一直循环，借此阻塞流程的进行。有点像`dispatch_once`

---

#### dispatch_group_async

内部其实是对`dispatch_async` 和 `dispatch_group_enter / dispatch_group_leave` 的封装

---

#### 线程池复用原理

线程创建后从队列里取出任务执行，任务执行后使用信号量使其等待`5`秒钟，如果在这期间再有`GCD`任务过来，会先尝试唤醒线程，让它继续工作，否则等待超时后线程会自动结束，被系统销毁。（不是`tableview`中的复用池机制）

```cpp
static void *
_dispatch_worker_thread(void *context)
{
    //////////////////////////////////
    // 删减了部分代码
    //////////////////////////////////

	dispatch_queue_global_t dq = context;
	dispatch_pthread_root_queue_context_t pqc = dq->do_ctxt;

    int pending = os_atomic_dec2o(dq, dgq_pending, relaxed);

    // 线程存活5秒钟
	const int64_t timeout = 5ull * NSEC_PER_SEC;
	pthread_priority_t pp = _dispatch_get_priority();
	dispatch_priority_t pri = dq->dq_priority;

    // 从队列中取出任务执行，执行完后等待5秒钟
    // 如果5秒后没有被唤醒则进入超时逻辑，队列释放，线程退出
	do {
        // 任务执行
		_dispatch_root_queue_drain(dq, pri, DISPATCH_INVOKE_REDIRECTING_DRAIN);
		_dispatch_reset_priority_and_voucher(pp, NULL);
	} while (dispatch_semaphore_wait(&pqc->dpq_thread_mediator,
			dispatch_time(0, timeout)) == 0);

#if DISPATCH_USE_INTERNAL_WORKQUEUE
	if (monitored) _dispatch_workq_worker_unregister(dq);
#endif
	(void)os_atomic_inc2o(dq, dgq_thread_pool_size, release);
	_dispatch_root_queue_poke(dq, 1, 0);
	_dispatch_release(dq); // retained in _dispatch_root_queue_poke_slow
	return NULL;
}
```

---

#### dispatch_once

`dispatch_once`函数中的`token` (`dispatch_once_t`) 会被强转为`dispatch_once_gate_t`类型，而`dispatch_once_gate_t`里面是个`union`联合体类型，其中`dgo_once`用来记录当前`block`的执行状态，执行完后状态会被标记为`DLOCK_ONCE_DONE`。

```cpp
typedef struct dispatch_once_gate_s {
	union {
		dispatch_gate_s dgo_gate;
		uintptr_t dgo_once;
	};
} dispatch_once_gate_s, *dispatch_once_gate_t;
```

我们首先获取`dgo_once`变量的值，如果是`DLOCK_ONCE_DONE`，则表示已经执行过了，直接return掉；
如果是`DLOCK_ONCE_UNLOCKED`状态，则表示首次执行，然后会把当前的`线程id`存到`dgo_once`变量中，然后开始执行block任务，结束后会把`dgo_once`置为`DLOCK_ONCE_DONE`；
如果有其他线程执行过来，根据`dgo_once`判断，发现正在执行中，则会进入等待流程，等待其实是启了个`for (;;)`无限循环，在循环中不断地通过原子操作查询`dgo_once`的状态，等发现变为`DLOCK_ONCE_DONE`后则退出循环。


---

#### dispatch_source_merge_data

对应的结构定义

```cpp
// 定义在 libdispatch 仓库中的 init.c 文件中
DISPATCH_VTABLE_INSTANCE(source,
	.do_type        = DISPATCH_SOURCE_KEVENT_TYPE,
	.do_dispose     = _dispatch_source_dispose,
	.do_debug       = _dispatch_source_debug,
	.do_invoke      = _dispatch_source_invoke,

	.dq_activate    = _dispatch_source_activate,
	.dq_wakeup      = _dispatch_source_wakeup,
	.dq_push        = _dispatch_lane_push,
);
```

把任务包装成`dispatch_continuation_t`对象，每次`dispatch_source_merge_data`时对内部变量进行原子性的`ADD、OR、REPLACE`等操作，并执行`dx_wakeup`函数，`dx_wakeup`是个宏定义，其实调用的是`_dispatch_source_wakeup`，wakeup这个函数其实是一个入队操作，但并不是每次都会进行入队（此处还未完全看明白 o(╯□╰)o ），接着会执行`_dispatch_main_queue_drain -> _dispatch_continuation_pop_inline`出队操作，流程基本和`dispatch_async`一致。


---

## NSTimer

#### timer添加到runloop的过程：

如果是`commonMode` ，会被添加到`runloop`持有的一个`_commonModeItems` 集合中， 然后调用 `__CFRunLoopAddItemToCommonModes` 函数，把`timer`添加到`runloopMode`对象持有的`_timers`数组中 ，同时也会把`modeName`添加到`runloopTimer`的 `_rlModes` 中，记录`runloopTimer`都能在哪种`runloop mode`下执行；

如果是普通`mode`，则先获取这个`runloopMode`对象，把`runloopMode`的`name`添加到`runloopTimer`持有的 `_rlModes`集合中，然后调用 `__CFRepositionTimerInMode` 函数，把`runloopTimer`插入`runloopMode`持有的 `_timers` 数组中（如果数组中已经存在了，则先做移除操作）；

上面添加完成后，会调用 `__CFRepositionTimerInMode` 函数，然后调用 `__CFArmNextTimerInMode`，再调用 `mk_timer_arm` 函数把 `CFRunLoopModeRef` 的 `_timerPort` 和一个时间点注册到系统中，等待着 `mach_msg` 发消息唤醒休眠中的 `runloop` 起来执行到达时间的计时器。（macOS 和 iOS 下都是使用 `mk_timer` 来唤醒 `runloop`）；

每次计时器都会调用  `__CFArmNextTimerInMode` 函数注册计时器的下次执行时间（这个时间是基于本次执行的理论时间叠加得到的，而非当前的真实时间，也就是说假如本次执行滞后了，不会影响下次理论上要执行的时间点），休眠中的`runloop` 通过当前`runloop mode`的 `_timerPort` 端口唤醒，然后在本次`runloop`循环中在 `_CFRunloopDoTimers` 函数中循环调用 `__CFRunLoopDoTimer` 函数，执行达到触发时间的`timer`的 `_callout` 函数。
`__CFRUNLOOP_IS_CALLING_OUT_TO_A_TIMER_CALLBACK_FUNCTION__(rlt->_callout, rlt, context_info);` 是执行计时器的 `_callout` 函数。

#### NSTimer 不准时问题

通过上面的 `NSTimer` 执行流程可看到计时器的触发回调完全依赖 `runloop` 的运行（macOS 和 iOS 下都是使用 `mk_timer` 来唤醒 `runloop`），使用 `NSTimer` 之前必须注册到 `run loop`，但是 `run loop` 为了节省资源并不会在非常准确的时间点调用计时器，如果一个任务执行时间较长（例如本次 `run loop` 循环中 `source0` 事件执行时间过长或者计时器自身回调执行时间过长，都会导致计时器下次正常时间点的回调被延后或者延后时间过长的话则直接忽略这次回调（计时器回调执行之前会判断当前的执行状态 `!__CFRunLoopTimerIsFiring(rlt)`，如果是计时器自身回调执行时间过长导致下次回调被忽略的情况大概与此标识有关 ）），那么当错过一个时间点后只能等到下一个时间点执行，并不会延后执行（`NSTimer` 提供了一个 `tolerance` 属性用于设置宽容度，即当前时间点已经过了计时器的本次触发点，但是超过的时间长度小于 `tolerance` 的话，那么本次计时器回调还可以正常执行，不过是不准时的延后执行。 `tolerance` 的值默认是 0，最大值的话是计时器间隔时间`_interval` 的一半，可以根据自身的情况酌情设置 `tolerance` 的值。
 （`NSTimer` 不是一种实时机制，以 `main run loop` 来说它负责了所有的主线程事件，例如 `UI` 界面的操作，负责的运算使当前 `run loop` 持续的时间超过了计时器的间隔时间，那么计时器下一次回调就被延后，这样就造成` timer` 的不准时，计时器有个属性叫做 `tolerance` (宽容度)，标示了当时间点到后，容许有多少最大误差。如果延后时间过长的话会直接导致计时器直接跳过本次回调。）

## 推荐文章

- [深入浅出 GCD 之 dispatch_queue](http://cocoa-chen.github.io/2018/03/05/%E6%B7%B1%E5%85%A5%E6%B5%85%E5%87%BAGCD%E4%B9%8Bdispatch_queue/)
- [iOS刨根问底-深入理解GCD](https://www.cnblogs.com/kenshincui/p/13272517.html)
- [iOS之武功秘籍⑧: 类和分类加载过程](https://juejin.cn/post/6936978891126865928#heading-40)
- [iOS 从源码解析Run Loop (八)：Run Loop 与 AutoreleasePool、NSTimer、PerformSelector 系列](https://juejin.cn/post/6911946403036004366#heading-10)