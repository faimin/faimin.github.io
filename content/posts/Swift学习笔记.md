---
title: "Swift学习笔记"
date: 2016-03-01T20:55:20+08:00
lastmod: 2020-11-18T20:55:20+08:00
draft: false
authorLink: "https://github.com/faimin"
description: ""
tags: ["iOS", "swift"]
categories: ["学习笔记"]

images: []
featuredImage: "/images/opensource/swift/dog.jpg"
featuredImagePreview: "/images/opensource/swift/dog.jpg"
---


## 函数

- 结构体和枚举是值类型，默认情况下，值类型的属性不能在它的实例方法中被修改，但是**如果你确实需要在某个具体的方法中修改结构体或者枚举的属性，可以在方法`func`前添加`mutating`关键字**，然后就可以修改它的属性了，并且它做的任何改变在方法结束时还会保留在原始结构体中。

- 方法与函数的区别：方法是与某些特定类型相关联的函数，即方法就是函数，只是这个函数与某个类型相关联罢了。

## 闭包

闭包表达式语法：

```swift
{ (parameters) -> returnType  in
    statements  //函数体
}
```

> 闭包表达式参数可以是 `in-out` 参数，但是不能设置默认值；也可以使用具名的可变参数（译者注：可变参数需要放在参数列表最后，因为如果可变参数不放在参数列表的最后一位的话，调用闭包的时候编译器将报错）；元组也可以作为参数返回。

- **类型推断：因为所有的类型都可以被正确推断，此时，闭包中的返回箭头（->）和围绕在参数周围的括号可以被省略:**

    ```swift
    reversedName = names.sorted(by: { s1, s2 in 
        return s1 > s2 
    })
    ```

- **单表达式闭包隐式返回(闭包隐式返回单行表达式)：单行表达式可以通过省略`return`关键字来隐式返回当行表达式的结果**，如`sort`函数的例子可以改写为:

    ```swift
    reversedName = names.sorted(by: { s1, s2 in s1 > s2 })
    ```

- **参数名称缩写：如果你在闭包表达式中使用参数名称缩写，那么你可以在闭包定义中省略参数列表，并且对应参数名称缩写的类型会通过参数类型自行进行推断出来。`in`关键字也同样可以被省略，因为此时闭包表达式完全由闭包函数体构成：**

    ```swift
    reversedName = names.sorted(by: { $0 > $1 })
    ```

- 运算符方法：Swift的`String`类型定义了关于大于号`>`的字符串实现，其作为一个函数接受两个`String`类型的参数并返回`Bool`类型的值：

    ```swift
    reversedName = names.sorted(by: > )
    ```

- **尾随闭包**：如果你需要将一个很长的闭包表达式作为最后一个参数传递给函数时，可以使用 *尾随闭包* 来增强函数可读性。 **尾随闭包是一个书写在函数括号之后的闭包表达式，函数支持将其作为最后一个参数调用，在使用尾随闭包时，你不用写出他的参数标签**：

    ```swift
    func someFunctionThatTakesAClosure(closure: () -> Void) {
         // 函数体部分
    }
    // 以下是没有用尾随闭包进行函数调用 
    someFunctionThatTakesAClosure(closure: {
         // 闭包主体部分
    })
    // 以下是使用尾随闭包进行函数调用，省略掉了参数标签 `closure`
    someFunctionThatTakesAClosure() {
        // 闭包主体部分 
    }
    ```

    所以`sorted(by:)`方法的参数字符串排序闭包可以改写为：

    ```swift
    reversedName = names.sorted() { $0 > $1 }
    ```

    **如果闭包表达式是函数或者方法的唯一参数，则当你使用尾随闭包时，甚至可以把`()`省略掉：**

    ```swift
    // 去掉小括号
    reversedName = names.sorted { $0 > $1 }
    ```

- 当一个闭包作为参数传到一个函数中，但是这个闭包在函数返回之后才被执行，我们称该闭包从函数中逃逸。当 你定义接受闭包作为参数的函数时，你可以在参数名之前标注`@escaping`，用来指明这个闭包是允许“逃逸”出 这个函数的。`将一个闭包标记为 @escaping 意味着你必须在闭包中显示的引用 self` 。

- **自动闭包**： 自动闭包是一种自动创建的闭包，用于包装传递给函数作为参数的表达式。**自动闭包不接受任何参数(e.g. () -> T )**，当它被调用的时候，会返回被包装在其中的表达式的值，这种便利语法让你能够省略闭包的花括号，用一个普通的表达式 来代替显式的闭包。

    ```swift
    // customersInLine is ["Ewa", "Barry", "Daniella"] 
    func serve(customer customerProvider: @autoclosure () -> String) { 
        print("Now serving \(customerProvider())!") 
    } 
    serve(customer: customersInLine.remove(at: 0)) // 打印 "Now serving Ewa!"
    ```

    > 1. `@autoclosure` 并不支持带有输入参数的写法，也就是说只有形如 `() -> T ` 的参数才能简化。
    > 2. 通过将参数标记为 `@autoclosure` 来接收一个自动闭包。**现在你可以将该函数当作接受 `String` 类型参数（而非闭包） 的函数来调用，也就是上面看到的`serve(customer: "string")`，可以直接传递字符串参数，而不是闭包或函数，因为`Swift`将会把参数 `"string"` 自动转换为 `() -> String`。 `customerProvider` 参数将自动转化为一个闭包，因为该参数被标记了 `@autoclosure` 特性。
    > 
    >+ [@autoclosure 和 ??](http://swifter.tips/autoclosure/)
    >+ [@autoclosure what, why and when](https://medium.com/ios-os-x-development/https-medium-com-pavelgnatyuk-autoclosure-what-why-and-when-swift-641dba585ece)
    
    
    - `{}()` : 通过闭包或函数设置属性的默认值：
    
        如果某个存储型属性的默认值需要一些定制或设置，你可以使用闭包或全局函数为其提供定制的默认值。每当某个属性所在类型的新实例被创建时，对应的闭包或函数会被调用，而它们的返回值会当做默认值赋值给这个属性。
        这种类型的闭包或函数通常会创建一个跟属性类型相同的临时变量，然后修改它的值以满足预期的初始状态，最 后返回这个临时变量，作为属性的默认值。

    ```swift
    class SomeClass {
        let someProperty: SomeType = {
            // 在这个闭包中给 someProperty 创建一个默认值
            // someValue 必须和 SomeType 类型相同
            return someValue
        }()
    }
    ```

    > **注意**
    注意闭包结尾的大括号后面接了一对空的小括号。这用来告诉 Swift 立即执行此闭包。如果你忽略了这对括 号，相当于将闭包本身作为值赋值给了属性，而不是将闭包的返回值赋值给属性。
    > 
    > 如果你使用闭包来初始化属性，请记住在闭包执行时，实例的其它部分都还没有初始化。这意味着你不能在闭包 里访问其它属性，即使这些属性有默认值。同样，你也不能使用隐式的 self 属性，或者调用任何实例方法。



## 枚举

1. 关联值：

   - 可以在定义Swift枚举来存储任意类型的关联值，每个枚举成员的关联值类型可以各不相同；

   - ```swift
     enum Barcode { 
       case upc(Int, Int, Int, Int) 
       case qrCode(String) 
     }
     ```



2. 原始值的隐式赋值：

   - 在使用原始值为整数或者字符串类型的枚举时，不需要显式地为每一个枚举成员设置原始值，Swift 将会自动为 你赋值。例如使用整数作为原始值时，其默认原始值为0，然后一次递增；当使用字符串作为枚举类型的原始值时，每个枚举成员的隐式原始值为该枚举成员的名称。

   - 使用枚举成员的`rawValue`属性可以访问该枚举成员的原始值。

3. 使用原始值初始化枚举实例：

   - 如果在定义枚举类型的时候使用了原始值，那么将会自动获得一个初始化方法，这个方法接收一个叫做`rawValue`的参数，参数类型极为原始值类型，返回值则是枚举成员或`nil`。因为并非所有的值都能匹配到枚举值，所以，原始值欧股早起总是返回一个可选的枚举成员。

4. 递归枚举：

   - 可以在枚举类型开头加上`indirect`关键字来表明它的所有成员都是可递归的；

   - ```swift
     indirect enum ArithmeticExpression { 
       case number(Int) 
       case addition(ArithmeticExpression, ArithmeticExpression) 
       case multiplication(ArithmeticExpression, ArithmeticExpression) 
     }
     ```



## 类 & 结构体

- Swift允许直接设置结构体属性的子属性；
- **所有的结构体都有一个自动生成的成员逐一构造器**，用于初始化新结构体实例中成员的属性。新实例中各个属性的初始值可以通过属性的名称传递到成员逐一构造器中：

    ```swift
    let  vga = Resolution(width:640, height: 480)
    ```

    与结构体不同，类实例没有默认的成员逐一构造器。

    > 注意: 以上是对字符串、数组、字典的“拷贝”行为的描述。在你的代码中，拷贝行为看起来似乎总会发生。然而，Swift 在幕后只在绝对必要时才执行实际的拷贝。Swift 管理所有的值拷贝以确保性能最优化，所以你没必要去回 避赋值来保证性能最优化。

## 属性

- 计算属性不直接存储值，而是提供一个`getter`和一个可选的`setter`来间接获取和设置其他属性或变量的值。**计算属性可以用于类、结构体和枚举，而存储属性只能用于类和结构体，不能用于枚举。**

- 常量结构体的存储属性：如果创建了一个结构体的实例并将其复制给一个常量，则无法修改该实例的任何属性，即使有属性被声明成变量也不行。这种行为是由于结构体属于值类型，**当值类型的实例被声明为常量的时候，它的所有属性也就成了常量。属于引用类型的类则不一样，把一个引用类型的实例赋给一个常量后，仍然可以修改该实例的变量属性。**

- 延迟存储属性： 在属性声明前使用`lazy`来标示一个延迟存储属性。

    > 必须将延迟存储属性声明为变量（使用`var`关键字），因为属性的初始值可能在实例构造完成之后才会得到，而常量属性在构造过程完成之前必须要有初始值，因此无法声明成延迟属性。
    > 
    > 如果一个被标记为`lazy`的属性在没有初始化时就被多个线程访问，则无法保证该属性只会被初始化一次。

- Swift中的数信没有对应的实例变量，属性的后端存储也无法直接访问。

- 计算属性：类、结构体和枚举可以定义*计算属性*。计算属性不直接存储值，而是提供一个`getter`和一个可选的`setter`，来间接获取和设置其他属性或变量的值。

    > 1. 如果计算属性的`setter`没有定义新值的参数，则可以使用默认名称`newValue`。
    > 2. **必须使用`var`关键字定义计算属性，包括只读计算属性，** 因为他们的值不是固定的。`let`关键字只用来声明常量属性，表示初始化后再也无法修改的值。
    > 3. 只读计算属性的声明可以去掉`get`关键字和花括号。

- 可以为属性添加如下的一个或全部观察器：
    `willSet` 在新的值被设置之前调用;
    `didSet` 在新的值被设置之后立即调用;
    `willSet` 观察器会将新的属性值作为常量参数传入，在 `willSet` 的实现代码中可以为这个参数指定一个名称，如果不指定则参数仍然可用，这时使用默认名称 `newValue` 表示。
    同样，`didSet` 观察器会将旧的属性值作为参数传入，可以为该参数命名或者使用默认参数名 `oldValue`。如果在 `didSet`方法中再次对该属性赋值，那么新值会覆盖旧的值。

    > **我们可以为除了延迟计算属性之外的其他存储属性添加属性观察器，也可以通过重写属性的方式 为继承的属性（包括存储属性和计算属性）添加属性观察器。**
    
    > **不需要为非重写的计算属性添加属性观察器，因为可以通过它的 `setter` 直接监控和响应值的变化。**
    
    > 如果在一个属性的didSet观察器里为它赋值，这个值会替换该观察器之前设置的值。
    
    > **父类的属性在子类的构造器中被赋值时，它在父类中的 `willSet` 和 `didSet` 观察器会被调用，随后才会调用子类的观察器。在父类初始化方法调用之前，子类给属性赋值时，观察器不会被调用。**

    ```swift
    class StepCounter {
        var totalSteps: Int = 0 {
            willSet(newTotalSteps) {
                print("About to set totalSteps to \(newTotalSteps)")
            }
            didSet {
                if totalSteps > oldValue  {
                    print("Added \(totalSteps - oldValue) steps")
                }
            }
        }
    }
    let stepCounter = StepCounter()
    stepCounter.totalSteps = 200
    // About to set totalSteps to 200
    // Added 200 steps
    stepCounter.totalSteps = 360
    // About to set totalSteps to 360
    // Added 160 steps
    stepCounter.totalSteps = 896
    // About to set totalSteps to 896
    // Added 536 steps
    ```

    StepCounter 类定义了一个 `Int` 类型的属性 `totalSteps`，它是一个存储属性，包含 `willSet` 和 `didSet` 观察器。
    
    当 `totalSteps` 被设置新值的时候，它的 `willSet` 和 `didSet` 观察器都会被调用，即使新值和当前值完全相同时也会被调用。
    
    例子中的 `willSet` 观察器将表示新值的参数自定义为 `newTotalSteps`，这个观察器只是简单的将新的值输出。
    
    `didSet` 观察器在 totalSteps 的值改变后被调用，它把新值和旧值进行对比，如果总步数增加了，就输出一个消息表示增加了多少步。`didSet` 没有为旧值提供自定义名称，所以默认值 `oldValue` 表示旧值的参数名。
    
    
    > 如果将属性通过 in-out 方式传入函数，willSet 和 didSet 也会调用。这是因为 in-out 参数采用了拷入拷出模式：即在函数内部使用的是参数的 copy，函数结束后，又对参数重新赋值。

- **全局的常量或变量都是延迟计算的，跟延迟存储属性相似，不同的地方在于，全局的常量或变量不需要标记lazy修饰符。局部范围的常量或变量从不延迟计算。**

- 类型属性是用`static`关键字修饰的，但是如果想让子类支持重写父类方法实现，需要把`static`改为`class`，但是`class`只支持类（协议中好像也可以用），不支持结构体和枚举。


    ```swift
    struct SomeStructure {
        static var storedTypeProperty = "Some value."
        static var computedTypeProperty: Int {
            return 1
        }
    }
    enum SomeEnumeration {
        static var storedTypeProperty = "Some value."
        static var computedTypeProperty: Int {
            return 6
        }
    }
    class SomeClass {
        static var storedTypeProperty = "Some value."
        static var computedTypeProperty: Int {
            return 27
        }
        class var overrideableComputedTypeProperty: Int {
            return 107
        }
    }
    ```

- 存储型类型属性可以是变量或常量，计算型类型属性跟实例的计算型属性一样只能定义成变量属性。**跟实例的存储型属性不同，必须给存储型类型属性指定默认值，因为类型本身没有构造器，也就无法在初始化过程中使用构造器给类型属性赋值。存储型类型属性是延迟初始化的，它们只有在第一次被访问的时候才会被初始化。即使它们被多个线程同时访问，系统也保证只会对其进行一次初始化，并且不需要对其使用`lazy`修饰符。**

- **值类型（结构体和枚举）不支持继承。**

## 方法

- 方法是与某些特定类型相关联的函数。
- 如果你确实需要在某个特定的方法中**修改结构体或者枚举的属性**，你可以为这个方法选择`可变(mutating)`行为，然后就可以从其方法内部改变它的属性；并且这个方法做的任何改变都会在方法执行结束时写回到原始结构中。方法还可以给它隐含的`self`属性赋予一个全新的实例，这个新实例在方法结束时会替换现存实例。
要使用可变方法，将关键字`mutating` 放到方法的`func`关键字之前就可以了。
不能在结构体类型的常量（a constant of structure type）上调用可变方法，因为其属性不能被改变，即使属性是变量属性。
- 类型方法： 可以定义在类型本身上调用的方法，这种方法就叫做类型方法。在方法的`func`关键字之前加上关键字`static`，来指定类型方法。类还可以用关键字`class`来允许子类重写父类的方法实现。在 Objective-C 中，你只能为 Objective-C 的类类型（classes）定义类型方法（type-level methods）。在 Swift 中，你可以为所有的类、结构体和枚举定义类型方法。每一个类型方法都被它所支持的类型显式包含。

## 覆写

- 覆写：**你可以将一个继承来的只读属性重写为一个读写属性，只需要在重写版本的属性里提供`getter`和`setter`即可，但是，不能将一个继承来的可读写属性重写为一个只读属性。如果你在重写属性中提供了`setter`，那么你也一定要提供`getter`。**

- 重写属性观察器：**你不可以为继承来的常量存储属性或者继承来的只读计算属性添加属性观察器。这些属性的值是不可以被设置的**，所以，为他们提供`willSet`和`didSet `实现是不恰当的。此外还要注意，你不可以同时提供重写的`setter`和重写的属性观察器。如果你想观察属性值的变化，并且你已经为那个属性提供了定制的`setter`，那么你在`setter`中就可以观察到任何变化了。

- 你可以通过把方法，属性或下标标记为 `final` 来防止它们被重写，只需要在声明关键字前加上 `final` 修饰符即可（例如： final var ， final func ， final class func ，以及 final subscript ）。你可以通过在关键字 `class` 前添加 `final` 修饰符来将整个类标记为 `final` 的。

## 构造过程

- 与Objective-C中的构造器不同的是：Swift的构造器无需返回值，他们的主要任务是保证新实例在第一次使用前完成正确的初始化。
- **当你为存储型属性设置默认值或者在构造器中为其赋值时，他们的值是被直接设置的，不会触发任何属性观察者。**
- **构造过程中常量属性可以修改：对于类的实例来说，它的常量属性只能在 定义它的类 的构造过程中 修改，不能在子类中修改。** 比如：

    ```swift
    // 修改上面的 SurveyQuestion 示例，用常量属性替代变量属性 text ，表示问题内容 text 在 SurveyQuestio n 的实例被创建之后不会再被修改。尽管 text 属性现在是常量，我们仍然可以在类的构造器中设置它的值：
    class SurveyQuestion {
        let text: String             //常量属性
        var response: String? 
        init(text: String) {
            self.text = text 
        } 
        func ask() {
            print(text) 
        }
    } 
    let beetsQuestion = SurveyQuestion(text: "How about beets?") beetsQuestion.ask() 
    // 打印 "How about beets?" 
    beetsQuestion.response = "I also like beets. (But not with cheese.)"
    ```

- 默认构造器：如果 **结构体或类**的所有属性都有默认值，同时没有自定义的构造器，那么 Swift 会给这些结构体或类提供一个默认构造器（default initializers）。
- **结构体的逐一成员构造器（结构体特有的）**：除了默认构造器，如果结构体没有提供自定义的构造器，他们将自动获得一个逐一成员构造器，**即使结构体的存储属性没有默认值**。
- 值类型的构造器代理：对于值类型，你可以使用`self.init`在自定义的构造器中使用相同类型中的其它构造器，并且你只能在构造器内部调用`self.init`。**如果你为了某个值类型定义了一个自定义构造器，你将无法访问默认构造器（如果是结构体，还将无法访问逐一成员构造器）**。这种限制可以防止你为值类型增加了一个额外的且十分复杂的构造器之后，仍有人错误的使用自动生成的构造器。**假如你希望默认构造器、逐一成员构造器以及你自己定义的构造器都能用来创建实例，你可以将自定义的构造器写到扩展（extension）里面，而不是卸载值类型的原始定义中。**
- 指定构造器是类中最重要的构造器。每一个类都必须拥有至少一个指定构造器。

    ```swift
    //指定构造器
    init(parameters) { 
        statements 
    }
    //便利构造器（在`init`前放置 `convenience` 关键字）
    convenience init(parameters) { 
        statements 
    }
    ```

- 类的构造器代理规则：

      > 为了简化指定构造器和便利构造器之间的调用关系，Swift 采用以下三条规则来限制构造器之间的代理调用：
      > 
      > 规则 1
    指定构造器必须调用其直接父类的的指定构造器。
      > 
      > 规则 2
    便利构造器必须调用同类中（即自己类里面）定义的其它构造器。
      > 
      > 规则 3
    便利构造器必须最终导致一个指定构造器被调用。
      > 
      > 一个更方便记忆的方法是：
        • 指定构造器必须总是向上代理
        • 便利构造器必须总是横向代理

- 两段式构造过程：Swift 中类的构造过程包含两个阶段。第一个阶段，每个存储型属性被引入它们的类指定一个初始值。当每个存储型属性的初始值被确定后，第二阶段开始，它给每个类一次机会，在新实例准备使用之前进一步定制它们的存 储型属性。 两段式构造过程的使用让构造过程更安全，同时在整个类层级结构中给予了每个类完全的灵活性。两段式构造过 程可以防止属性值在初始化之前被访问，也可以防止属性被另外一个构造器意外地赋予不同的值。

- **构造过程的安全检查**（重要）：

      > Swift 编译器将执行 4 种有效的安全检查，以确保两段式构造过程能不出错地完成：
      > 
      > 安全检查 1:
    指定构造器必须保证它所在类引入的所有属性都必须先初始化完成，之后才能将其它构造任务向上代理给父类中 的构造器。
      > 
      > 如上所述，一个对象的内存只有在其所有存储型属性确定之后才能完全初始化。为了满足这一规则，指定构造器 必须保证它所在类引入的属性在它往上代理之前先完成初始化。
      > 
      > 安全检查 2:
    指定构造器必须先向上代理调用父类构造器，然后再为继承的属性设置新值。如果没这么做，指定构造器赋予的 新值将被父类中的构造器所覆盖。
      > 
      > 安全检查 3:
    便利构造器必须先代理调用同一类中的其它构造器，然后再为任意属性赋新值。如果没这么做，便利构造器赋予的新值将被同一类中其它指定构造器所覆盖。
      > 
      > 安全检查 4:
    构造器在第一阶段构造完成之前，不能调用任何实例方法，不能读取任何实例属性的值，不能引用 `self`作为一个值。
      > 
      > 类实例在第一阶段结束以前并不是完全有效的。只有第一阶段完成后，该实例才会成为有效实例，才能访问属性 和调用方法。

- 以下是两段式构造过程中基于上述安全检查的构造流程展示：

      > 阶段 1：
      > 
      > - 某个指定构造器或便利构造器被调用。
      >   > - 完成新实例内存的分配，但此时内存还没有被初始化。
      >   > - 指定构造器确保其所在类引入的所有存储型属性都已赋初值。存储型属性所属的内存完成初始化。
      >   > - 指定构造器将调用父类的构造器，完成父类属性的初始化。
      >   > - 这个调用父类构造器的过程沿着构造器链一直往上执行，直到到达构造器链的最顶部。
      >   > - 当到达了构造器链最顶部，且已确保所有实例包含的存储型属性都已经赋值，这个实例的内存被认为已经完 全初始化。此时阶段 1 完成。
      > 
      > 阶段2：
      > 
      > - 从顶部构造器链一直往下，每个构造器链中类的指定构造器都有机会进一步定制实例。构造器此时可以访问 `self` 、修改它的属性并调用实例方法等等。
      >   > - 最终，任意构造器链中的便利构造器可以有机会定制实例和使用 `self `。

- **Swift中的子类默认情况下不会继承父类的构造器，父类的构造器仅会在安全和适当的情况下被继承。**

## 协议

- 类类型专属协议： 你可以在协议的继承列表中，通过添加 `class` 关键字来限制协议只能被类类型遵循，而结构体和枚举不能遵循该协议。`class` 关键字必须第一个出现在协议的继承列表中，在其他继承的协议之前：

    ```swift
    protocol SomeClassOnlyProtocol: class, SomeInheritedProtocol {
        // 这里是类类型专属协议的定义部分
    }
    ```
    
    当协议定义的要求需要遵循协议的类型必须是引用予以而非值语义时，应该采用类类型专属协议。

- **协议合成：** 同时采纳多个协议,多个协议之间用 & 分隔.协议的合成并不会生成新的协议类型,只是一个临时局部的。 

    ```Swift
    protocol Name {
        var name: String { get }
    }
    protocol Age {
        var age: Int { get }
    }
    struct People: Name, Age {              // 遵守name age这两个协议
        var name: String
        var age: Int
    }
    // 参数支持多个协议的话，协议之间用`&`分隔开
    func say(to people: Name & Age) {       // 参数类型:Name & Age
        print("This is \(people.name), age is \(people.age)") // This is Joan, age is 20
    }
    let p = People(name: "Joan", age: 20)
    say(to: p)                              // 只要遵守这两个协议的对象都能被传进去
    ```
    
- **可选的协议前面需要加 `@objc` 关键字。`@objc` : 表示该协议暴露给`OC`代码，但即使不与`OC`交互只想实现可选协议要求，还是要加`@objc`关键字。带有`@objc`关键字的协议只能被`OC`类，或者带有`@objc`关键字的类遵守，结构体和枚举都不能遵守。**

    ```swift
    @objc protocol CounterDataSource {      // 用于计数的数据源
        @objc optional var fixAdd: Int { get } // 可选属性
        @objc optional func addForCount(count: Int) -> Int // 可选方法,用于增加数值
    }
    class Counter: CounterDataSource {
        var count = 0                       // 用来存储当前值
        var dataSource: CounterDataSource?
        func add() {                        // 增加count值
            // 使用可选绑定和两层可选链式调用来调用可选方法
            if let amount = dataSource?.addForCount?(count: count) {
                count += amount
            }else if let amount = dataSource?.fixAdd {
                count += amount
            }
        }
    }
    class ThreeSource: NSObject, CounterDataSource {
        let fixAdd = 3
    }
    var counter = Counter()
    counter.dataSource = ThreeSource()      // 将counter的数据源设置为ThreeSource
    counter.add()                           // 增加3
    counter.add()                           // 增加3
    print(counter.count)                    // 6
    ```

- **协议扩展：** 协议可以通过扩展来为遵循协议的类型提供属性、方法以及下标的实现。通过这种方式，你可以基于协议本身来实现这些功能，而无需在每个遵循协议的类型中都重复同样的实现，也无需使用全局函数。通过协议扩展，所有遵循协议的类型，都能自动获得这个扩展所增加的方法实现，无需任何额外修改。

- **提供默认实现：** 可以通过协议扩展来为协议要求的属性、方法以及下标提供默认的实现。 `如果遵循协议的类型为这些要求提供了自己的实现，那么这些自定义实现将会替代扩展中的默认实现被使用。` 通过扩展提供的默认实现可以直接调用，而无需使用可选链式调用。

  > 协议扩展和提供的默认实现，可以实现多继承的效果。

## 运算符

- 要实现前缀或者后缀运算符，需要在声明运算符函数的时候在`func`关键字之前指定`prefix`或者`postfix`修饰符。

## 解惑

#### 1. `lazy`修饰的实例为什么不能用`lazy let`？

在 Swift 里你不能创建 `lazy let` 实例属性，这是由 `lazy` 的具体实现细节决定的：它在没有值的情况下以某种方式被初始化，然后在被访问时改变自己的值，这就要求该属性是可变的。因此无法实现一个使用时才会被计算的常量。

> 既然说到了`let`，顺便说一条比较有意思的特性： **被声明在全局作用域下 或者 被声明为一个类型属性（即声明为`static let`）的常量，是自动具有惰性(`lazy`)的，而且还是线程安全的。**

## 重要概念

- **写时复制**: Swift 中的“写时复制”是指，值类型只在被改动前进行复制。传统意义上的值类型会在被传递或者被赋值给其他变量时就发生复制行为，但是这将会带来极大的，也是不必要的性能损耗。写时复制将在值被传递和赋值给变量时首先检查其引用计数，如果引用计数为 1 (唯一引用)，那么意味着并没有其他变量持有该值，对当前值的复制也就可以完全避免，以此在保持值类型不可变性的优良特性的同时，保证使用效率。`Swift` 中像是 `Array` 和 `Dictionary` 这样的类型都是值类型，但是底层实现确是引用类型，它们都利用了写时复制的技术来保证效率。

## 备注

以上内容全部摘自[The Swift Programming Language 中文版](https://swiftgg.gitbook.io/swift/swift-jiao-cheng)

## 资料

- [Swift 烧脑体操（一） - Optional 的嵌套](http://blog.devtang.com/2016/02/27/swift-gym-1-nested-optional/)
- [Swift 烧脑体操（二） - 函数的参数](http://blog.devtang.com/2016/02/27/swift-gym-2-function-argument/)
- [Swift 烧脑体操（三） - 高阶函数](http://blog.devtang.com/2016/02/27/swift-gym-3-higher-order-function/)
- [Swift 烧脑体操（四） - map 和 flatMap](http://blog.devtang.com/2016/03/05/swift-gym-4-map-and-flatmap/)
- [Swift 烧脑体操（五）- Monad](http://blog.devtang.com/2016/04/05/swift-gym-5-monad)
- [“懒”点儿好](http://swift.gg/2016/03/25/being-lazy/)
- [Swift2.0：理解flatMap](http://swift.gg/2015/08/06/swift-2-flatmap/)
- [谈谈 Swift 中的 map 和 FlatMap 第二篇 - 另一层思维方式](http://www.swiftcafe.io/2016/03/31/about-map-2)
- [Swift中枚举高级用法与实践](http://swift.gg/2015/11/20/advanced-practical-enum-examples/)
- [Unowned 还是 Weak？生命周期和性能对比](http://swift.gg/2017/05/16/unowned-or-weak-lifetime-and-performance/)
- [所有权宣言 - Swift 官方文章 Ownership Manifesto 译文评注版](https://onevcat.com/2017/02/ownership/)
