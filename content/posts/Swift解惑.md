---
weight: 9
title: "Swift解惑"
date: 2022-07-26T16:23:10+08:00
lastmod: 2024-01-14T01:10:00+08:00
draft: false
author: "Zero.D.Saber"
authorLink: "https://github.com/faimin"
description: "记录Swift语言中的一些疑惑"
tags: ["iOS", "swift"]
categories: ["实现原理"]

images: []
featuredImage: "/images/opensource/swift/naruto.jpg"
featuredImagePreview: "/images/opensource/swift/naruto.jpg"
---

<!--more-->

## Swift分析利器

> swiftc xxx.swift -emit-sil[gen] | xcrun swift-demangle > xxxxSILGen.sil


## 备忘录

- **全局的常量或者变量都是延迟计算的**，跟延迟加载存储属性相似，不同的地方在于，全局的常量或变量不需要标记`lazy`修饰符。**局部范围的常量和变量不延迟计算**；

- 枚举类型不支持存储属性，想存储数据可以使用枚举关联的方式；

- 为类定义**计算型类型属性**时，可以改用关键字`class`来支持子类对父类的实现进行重写；

- 如果一个被标记为`lazy`的属性在没有初始化时就被多个线程访问，则无法保证该属性只会被初始化一次，也就是说`lazy`不是线程安全的；

- 我们可以为除了延迟计算属性之外的其他存储属性添加属性观察器，也可以通过重写属性的方式为继承的属性（包括存储属性和计算属性）添加属性观察器；不需要为非重写的计算属性添加属性观察器，因为可以通过它的`setter`直接监控和响应值的变化；如果在一个属性的`didSet`观察器里为它赋值，这个值会替换该观察器之前设置的值；

- 父类的属性在子类的构造器中被赋值时，它在父类中的`willSet`和`didSet`观察器会被调用，随后才会调用子类的观察器。在父类初始化方法调用之前，子类给属性赋值时，观察器不会被调用。

- 存储型类型属性可以是变量或常量，计算型类型属性跟实例的计算型属性一样只能定义成变量属性。跟实例的存储型属性不同，**必须给存储型类型属性指定默认值**，因为类型本身没有构造器，也就无法在初始化过程中使用构造器给类型属性赋值。**存储型类型属性是延迟初始化的，它们只有在第一次被访问的时候才会被初始化，即使它们被多个线程同时访问，系统也保证只会对其进行一次初始化，并且不需要对其使用`lazy`修饰符**。

- 如果将属性通过`in-out`方式传入函数，`willSet` 和 `didSet` 也会调用，这是因为 `in-out`参数采用了拷入拷出模式：**即在函数内部使用的是参数的`copy`，函数结束后，又对参数重新赋值**；


## 值类型线程安全？

不要人云亦云，这个说法是有问题的，思考一下：假如我们有个变量 `var i = 1`，多线程修改时不需要加锁？

在未优化状态下值类型其实默认是在堆上分配的，只是在`SIL`优化阶段，编译器会根据上下文把大部分值类型改为在栈上分配，在栈上分配的情况是才是线程安全的，因为每个线程都有自己的栈空间，不需要考虑线程安全问题。但是对于被捕获的这种情况是没办法优化的，你想想如果放到栈上在出作用域后不就被释放了嘛，所以这种情况不会优化到栈上，而是继续留在堆上，也就是说这种场景下多线程操作值类型是不安全的，需要加锁来防止数据竞争。

那值类型的安全性体现在哪里呢？

1. 显式捕获：这种情况会发生值类型的拷贝操作，即生成一份新的变量，所以是安全的

2. 函数传参时值类型会发生拷贝，所以是安全的

3. `let` 标记的变量是不允许修改的，所以这种也是安全的

## 闭包（closure）

![闭包定义](/images/opensource/swift/closure-define.png "closure-define") 

> 闭包和函数都是**引用类型**
>
> 函数也是特殊的闭包

`Objective-C`中的`block`默认会捕获外界变量，我们要想修改捕获的值需要添加`__block`。 可是在`Swift`中不太一样，`Swift`中的闭包是捕获和存储其所在上下文中任意常量和变量的**引用** **引用** **引用**，注意是**引用**，如果想要捕获值类型变量的值，需要在闭包中显式引用。

我们来简单分析下，`Swift`捕获外界上下文变量时会在堆上开辟一块内存`project_box` （仔细想想，如果是在栈上，出作用域就会释放掉，还怎么实现捕获的目的？！），然后上下文变量会被包装成`project_box`(先被`HeapObject`包装一下，`HeapObject`再被`Box`包装一下，最后捕获的是`Box`，即**捕获的上下文存储在堆空间**)，这个`project_box`会被放到闭包的参数列表后面传递进来。变量属于是被间接捕获的，有点类似于`OC`中的`__block`原理。当然，并不是所有的外界变量捕获都是经过包装过的，只有在闭包内发生修改的变量才会被包装，官方文档中有提到。

> 注意：
> 为了优化，如果一个值不会被闭包改变，或者在闭包创建后不会改变，Swift 可能会改为捕获并保存一份对值的拷贝。

```swift
 struct HeapObject {
    var Kind: UInt64
    var refcount: UInt64
 }
 
 // 负责包装的结构体,也就是用来包装捕获需要更新的值
 struct Box {
    var refCounted: HeapObject
    // 这个捕获的值的类型根据捕获的值进行分配，此处规范操作是写泛型
    // var value: Int
    var value: <T>
}
 ```

而显式捕获，比如捕获全局变量的场景，经过编译后可以发现，其实是把被捕获的变量作为闭包函数的参数放到了原有闭包函数的后面，而值类型的函数参数在传参过程中会发生拷贝操作。


## Lazy

这里的`lazy`指的是高阶函数前面的`lazy`，而非属性声明中的`lazy`。

使用`lazy`后再执行高阶函数，返回的其实是一个`lazy`对象，比如对一个数组进行`XX`操作，返回的是 `LazyXXSequence` 类型，这个类型中会保存原函数的操作行为和原始数据，只有在对这个`lazy`类型进行操作时才会真正进行函数操作。

![Lazy](/images/opensource/swift/Swift_Lazy.png "swift_lazy")


## Weak机制

`Swift`中`weak`与`Objective-C`中的`weak`实现机制不太一样，`Objective-C`中是不允许在一个对象释放过程中再被弱引用的，而`Swift`却没有这个限制。

`Swift`中的弱引用并没有和`Objective-C`一样放在全局的`side table`表中（Swift也不存在这个全局`side table`），而是由自身结构中的 `InlineRefCounts refCounts`来管理，这样效能会比`Objective-C`那种查表的方式高一些。

`Swift`[对象基本结构](https://github.com/apple/swift/blob/main/stdlib/public/SwiftShims/swift/shims/HeapObject.h)如下：

```cpp
// The members of the HeapObject header that are not shared by a
// standard Objective-C instance
#define SWIFT_HEAPOBJECT_NON_OBJC_MEMBERS       \
  InlineRefCounts refCounts

/// The Swift heap-object header.
/// This must match RefCountedStructTy in IRGen.
struct HeapObject {
  /// This is always a valid pointer to a metadata object.
  HeapMetadata const *__ptrauth_objc_isa_pointer metadata;

  SWIFT_HEAPOBJECT_NON_OBJC_MEMBERS;

#ifndef __swift__
  HeapObject() = default;

  // Initialize a HeapObject header as appropriate for a newly-allocated object.
  constexpr HeapObject(HeapMetadata const *newMetadata) 
    : metadata(newMetadata)
    , refCounts(InlineRefCounts::Initialized)
  { }
  
  // Initialize a HeapObject header for an immortal object
  constexpr HeapObject(HeapMetadata const *newMetadata,
                       InlineRefCounts::Immortal_t immortal)
  : metadata(newMetadata)
  , refCounts(InlineRefCounts::Immortal)
  { }

#ifndef NDEBUG
  void dump() const SWIFT_USED;
#endif

#endif // __swift__
};
```

`Swift` 引用计数的存储结构在[RefCount 头文件](https://github.com/apple/swift/blob/main/stdlib/public/SwiftShims/swift/shims/RefCount.h) 有介绍：

```swift
  //Objects initially start with no side table. They can gain a side table when:
  //* a weak reference is formed and pending future implementation:
  //* strong RC or unowned RC overflows (inline RCs will be small on 32-bit)
  //* associated object storage is needed on an object
  //* etc
  //Gaining a side table entry is a one-way operation; an object with a side 
  //table entry never loses it. This prevents some thread races.

  //Strong and unowned variables point at the object.
  //Weak variables point at the object's side table.


  //Storage layout:

  HeapObject {
    isa
    InlineRefCounts {
      atomic<InlineRefCountBits> {
        strong RC + unowned RC + flags
        OR
        HeapObjectSideTableEntry*
      }
    }
  }

  HeapObjectSideTableEntry {
    SideTableRefCounts {
      object pointer
      atomic<SideTableRefCountBits> {
        strong RC + unowned RC + weak RC + flags
      }
    }   
  }
```

一般情况下`Swift`引用类型的对象结构中的`InlineRefCounts`并不会开辟`HeapObjectSideTableEntry`内存，只有在创建`weak`引用时，会先把对象的引用计数放到新创建的`HeapObjectSideTableEntry`中去，再把空出来的空间存放 `HeapObjectSideTableEntry` 的地址，而 `runtime` 会通过一个标志位来区分对象是否有 `HeapObjectSideTableEntry`。

对象的生命周期在 [RefCount 头文件](https://github.com/apple/swift/blob/main/stdlib/public/SwiftShims/swift/shims/RefCount.h) 中也有详细的说明：

```swift
  Object lifecycle state machine:

  LIVE without side table
  The object is alive.
  Object's refcounts are initialized as 1 strong, 1 unowned, 1 weak.
  No side table. No weak RC storage.
  Strong variable operations work normally. 
  Unowned variable operations work normally.
  Weak variable load can't happen.
  Weak variable store adds the side table, becoming LIVE with side table.
  When the strong RC reaches zero deinit() is called and the object 
    becomes DEINITING.

  LIVE with side table
  Weak variable operations work normally.
  Everything else is the same as LIVE.

  DEINITING without side table
  deinit() is in progress on the object.
  Strong variable operations have no effect.
  Unowned variable load halts in swift_abortRetainUnowned().
  Unowned variable store works normally.
  Weak variable load can't happen.
  Weak variable store stores nil.
  When deinit() completes, the generated code calls swift_deallocObject. 
    swift_deallocObject calls canBeFreedNow() checking for the fast path 
    of no weak or unowned references. 
    If canBeFreedNow() the object is freed and it becomes DEAD. 
    Otherwise, it decrements the unowned RC and the object becomes DEINITED.

  DEINITING with side table
  Weak variable load returns nil. 
  Weak variable store stores nil.
  canBeFreedNow() is always false, so it never transitions directly to DEAD.
  Everything else is the same as DEINITING.

  DEINITED without side table
  deinit() has completed but there are unowned references outstanding.
  Strong variable operations can't happen.
  Unowned variable store can't happen.
  Unowned variable load halts in swift_abortRetainUnowned().
  Weak variable operations can't happen.
  When the unowned RC reaches zero, the object is freed and it becomes DEAD.

  DEINITED with side table
  Weak variable load returns nil.
  Weak variable store can't happen.
  When the unowned RC reaches zero, the object is freed, the weak RC is 
    decremented, and the object becomes FREED.
  Everything else is the same as DEINITED.

  FREED without side table
  This state never happens.

  FREED with side table
  The object is freed but there are weak refs to the side table outstanding.
  Strong variable operations can't happen.
  Unowned variable operations can't happen.
  Weak variable load returns nil.
  Weak variable store can't happen.
  When the weak RC reaches zero, the side table entry is freed and 
    the object becomes DEAD.

  DEAD
  The object and its side table are gone.
```

简单翻译过来就是：

1. **LIVE**阶段：

    在给对象添加`weak`引用时，创建`side table`，把弱引用计数放到其中，强引用计数和无主引用计数也会挪到这里，在强引用计数变为`0`时调用`deinit()`析构函数，然后这个对象被标记为**DEINITING**；

2. **DEINITING**阶段（对象正在析构）：

    a. 没有弱引用：

        i. 再强引用此对象不会发生任何效果，即什么都不做(OC中也是如此)；
        ii. 通过无主引用加载此对象会发生`abort`；
        iii. 可以正常新增对此对象的无主引用;
        iv. 新增weak引用会指向nil

    在`deinit()`析构函数执行结束会调用`swift_deallocObject`函数，内部会执行`canBeFreedNow()`进行检查，如果没有无主引用和弱引用，则这个对象会被立即释放并且变为`DEAD`状态，否则，无主引用计数`-1`，变为**DEINITED**状态。

    b. 存在弱引用：

        i. 通过`weak`获取对象或者新增`weak`指向对象都不会有问题，它们都会指向`nil`；

    这种情况`canBeFreedNow()`必定返回`false`，然后无主引用计数`-1`，变为**DEINITED**状态。        
    
2. **DEINITED**阶段（对象析构完成，强引用计数变为0，但是存在无主引用）：

    a. 没有弱引用：

        i. 通过无主引用加载此对象会发生`abort`；

    当无主引用计数变为`0`的时候会真正释放此对象的内存，然后变为**DEAD**状态。

    b. 存在弱引用：

        i. 通过`weak`获取对象得到`nil`；

    当无主引用计数变为`0`的时候会真正释放此对象的内存，弱引用计数`-1`，对象变为**FREED**状态。 

3. **FREED**阶段（对象已释放，但是存在弱引用，即`side table`）：

    a. 当弱引用计数变为`0`，则释放`side table entry`，然后对象变为**DEAD**。

3. **DEAD**阶段：

    对象和它的`side table`都被释放了。


## struct

#### 嵌套类型会影响父级结构的内存占用吗？

不会。最简单的验证方法就是通过`MemoryLayout<Type>.size`打印一下父级结构所占内存大小就清楚了。也就是说嵌套只是起到了命名空间的作用，并不会影响其他东西

#### `Array`存`Any`类型的元素是怎么内存对齐的？

元素会被包装成`existential`类型，初步猜测应该和数组中存放遵守相同协议的元素的处理方式类似。

下面截取函数原型为`arr.append(1); arr.append((100, 200)); arr.append(XX());`的部分`SIL`代码，注意里面的`init_existential_addr`字眼：

```c
store %6 to %3 : $*Array<Any>                   // id: %7
%8 = alloc_stack $Any                           // users: %17, %15, %11
%9 = integer_literal $Builtin.Int64, 1          // user: %10
%10 = struct $Int (%9 : $Builtin.Int64)         // user: %12
%11 = init_existential_addr %8 : $*Any, $Int    // user: %12
store %10 to %11 : $*Int                        // id: %12
%13 = begin_access [modify] [dynamic] %3 : $*Array<Any> // users: %16, %15
// function_ref Array.append(_:)
%14 = function_ref @Swift.Array.append(__owned A) -> () : $@convention(method) <τ_0_0> (@in τ_0_0, @inout Array<τ_0_0>) -> () // user: %15
%15 = apply %14<Any>(%8, %13) : $@convention(method) <τ_0_0> (@in τ_0_0, @inout Array<τ_0_0>) -> ()
end_access %13 : $*Array<Any>                   // id: %16
dealloc_stack %8 : $*Any                        // id: %17
%18 = alloc_stack $Any                          // users: %32, %30, %19
%19 = init_existential_addr %18 : $*Any, $(Int, Int) // users: %21, %20
%20 = tuple_element_addr %19 : $*(Int, Int), 0  // user: %24
%21 = tuple_element_addr %19 : $*(Int, Int), 1  // user: %27
%22 = integer_literal $Builtin.Int64, 100       // user: %23
%23 = struct $Int (%22 : $Builtin.Int64)        // user: %24
store %23 to %20 : $*Int                        // id: %24
%25 = integer_literal $Builtin.Int64, 200       // user: %26
%26 = struct $Int (%25 : $Builtin.Int64)        // user: %27
store %26 to %21 : $*Int                        // id: %27
%28 = begin_access [modify] [dynamic] %3 : $*Array<Any> // users: %31, %30
// function_ref Array.append(_:)
%29 = function_ref @Swift.Array.append(__owned A) -> () : $@convention(method) <τ_0_0> (@in τ_0_0, @inout Array<τ_0_0>) -> () // user: %30
%30 = apply %29<Any>(%18, %28) : $@convention(method) <τ_0_0> (@in τ_0_0, @inout Array<τ_0_0>) -> ()
end_access %28 : $*Array<Any>                   // id: %31
dealloc_stack %18 : $*Any                       // id: %32
%33 = alloc_stack $Any                          // users: %43, %41, %37
%34 = metatype $@thick XX.Type                  // user: %36
// function_ref XX.__allocating_init()
%35 = function_ref @A.XX.__allocating_init() -> A.XX : $@convention(method) (@thick XX.Type) -> @owned XX // user: %36
%36 = apply %35(%34) : $@convention(method) (@thick XX.Type) -> @owned XX // user: %38
%37 = init_existential_addr %33 : $*Any, $XX    // user: %38
store %36 to %37 : $*XX                         // id: %38
%39 = begin_access [modify] [dynamic] %3 : $*Array<Any> // users: %42, %41
  ```


## 枚举

### 内存占用

1. 普通的枚举（非关联类型）自身只占用`1个字节`，与`case`数量无关；
2. 带关联值的枚举，其所占内存大小为所有`case`中关联类型占用内存最大的那个(类似`union`)，再加枚举自身的大小；
3. 特殊场景：只有一个`case`的枚举，枚举本身所占用的内存大小是`0个字节`，如果带关联值，那枚举所占内存大小只包含关联值所占内存的大小，不包含枚举自身的大小；
4. 对于有关联值的`case`，它的`case`值会根据定义的顺序默认从`0`开始累加`1`；而其余所有不带关联值的`case`，它们的`case`地址相同，都等于最后一个带关联成员`case`的值`+1`（也就是说不带关联值的`case`在带关联值的`case`后面）；
5. **关联值**是直接存储在枚举变量内存里面的，而**原始值**不是，它是通过`xx.rawValue`（计算属性）访问的，因此它的原始值完全不需要存储（枚举也不支持存储属性），而是在计算属性函数的返回值中，即函数中。`rawValue`这个计算属性是编译器帮我们默认添加的，它的返回值默认是我们设置的**原始值**，假如我们自己实现了这个计算属性，编译器就不会帮我们默认添加了，而是使用我们自己的实现；
6. 嵌套枚举：被`indirect`标记的对象会被`BoxPair`包装成引用类型（放到堆上），和`Rust`一样的处理方式（`Rust`中是被包装成`Box`类型）；


## 派发方式

> 1. 静态派发
>
> 2. 函数表派发
>
> 3. 消息派发

1. 添加 `@objc` 标识，编译器会生成两份函数实现，一份是消息派发的函数供`OC`调用，另一份是函数表派发或静态派发的函数实现；消息派发那个函数内部会调用另一份实现，我觉得可以简单理解为`@objc`只是编译器帮我们暴漏了一个`OC`接口而已；
2. 多使用`final`关键字，一个类标记为`final`后，默认的函数表派发会变成静态派发，但是它不会影响`@objc`这个接口的生成；函数用`final`标记后也会变成静态派发；
3. 在`extension`中的方法是静态派发；
4. `protocol`中声明的方法属于函数表派发，即使在`extension`中添加了默认实现，当我们在调用某个对象的这个协议方法时采用的也是函数表派发；但是我们调用`protocol`的`extension`中的某个未作为协议声明的方法时，采用的是静态派发的策略；
5. `private`函数并未改变函数的派发方式（[iOS摸鱼周报#73](https://mp.weixin.qq.com/s/Om_1TOGKWkMiNneB6Ittrw) 中说`private`会隐式`final`声明，但我测试发现它并不会改变函数的派发方式，感兴趣的同学可以自己验证一下）；


## `any` VS `some`

```swift
// 1.泛型
func tFoo<T: Equatable>() -> T {
    return 42 as! T
}

// 2.some
func someFoo() -> some Equatable {
    return 42
}

// 3.any
func anyFoo() -> any Equatable {
    return 42
}
```

1. `some`是`Swift 5.1`新加的。`any`是`Swift 5.6`引入的，用来修饰`existential type`，在`Swift5.7`中这个修饰行为变为了强制；
2. `some`其实只是对泛型协议参数的一种等价简化（如上的`1`和`2`是等价的），也就是说`some`在编译期就可以确定出类型，在方法调用上可以做到函数表派发、静态派发；
3. `any`则是类似`盒子`的类型，它包装了遵循特定协议的类型。这个`box盒子`允许我们去存储任何具体类型，只要该类型遵循了特定协议即可。
   1. 性能：由于编译器无法在编译期确定盒子内对象的具体类型以及内存分配方式，导致在运行时不得不采用动态派发的方式将消息派发到具体的对象上，这肯定比静态派发方式要慢很多。
   2. 由于`existential type`使用上太简单、太方便，很容易会出现滥用的情况，为了提醒开发人员性能损失这一点，所以在`Swift 5.7`中苹果强制要求对`existential type`使用`any`来标记。
   3. 我们不能使用`==`操作来比较两个`existential type`实例对象。
   

  ![some vs any](/images/swift/some_vs_any.webp "some_vs_any")

  最后，根据下面的例子体会一下：

  ```swift
   // ✅ No compile error when changing the underlying data type
   var myCar: any Vehicle = Car()
   myCar = Bus()
   myCar = Car()
   ​
    // 🔴 Compile error in Swift 5.7: Use of protocol 'Vehicle' as a type must be written 'any Vehicle' 
   func wash(_ vehicle: Vehicle)  {
       // Wash the given vehicle
   }
   ​
   // ✅ No compile error in Swift 5.7
   func wash(_ vehicle: any Vehicle)  {
       // Wash the given vehicle
   }

   // 🔴 Compile error in Swift 5.7: Use of protocol 'Vehicle' as a type must be written 'any Vehicle'
  // 一个函数不能返回多种类型结果，而`some`在编译期就可以确定类型，所以编译失败
   func createVehicle(isPublicTransport: Bool) -> some Vehicle {
      if isPublicTransport {
        return Bus()
      } else {
        return Car()
      }
   }
   ​
   // ✅ No compile error when returning different kind of concrete type 
  func createAnyVehicle(isPublicTransport: Bool) -> any Vehicle {
      if isPublicTransport {
        return Bus()
      } else {
        return Car()
      }
  }
  ```

## @objc方法的派发方式

> 不考虑`@dynamic`关键字标记的场景（被`@dynamic`和`@objc`标记后会变为消息派发）

`Swift`方法被`@objc`标记后，编译器会生成`2份`接口：一份是`Swift`接口，供`Swift`内部调用；另一份是`OC`接口，用于给`OC`层调用。其中`Swift`的函数调用采用的是**函数表派发**（函数在`sil_vtable`中），而`OC`接口内部其实最终调用的还是`Swift`函数，也就是说派发方式并没有发生变化，还是函数表派发。

创建一个`Foo`类，并实现一个`@objc`标记的`bar`方法：

```swift
import Foundation

class Foo: NSObject {
    @objc func bar() {
        print("Hello from Swift!")
    }
}
```

通过 `swiftc Foo.swift -emit-sil | xcrun swift-demangle > FooSILGen.sil`转换为`SIL`代码如下：

> 有精简，只保留了`bar`函数和`vtable`相关部分

```MLIR
sil_stage canonical

import Builtin
import Swift
import SwiftShims

import Foundation

@objc @_inheritsConvenienceInitializers class Foo : NSObject {
  @objc func bar()
  override dynamic init()
  @objc deinit
}

// Foo.bar()
sil hidden @Foo.Foo.bar() -> () : $@convention(method) (@guaranteed Foo) -> () {
// %0 "self"                                      // user: %1
bb0(%0 : $Foo):
  debug_value %0 : $Foo, let, name "self", argno 1, implicit // id: %1
  %2 = integer_literal $Builtin.Word, 1           // user: %4
  // function_ref _allocateUninitializedArray<A>(_:)
  %3 = function_ref @Swift._allocateUninitializedArray<A>(Builtin.Word) -> ([A], Builtin.RawPointer) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // user: %4
  %4 = apply %3<Any>(%2) : $@convention(thin) <τ_0_0> (Builtin.Word) -> (@owned Array<τ_0_0>, Builtin.RawPointer) // users: %6, %5
  %5 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 0 // user: %17
  %6 = tuple_extract %4 : $(Array<Any>, Builtin.RawPointer), 1 // user: %7
  %7 = pointer_to_address %6 : $Builtin.RawPointer to [strict] $*Any // user: %14
  %8 = string_literal utf8 "Hello from Swift!"    // user: %13
  %9 = integer_literal $Builtin.Word, 17          // user: %13
  %10 = integer_literal $Builtin.Int1, -1         // user: %13
  %11 = metatype $@thin String.Type               // user: %13
  // function_ref String.init(_builtinStringLiteral:utf8CodeUnitCount:isASCII:)
  %12 = function_ref @Swift.String.init(_builtinStringLiteral: Builtin.RawPointer, utf8CodeUnitCount: Builtin.Word, isASCII: Builtin.Int1) -> Swift.String : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %13
  %13 = apply %12(%8, %9, %10, %11) : $@convention(method) (Builtin.RawPointer, Builtin.Word, Builtin.Int1, @thin String.Type) -> @owned String // user: %15
  %14 = init_existential_addr %7 : $*Any, $String // user: %15
  store %13 to %14 : $*String                     // id: %15
  // function_ref _finalizeUninitializedArray<A>(_:)
  %16 = function_ref @Swift._finalizeUninitializedArray<A>(__owned [A]) -> [A] : $@convention(thin) <τ_0_0> (@owned Array<τ_0_0>) -> @owned Array<τ_0_0> // user: %17
  %17 = apply %16<Any>(%5) : $@convention(thin) <τ_0_0> (@owned Array<τ_0_0>) -> @owned Array<τ_0_0> // users: %26, %23
  // function_ref default argument 1 of print(_:separator:terminator:)
  %18 = function_ref @default argument 1 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %19
  %19 = apply %18() : $@convention(thin) () -> @owned String // users: %25, %23
  // function_ref default argument 2 of print(_:separator:terminator:)
  %20 = function_ref @default argument 2 of Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) () -> @owned String // user: %21
  %21 = apply %20() : $@convention(thin) () -> @owned String // users: %24, %23
  // function_ref print(_:separator:terminator:)
  %22 = function_ref @Swift.print(_: Any..., separator: Swift.String, terminator: Swift.String) -> () : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> () // user: %23
  %23 = apply %22(%17, %19, %21) : $@convention(thin) (@guaranteed Array<Any>, @guaranteed String, @guaranteed String) -> ()
  release_value %21 : $String                     // id: %24
  release_value %19 : $String                     // id: %25
  release_value %17 : $Array<Any>                 // id: %26
  %27 = tuple ()                                  // user: %28
  return %27 : $()                                // id: %28
} // end sil function 'Foo.Foo.bar() -> ()'

// @objc Foo.bar()
sil private [thunk] @@objc Foo.Foo.bar() -> () : $@convention(objc_method) (Foo) -> () {
// %0                                             // users: %4, %3, %1
bb0(%0 : $Foo):
  strong_retain %0 : $Foo                         // id: %1
  // function_ref Foo.bar()
  %2 = function_ref @Foo.Foo.bar() -> () : $@convention(method) (@guaranteed Foo) -> () // user: %3
  %3 = apply %2(%0) : $@convention(method) (@guaranteed Foo) -> () // user: %5
  strong_release %0 : $Foo                        // id: %4
  return %3 : $()                                 // id: %5
} // end sil function '@objc Foo.Foo.bar() -> ()'

sil_vtable Foo {
  #Foo.bar: (Foo) -> () -> () : @Foo.Foo.bar() -> ()	// Foo.bar()
  #Foo.deinit!deallocator: @Foo.Foo.__deallocating_deinit	// Foo.__deallocating_deinit
}
```

可以看到`oc`方法内部其实调用的还是`Swift`的实现：`%2 = function_ref @Foo.Foo.bar() -> (),  %3 = apply %2(%0)`，即`@objc`关键字未影响原来的派发方式。



## 推荐文章

- [Swift Intermediate Language (SIL)](https://github.com/apple/swift/blob/main/docs/SIL.rst)

- [从 SIL 角度看 Swift 中的值类型与引用类型](https://juejin.cn/post/7030983921328193549)

- [从 SIL 看 Swift 函数派发机制](https://mp.weixin.qq.com/s/KvwFyc1X_anTt-DTw86u7Q)

- [iOS下的闭包下篇-Closure](https://mp.weixin.qq.com/s/97Ij2N545ydx6WBNAwncOA)

- [Swift 性能优化(2)——协议与泛型的实现](http://chuquan.me/2020/02/19/swift-performance-protocol-type-generic-type/)

- [Swift 泛型底层实现原理](http://chuquan.me/2020/04/20/implementing-swift-generic/)

- [【译】Understanding the “some” and “any” keywords in Swift 5.7](https://juejin.cn/post/7119062263406788616)
  - [【译】What is the “some” keyword in Swift?](https://juejin.cn/post/7117916143175598088)
  - [【译】What is the “any” keyword in Swift?](https://juejin.cn/post/7116463990724624421)
  - [【译】What’s the difference between any and some in Swift 5.7?](https://juejin.cn/post/7119062787749314590)
  - [【译】Using the ‘some’ and ‘any’ keywords to reference generic protocols in Swift 5](https://juejin.cn/post/7119393646729756685)
  - [【译】What are primary associated types in Swift 5.7?](https://juejin.cn/post/7119423026755551239)