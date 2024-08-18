# 面试资料



## 优秀文章

### 计算机基础

- [iOS Memory内存详解](https://mp.weixin.qq.com/s/YpJa3LeTFz9UFOUcs5Bitg)
- [【精华】程序员的自我修养视频教程](https://www.bilibili.com/video/BV1xf4y127AJ)
- [基本功 | 一文讲清多线程和多线程同步](https://tech.meituan.com/2024/07/19/multi-threading-and-multi-thread-synchronization.html)

### UI

- [iOS触摸事件全家桶](https://www.jianshu.com/p/c294d1bd963d)
- [移动端渲染原理浅析](https://mp.weixin.qq.com/s/-ZMCk0_Mc1xKth32GI_mPA)
- [iOS渲染原理](https://juejin.cn/post/7078881864030617607)

### Runtime

- [iOS源码阅读笔记](https://faimin.github.io/ios%E6%BA%90%E7%A0%81%E9%98%85%E8%AF%BB%E7%AC%94%E8%AE%B0/)
- [dyld详解](https://www.dllhook.com/post/238.html)
- [iOS之武功秘籍](https://juejin.cn/post/6936173181321347102)
- [Block的本质](https://github.com/pro648/tips/blob/master/sources/Block%E7%9A%84%E6%9C%AC%E8%B4%A8.md)
- [Block捕获实体引用](https://github.com/tripleCC/Laboratory/blob/5064a0f4e7c26ea5b71b8b3d7b1a64121f0c6ea9/BlockStrongReferenceObject/README.md)
- [图解fishhook原理](https://mp.weixin.qq.com/s/dcQrR4knN0aGDPy2hsrgmg)

### Performance

- [带你打造一套APM监控系统](https://github.com/FantasticLBP/knowledge-kit/blob/master/Chapter1%20-%20iOS/1.74.md)
- [iOS APP包瘦身真没你想的那么难，难得是业务！！！](https://juejin.cn/post/7056451940326047758)
- [iOS写一个死锁检测](https://juejin.cn/post/7037454684453339144)

### Crash

- [iOS crash分类：Mach异常、Unix信号和NSException异常](https://blog.csdn.net/u014600626/article/details/119517507)
- [iOS崩溃监控与分析](https://tenloy.github.io/2021/08/01/Crash-Monitor.html#%E4%B8%89%E3%80%81%E6%8D%95%E8%8E%B7-%E2%80%94-Mach%E5%BC%82%E5%B8%B8%E4%B8%8EUnix%E4%BF%A1%E5%8F%B7%E5%BC%82%E5%B8%B8)
- [你真的懂iOS的异常捕获吗？](https://juejin.cn/post/7142656591139962888)
- [iOS Crash崩溃异常捕获](https://www.jianshu.com/p/3f6775c02257)
- [iOS Crash 收集框架 KSCrash 源码解析(上)](https://zhang759740844.github.io/2019/10/25/kscrash/)
- [关于KSCrash的一些整理(干货满满) ](https://juejin.cn/post/7130440973293158431)

### Network

- [计算机网络太难了？了解这一篇就够了](https://juejin.cn/post/6844903951335178248)
- [「查缺补漏」巩固你的HTTP知识体系](https://juejin.cn/post/6857287743966281736)
- [Web技术（五）：HTTP/2 是如何解决HTTP/1.1 性能瓶颈的？](https://blog.csdn.net/m0_37621078/article/details/106006303)
- [Web技术（六）：QUIC 是如何解决TCP 性能瓶颈的？](https://blog.csdn.net/m0_37621078/article/details/106506532)

### Swift

- [从 SIL 角度看 Swift 中的值类型与引用类型](https://juejin.cn/post/7030983921328193549)
- [从 SIL 看 Swift 函数派发机制](https://mp.weixin.qq.com/s/KvwFyc1X_anTt-DTw86u7Q)
- [iOS下的闭包下篇-Closure](https://mp.weixin.qq.com/s/97Ij2N545ydx6WBNAwncOA)
- [Swift 性能优化(2)——协议与泛型的实现](http://chuquan.me/2020/02/19/swift-performance-protocol-type-generic-type/)
- [Swift 泛型底层实现原理](http://chuquan.me/2020/04/20/implementing-swift-generic/)

### 业务

- [iOS直播流程概述](https://mp.weixin.qq.com/s/n5ImksCKgUwtl0VdCRSvtw)


## 算法

### 快速排序

```swift
class Solution {
    func sortArray(_ nums: [Int]) -> [Int] {
        let left = 0, right = nums.count - 1
        var arr = nums
        quickSort(&arr, left, right)
        return arr
    }

    func quickSort(_ nums: inout [Int], _ low: Int, _ high: Int) {
        guard low < high else {
            return
        }

        let randomIndex = Int.random(in: (low...high))
        let pivot = nums[randomIndex]
        // 把随机选择的数放到最前面
        nums.swapAt(low, randomIndex)
        var left = low, right = high

        while left < right {
            while left < right, pivot <= nums[right] {
                right -= 1
            }
            while left < right, nums[left] <= pivot {
                left += 1
            }
            if left < right {
                nums.swapAt(left, right)
            }
        }
        // 把pivot交换回来
        nums.swapAt(left, low)

        quickSort(&nums, low, left - 1)
        quickSort(&nums, left + 1, high)
    }
}
```

### 二叉树遍历

#### 递归

```swift
/// traversals 为输出的数组
func preorder(_ node: TreeNode?) {
    guard let node = node else {
      return
    }
    
    /// 前序遍历
    traversals.append(node.val) 
    preorder(node.left)
    preorder(node.right)
    
    /// 中序遍历
    preorder(node.left)
    traversals.append(node.val) 
    preorder(node.right)
    
    /// 后序遍历
    preorder(node.left)
    preorder(node.right)
    traversals.append(node.val) 
}
```

#### 迭代

> 前序遍历

```swift
func preorderIteration(_ root: TreeNode?) {
    var st: [TreeNode?] = [root]
    while !st.isEmpty {
        guard node = st.removeLast() else {
            continue
        }
        traversals.append(node.val)
        st.insert(node.right, at: 0)
        st.insert(node.left, at: 0)
    }
}
```

> 中序遍历

```swift
func inorderIteration(_ root: TreeNode?) {
    var st: [TreeNode?] = []
    var cur: TreeNode? = root
    while cur != nil || !st.isEmpty {
        if cur != nil {
            st.append(cur)
            cur = cur?.left
        } else {
            let lastNode = st.popLast()
            traversals.append(lastNode!.val)
            cur = lastNode?.right
        }
    }
}
```

> 后序遍历

```swift
func postorderIteration(_ root: TreeNode?) {
    var st: [TreeNode?] = [root]
    while !st.isEmpty {
        let node = st.removeFirst()
        if node != nil {
            traversals.append(node!.val)
        } else {
            continue
        }
        st.insert(node?.left, at: 0)
        st.insert(node?.right, at: 0)
    }
    traversals = traversals.reversed()
}
```

#### 颜色标记

> 前序 中→左→右 按照 右→左→中
>
> 中序 左→中→右 按照 右→中→左
>
> 后序 左→右→中 按照 中→右→左

```swift
func inorderTraversal(_ root: TreeNode?) -> [Int] {
    
    var traversals = [Int]()
    
    var stack = [(root, false)]
    
    while !stack.isEmpty {
        let (node, isVisted) = stack.removeLast()
        guard let node == node else {
            continue
        }
        
        if isVisted {
            traversals.append(node.val)
            continue
        }
        
        // ------ 逆序添加 ------
        
        ///前序遍历
        stack.append((node.right, false))
        stack.append((node.left, false))
        stack.append((node, true))
        
        ///中序遍历
        stack.append((node.right, false))
        stack.append((node, true))
        stack.append((node.left, false))
        
        ///后序遍历
        stack.append((node, true))
        stack.append((node.right, false))
        stack.append((node.left, false))
    }
    return traversals
}
```

### 堆排序

```swift
// 堆排序
func sortArray(_ nums: [Int]) -> [Int] {
    var nums = nums
    var endIndex = nums.count - 1
    // 1.把当前数组构建成一个大顶堆
    // 2.接着第一个值与最后一个值调换(把最大值放到最后)
    // 3.然后把刨除最后最大值的数组重新构建成大顶推，
    // 4.再然后递归执行上面的流程
    repeat {
        buildMaxHeap(&nums, endIndex)
        (nums[endIndex], nums[0]) = (nums[0], nums[endIndex])
        endIndex = endIndex - 1
    } while(endIndex > 0)
    
    return nums
}

// 把数组构建成大顶堆
private func buildMaxHeap(_ nums: inout [Int], _ endIndex: Int) {
    var parentIndex = endIndex >> 1
    
    while parentIndex >= 0 {
        let parentValue = nums[parentIndex]
        var minNodeIndex = parentIndex
        
        let leftChildIndex = parentIndex * 2 + 1
        if endIndex >= leftChildIndex && nums[leftChildIndex] > parentValue {
            minNodeIndex = leftChildIndex
        }
        
        let rightChildIndex = parentIndex * 2 + 2
        if rightChildIndex <= endIndex && nums[rightChildIndex] > nums[minNodeIndex] {
            minNodeIndex = rightChildIndex
        }
        
        // 如果父节点不是最大的值，那么与最大值进行交换，保证堆顶是最大值
        if minNodeIndex != parentIndex {
            (nums[minNodeIndex], nums[parentIndex]) = (nums[parentIndex], nums[minNodeIndex])
        }
        
        parentIndex = parentIndex - 1
    }
}
```

### 基数（桶）排序

```swift
// 基数排序
func radixSort(_ nums: [Int]) -> [Int] {
    // 最终结果
    var resultArray = nums
    
    //通过基数排序实现
    var maxDigit = 0 //最大位数
    var digit = 0 //当前所在位数(个十百千万)
    var maxValue = 0
    repeat {
        //1、建立20个桶((-9 - 9)一个数字一个桶),负数放在前10个桶,正数放到后10个桶
        var buckets = [[Int]]()
        for _ in 0 ..< 20 {
            buckets.append([Int]())
        }
        
        //2、按每个位上的值放入对应的桶中
        //let digit10n = NSDecimalNumber(decimal: pow(Decimal(10), digit)).intValue
        let digit10n = Int(pow(Double(10), Double(digit)))
        for num in resultArray {
            let mod = num / digit10n % 10 //取得某位上的值
            buckets[mod + 10].append(num)
            //首次遍历时获取到数组中的最大值，后面要用它计算最大位数是多少位
            if digit == 0 {
                maxValue = max(maxValue, abs(num))
            }
        }
        
        //resultArray.removeAll()
        //3、二维数组降维成一维数组，用于二次递归
        resultArray = buckets.flatMap {$0}
        
        // 计算绝对值最大的数的位数
        if digit == 0 {
            var tempMaxValue = maxValue
            while tempMaxValue != 0 {
                tempMaxValue = tempMaxValue / 10
                maxDigit = maxDigit + 1
            }
        }
        
        //4、进位
        digit = digit + 1
    } while (digit < maxDigit)
    
    return resultArray
}
```

### 寻找两个View的最近公共父视图

```objectivec
- (__kindof MAS_VIEW *)mas_closestCommonSuperview:(MAS_VIEW *)view {
    MAS_VIEW *closestCommonSuperview = self;
    MAS_VIEW *secondViewSuperview = view;

    while (closestCommonSuperview != secondViewSuperview) {
        closestCommonSuperview = closestCommonSuperview == nil ? view : closestCommonSuperview.superview;
        secondViewSuperview = secondViewSuperview == nil ? self : secondViewSuperview.superview;
    }

    return closestCommonSuperview;
}
```

### leetcode

- [#42 接雨水](https://leetcode.cn/problems/trapping-rain-water/)
- [#142 环形链表II](https://leetcode.cn/problems/linked-list-cycle-ii/)
- [#206 反转链表](https://leetcode.cn/problems/reverse-linked-list/)
- [#92 反转链表II](https://leetcode.cn/problems/reverse-linked-list-ii/)
- [#405 十进制转十六进制](https://leetcode.cn/problems/convert-a-number-to-hexadecimal/)
- [#215 数组中第K个最大的元素](https://leetcode.cn/problems/kth-largest-element-in-an-array/)
- [#面试题02.08 环路检测](https://leetcode.cn/problems/linked-list-cycle-lcci/)



