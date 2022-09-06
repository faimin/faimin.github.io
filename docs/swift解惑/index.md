# Swift解惑


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


## 推荐文章

- [从 SIL 角度看 Swift 中的值类型与引用类型](https://juejin.cn/post/7030983921328193549)

- [从 SIL 看 Swift 函数派发机制](https://mp.weixin.qq.com/s/KvwFyc1X_anTt-DTw86u7Q)

- [iOS下的闭包下篇-Closure](https://mp.weixin.qq.com/s/97Ij2N545ydx6WBNAwncOA)

- [Swift 性能优化(2)——协议与泛型的实现](http://chuquan.me/2020/02/19/swift-performance-protocol-type-generic-type/)

- [Swift 泛型底层实现原理](http://chuquan.me/2020/04/20/implementing-swift-generic/)
