---
title: "Block捕获原理探究"
date: 2018-08-17T12:10:41+08:00
lastmod: 2024-08-18T00:02:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: "探索block变量捕获的原理"
tags: ["iOS", "block"]
categories: ["实现原理"]

images: []
featuredImage: "/images/block/milim.jpg"
featuredImagePreview: "/images/block/milim.jpg"

lightgallery: true

---

探索`block`捕获外界变量的原理

<!--more-->


在此之前先介绍一下**block 基本语法**：

![](/images/block/BlockSyntax.png "BlockSyntax")


</br>

<details open>
<summary>Block Syntax</summary>

```objectivec
// Block as a local variable
returnType (^blockName)(parameterTypes) = ^returnType(parameters) {...};

// Block as a property
@property (nonatomic, copy) returnType (^blockName)(parameterTypes);

// Block as a method parameter
- (void)someMethodThatTakesABlock:(returnType (^)(parameterTypes))blockName;

// Block as an argument to a method call
[someObject someMethodThatTakesABlock: ^returnType (parameters) {...}];

// Block as typedef
typedef returnType (^TypeName)(parameterTypes);
TypeName blockName = ^returnType(parameters) {...};
```

</details>

对`Object-C`文件执行 `xcrun -sdk iphonesimulator clang -fobjc-arc -fobjc-runtime=ios -rewrite-objc fileName.m` 操作来获取伪代码，仅供技术探究。

先把`__block_impl`结构体拿出来放在最前面，最终`block`调用时都会被强转成这种类型，下面好多地方会用到。

```cpp
struct __block_impl {
  void *isa;        
  int Flags;
  int Reserved;
  void *FuncPtr;
};
```

> * `isa`指针：指向一个类对象，在非`GC`模式下有三种类型：_`NSConcreteStackBlock`、`_NSConcreteGlobalBlock`、`_NSConcreteMallocBlock`；
> * `Flags`：`block`的负载信息（引用计数和类型信息），按位存储；
> * `Reserved`：保留变量；
> * `FuncPtr`：指向`block`函数地址的指针。
> * `descriptor`：是用于描述当前这个 `block` 的附加信息的，包括结构体的大小，需要 `capture` 和 `dispose` 的变量列表等。结构体大小需要保存是因为，每个 `block` 因为会 `capture` 一些变量，这些变量会加到 `__main_block_impl_0` 这个结构体中，使其体积变大。

接下来进入正题：

> p.s：以下`Objective-C`的代码都处在`ARC`环境下

## 1、不加__block的情况:

```objectivec
#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {

        NSMutableArray *mutArr = [NSMutableArray array];

        void(^block)() = ^{
            [mutArr addObject:@2];
        };

        block();
    }
}
```

----

执行`clang`操作后的`C++`代码:

```cpp
// 定义block的结构体
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  NSMutableArray *mutArr;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSMutableArray *_mutArr, int flags=0) : mutArr(_mutArr) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 以下为调用`block`时执行的方法
// 此`mutArr`是在最初定义`block`时 为结构体传进去的局部变量`mutArr`的值
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  // bound by copy:这里的注释表示，block对它引用的局部变量做了只读拷贝，也就是说block引用的是局部变量的副本。
  NSMutableArray *mutArr = __cself->mutArr; // bound by copy

   ((void (*)(id, SEL, ObjectType))(void *)objc_msgSend)((id)mutArr, sel_registerName("addObject:"), (id)((NSNumber *(*)(Class, SEL, int))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithInt:"), 2));
}

// block的copy函数
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->mutArr, (void*)src->mutArr, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->mutArr, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

int main(int argc, char *argv[]) {
 /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

  NSMutableArray *mutArr = ((NSMutableArray *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSMutableArray"), sel_registerName("array"));

  // 可以看出block变量实际上就是一个指向结构体`__main_block_impl_0`的指针,而结构体的第三个元素是局部变量mutArr的值
  // 此处捕获的直接就是`mutArr`局部变量
  void(*block)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, mutArr, 570425344));

  // 下面调用`block`的方法实质其实是: 指向结构体的指针`block`访问其`FuncPtr`元素(即,在定义block时为`FuncPtr`元素传进去的`__main_block_func_0`方法)
  ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);
 }
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
```

----

## 2、添加__block的情况:

```objectivec
#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {

        __block NSMutableArray *mutArr = [NSMutableArray array];

        void(^block)() = ^{
            [mutArr addObject:@2];
        };

        [mutArr addObject:@"hello"];

        block();
    }
}
```

----

执行`clang`后的`C++`代码:

```cpp
// 由下面的代码可知: `__block`的作用就是定义一个新的结构体来包裹原来的变量
// 定义一个保存变量的结构体 （被__block标记的变量会被转化为这种格式的结构体对象）
struct __Block_byref_mutArr_0 {
  void *__isa;
  __Block_byref_mutArr_0 *__forwarding;
 int __flags;
 int __size;
 void (*__Block_byref_id_object_copy)(void*, void*);
 void (*__Block_byref_id_object_dispose)(void*);
 NSMutableArray *mutArr;
};

// block 结构体
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  // 包含捕获的局部变量的结构体指针
  __Block_byref_mutArr_0 *mutArr; // by ref
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, __Block_byref_mutArr_0 *_mutArr, int flags=0) : mutArr(_mutArr->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 在block内部对`mutArr`操作 (block回调时执行的函数)
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
   // 拿到 包含捕获的局部变量 的结构体指针
   __Block_byref_mutArr_0 *mutArr = __cself->mutArr; // bound by ref
   // 通过上面的结构体指针一步步拿到`mutArr`数组
   ((void (*)(id, SEL, ObjectType))(void *)objc_msgSend)((id)(mutArr->__forwarding->mutArr), sel_registerName("addObject:"), (id)((NSNumber *(*)(Class, SEL, int))(void *)objc_msgSend)(objc_getClass("NSNumber"), sel_registerName("numberWithInt:"), 2));
}

static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
    _Block_object_assign((void*)&dst->mutArr, (void*)src->mutArr, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
    _Block_object_dispose((void*)src->mutArr, 8/*BLOCK_FIELD_IS_BYREF*/);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

// main函数
int main(int argc, char *argv[]) {
 /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

  // 这里可以看到结构体中的 __forwarding 指针其实指向的就是其自身
  __attribute__((__blocks__(byref))) __Block_byref_mutArr_0 mutArr = {(void*)0,(__Block_byref_mutArr_0 *)&mutArr, 33554432, sizeof(__Block_byref_mutArr_0), __Block_byref_id_object_copy_131, __Block_byref_id_object_dispose_131, ((NSMutableArray *(*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSMutableArray"), sel_registerName("array"))};

  // 与不加__block差不多,`block`变量还是一个指向`__main_block_impl_0`结构体的指针,区别在于第三个参数变了. 第三个参数是包含局部变量`mutArr`的结构体指针.
  // 即block捕获的是持有`mutArr`的结构体指针
  void(*block)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, (__Block_byref_mutArr_0 *)&mutArr, 570425344));

  // 在block外部对`mutArr`操作
  //
  // 此处对`mutArr`数组对象进行操作,获取`mutArr`也是和`block`内部的获取方法一样,
  // 都是通过持有`mutArr`的结构体一步步获取到`mutArr`数组,
  //
  // 这里要经过 __forwarding 来获取`mutArr`的原因是：
  // __block 标记的变量有可能被copy到堆上，__forwarding 的作用就是在变量被copy到堆上时修改指向，使栈和堆上的 __forwarding 都指向堆上的那个副本，这样就保证了block内外操作的都是同一份内存。
  // 具体的copy实现可以参见下面的 `_Block_byref_copy` 函数。
  // 
  // 举个例子：block外有个`__block int x = 2;`，当block被copy到堆上后这个warp变量也会生成一个新的对象地址，block内部使用的是新的对象，block外面用的还是原来栈上的那个，但我们期望的是不管内外，一方改变后另一方也要改变，所以需要指向同一份内存，这时候就是`__forwarding`的用武之地了。
  // 
  // 所以,在block内外,操作的都是同一个`mutArr`对象.都是通过包含`mutArr`对象的`__Block_byref_mutArr_0`结构体对其进行间接操作处理的
  // 这也就是为什么添加`__block`后还能改变原来的对象的原因
  //
  // PS: 在我们用__block 标记一个变量以后，当我们用到这个变量时都不是直接使用这个变量了，而是变成了通过`__Block_byref`来操作这个变量
  ((void (*)(id, SEL, ObjectType))(void *)objc_msgSend)((id)(mutArr.__forwarding->mutArr), sel_registerName("addObject:"), (id)(NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_b07809_mi_0);

  ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);

 }
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };

// __block 变量被copy到堆上时的具体实现
static struct Block_byref *_Block_byref_copy(const void *arg) {
    struct Block_byref *src = (struct Block_byref *)arg;

    if ((src->forwarding->flags & BLOCK_REFCOUNT_MASK) == 0) {
        // src points to stack
        struct Block_byref *copy = (struct Block_byref *)malloc(src->size);
        copy->isa = NULL;
        // byref value 4 is logical refcount of 2: one for caller, one for stack
        copy->flags = src->flags | BLOCK_BYREF_NEEDS_FREE | 4;
        // 堆上的forwarding指向其自身
        copy->forwarding = copy; // patch heap copy to point to itself
        // 栈上的forwarding指向copy到堆上的副本
        src->forwarding = copy;  // patch stack to point to heap copy
        copy->size = src->size;

        if (src->flags & BLOCK_BYREF_HAS_COPY_DISPOSE) {
            // Trust copy helper to copy everything of interest
            // If more than one field shows up in a byref block this is wrong XXX
            struct Block_byref_2 *src2 = (struct Block_byref_2 *)(src+1);
            struct Block_byref_2 *copy2 = (struct Block_byref_2 *)(copy+1);
            copy2->byref_keep = src2->byref_keep;
            copy2->byref_destroy = src2->byref_destroy;

            if (src->flags & BLOCK_BYREF_LAYOUT_EXTENDED) {
                struct Block_byref_3 *src3 = (struct Block_byref_3 *)(src2+1);
                struct Block_byref_3 *copy3 = (struct Block_byref_3*)(copy2+1);
                copy3->layout = src3->layout;
            }

            (*src2->byref_keep)(copy, src);
        }
        else {
            // Bitwise copy.
            // This copy includes Block_byref_3, if any.
            memmove(copy+1, src+1, src->size - sizeof(*src));
        }
    }
    // already copied to heap
    else if ((src->forwarding->flags & BLOCK_BYREF_NEEDS_FREE) == BLOCK_BYREF_NEEDS_FREE) {
        latching_incr_int(&src->forwarding->flags);
    }

    return src->forwarding;
}
```

![](/images/block/BlockForwarding.png "block __forwarding")

虽然`NSMutableArray`前面加不加`__block`，都不会影响往数组中添加数据，但是当在`block`中给`mutArr`重新赋值的时候就有区别了。

![](/images/block/blockTest1.png "blockTest")

如果你想对`mutArr`变量重新赋一个新的`array`实例，改变原变量的指针，那么不加`_block`是不行的，因为`block`捕获的是对象的地址，重新赋值，指针的指向就变了。但是如果只是单纯的`add`一个数据进去实际上改变的是变量所指的那个`mutArr`内存区域，指针指向并没有发生变化，还是原来那个对象，这样是没有区别的。

## 3、静态变量:

```objectivec
#import <Foundation/Foundation.h>

int main(int argc, char *argv[]) {
    @autoreleasepool {

        static NSString *myString = @"111";

        void(^block)() = ^{
            [myString stringByAppendingString:@"222"];

            myString = @"444";

            NSLog(@"%@", myString);
        };

        [myString stringByAppendingString:@"333"];

        block();

    }
}
```

----

`clang`之后的`C++`代码：

```cpp
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  // 注意这里, 外面的静态变量被捕获了,不过捕获的是对象的指针
  NSString **myString;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, NSString **_myString, int flags=0) : myString(_myString) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  NSString **myString = __cself->myString; // bound by copy

    // 通过对`myString`指针进行取值操作(*myString),拿到 myString
   ((NSString *(*)(id, SEL, NSString *))(void *)objc_msgSend)((id)(*myString), sel_registerName("stringByAppendingString:"), (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_dac7fc_mi_1);

// 由下面的伪代码可以看出,由于`myString`是指针,所以通过`*`操作来获取到原来的变量,
// 然后再对其进行重新赋值操作
(*myString) = (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_121621_mi_2;

   NSLog((NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_dac7fc_mi_2, (*myString));

}

static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
  _Block_object_assign((void*)&dst->myString, (void*)src->myString, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {
  _Block_object_dispose((void*)src->myString, 3/*BLOCK_FIELD_IS_OBJECT*/);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};


int main(int argc, char *argv[]) {
 /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

  static NSString *myString = (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_dac7fc_mi_0;

    // block捕获的是静态变量的指针
  void(*block)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA, &myString, 570425344));

  ((NSString *(*)(id, SEL, NSString *))(void *)objc_msgSend)((id)myString, sel_registerName("stringByAppendingString:"), (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_dac7fc_mi_3);

  ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);

 }
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
```

## 4、全局变量:

```objectivec
#import <Foundation/Foundation.h>

NSString *myString = @"111";

int main(int argc, char *argv[]) {
    @autoreleasepool {

        void(^block)() = ^{
            [myString stringByAppendingString:@"222"];

            myString = @"444";

            NSLog(@"%@", myString);
        };

        [myString stringByAppendingString:@"333"];

        block();
    }
}
```

---

`clang`操作执行之后的`C++`伪代码:

```cpp
NSString *myString = (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_938f32_mi_0;

// block结构体并没有捕获全局变量
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {

    // 下面三个函数都是在用到全局变量`myString`的时候直接从内存去获取
   ((NSString *(*)(id, SEL, NSString *))(void *)objc_msgSend)((id)myString, sel_registerName("stringByAppendingString:"), (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_938f32_mi_1);

   myString = (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_938f32_mi_2;

   NSLog((NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_938f32_mi_3, myString);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};

// main函数
int main(int argc, char *argv[]) {
 /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

  void(*block)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

  ((NSString *(*)(id, SEL, NSString *))(void *)objc_msgSend)((id)myString, sel_registerName("stringByAppendingString:"), (NSString *)&__NSConstantStringImpl__var_folders_4t_ldgq93v932g220vwkl7c1fk40000gn_T_BlockTest_938f32_mi_4);

  ((void (*)(__block_impl *))((__block_impl *)block)->FuncPtr)((__block_impl *)block);

 }
}
static struct IMAGE_INFO { unsigned version; unsigned flag; } _OBJC_IMAGE_INFO = { 0, 2 };
```

## 总结:

#### 局部变量：

  - 不加`__block`: `block`内部捕获的是局部变量的值，而且如果局部变量是数值类型（比如`int`）不会有`__main_block_copy_0` 和 `__main_block_dispose_0` 两个函数，如果是引用类型（比如`NSArray`）则会有这个函数，说明对于值类型变量是直接定义新变量并赋值相同，对于引用类型变量是定义一个新变量并`copy`这个对象的指针。

  - 添加`__block`: 原来的局部变量会被放入到一个`__Block_byref_变量名_0`类型的结构体中，然后`block`内部当捕获局部变量时其实是捕获的是这个结构体的指针，当获取原来的局部变量时(不管是在`block`内还是`block`外)，其实都是通过这个结构体或者这个结构体指针来拿到原来的局部变量再进行操作的。这也就是为什么添加`__block`后可以对`block`内捕获的局部变量进行重新赋值等操作。

#### 静态变量：

`block`直接捕获的是静态变量的指针，前后都是对指针进行操作。

#### 全局变量（或 全局静态变量）：

`block`并没有捕获变量，而是在结构体的执行方法中直接使用了全局变量，是在执行时才去取值，一直都是获取变量的最新值。而且细心点我们可以发现，对于没有捕获全局变量的`block`中也没有`__main_block_copy_0` 和 `__main_block_dispose_0` 两个函数（用于在调用前后修改相应变量的引用计数），即没有发生`copy`操作。

#### 其他

`ARC`环境下：在单独声明`block`的时候，`block`还是会在栈上的；当`block`作为参数返回的时候，`block`也会自动被移到堆上；在`ARC`下，只要指针过一下`strong`指针，或者由函数返回都会把`block`移动到堆上。
   
> `__main_block_copy_0` 中的 `_Block_object_assign` 函数相当于`retain`实例方法，使 block 的成员变量持有捕获到的对象。 `__main_block_dispose_0` 中的 `_Block_object_dispose` 函数相当于 `release` 实例方法，释放 `block `的成员变量持有的对象。

`Objective-C` 中的3种`block`： `__NSStackBlock__`、`__NSMallocBlock`、`__NSGloballBlock` 会在下面的情况下出现：

| 条件         |ARC                                            |MRC               |
|:------------:|:--------------------------------------------:|:-----------------:|
|捕获外部变量     |`__NSStackBlock__` <br> `__NSMallocBlock__`   |`__NSStackBlock__` |
|未捕获外部变量   |`__NSGlobalBlock__`                           |`__NSGlobalBlock__`|

* 在 `ARC` 中，捕获了外部非静态变量的`block`的类型会是`__NSStackBlock__` 或者 `__NSMallocBlock__`，如果 `block` 被赋值给了某个变量，在这个过程中会执行`_Block_copy`，将原有的 `__NSStackBlock__` 变成 `__NSMallocBlock__`；但是如果 `block` 没有被赋值给某个变量，那它的类型就是`__NSStackBlock__`；捕获静态变量、全局变量或者没有捕获外部变量的 `block` 类型则是 `__NSGlobalBlock__` ，既不在栈上，也不在堆上，它类似于 `C` 语言函数一样，会在代码段中。
* 在`MRC`中，捕获了外部变量的 `block` 的类会是`__NSStackBlock__`，放置在栈上；没有捕获外部变量的 `block` 与 `ARC` 环境下的情况是相同的，类型是`__NSGlobalBlock__`，放置在代码段中。

捕获外部变量，类型还是栈上block的例子如下：
```cpp
#import <Foundation/Foundation.h>
#import <stdio.h>

int x = 1;

int main (int argc, const char * argv[])
{
  @autoreleasepool {
    int i = 1024;
    void (^block1)(void) = ^{
        printf("%d\n", i);
    };
    
    static int j = 1025;
    void(^block2)(void) = ^{
      printf("%d", j);
    };

    void(^block3)(void) = ^{
      printf("%d", x);
    };

    // output: _NSConcreteMallocBlock, _NSConcreteGlobalBlock, _NSConcreteGlobalBlock, _NSConcreteStackBlock
    NSLog(@"%@, %@, %@, %@", [block1 class], [block2 class], [block3 class], [^{
        NSLog(@"%d", i);
    } class]);
    
  }
}
```

------

## 推荐文章：

> 比我写的好

- [Block本质](https://github.com/pro648/tips/blob/master/sources/Block%E7%9A%84%E6%9C%AC%E8%B4%A8.md)

## 参考文章:

1. [深入研究 Block 捕获外部变量和 __block 实现原理](https://halfrost.com/ios_block/)
2. [谈Objective-C Block的实现](http://blog.devtang.com/2013/07/28/a-look-inside-blocks/)
3. [iOS中的block是如何持有对象的](http://draveness.me/block-retain-object)
4. [深入分析Objective-C block、weakself、strongself实现原理](http://www.jianshu.com/p/a5dd014edb13)
5. [block-copy](http://www.galloway.me.uk/2013/05/a-look-inside-blocks-episode-3-block-copy/)

