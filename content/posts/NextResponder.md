---
title: "NextResponder"
date: 2022-09-19T16:34:10+08:00
lastmod: 2022-09-19T16:34:10+08:00
draft: false
author: "Zero.D.Saber"
authorLink: "https://github.com/faimin"
description: "childController的nextResponder是谁？"
tags: ["iOS", "事件响应链"]
categories: ["事件响应链"]

images: []
featuredImage: "/images/ui/fairy_tail_ailusaha.jpeg"
featuredImagePreview: "/images/ui/fairy_tail_ailusaha.jpeg"
---

<!--more-->

在这里就不介绍事件响应链了，想必大家很清楚，如果有朋友印象模糊了，推荐看看[iOS触摸事件全家桶](https://www.jianshu.com/p/c294d1bd963d)这篇文章。

那写点啥呢？咱们聊点上文中的几处不严谨的地方：视图的`nextResponder`是谁。

## 视图的`nextResponder`是谁？

> UIView
> 
> 若视图是控制器的根视图，则其nextResponder为控制器对象；否则，其nextResponder为父视图。

以上说法一般情况下是没问题的，但是对于控制器添加子控制器的场景确是不符合的。

仅仅把控制器的视图添加到父视图上，则视图的下一个响应者就是父视图，而不是控制器。

![](/images/ui/unaddchildcontroller.png "unaddchildcontroller")

把子控制器也添加到父控制器上，子控制器的下一响应者是父控制器的跟视图，而不是父控制器。

![](/images/ui/addchildcontroller.png "addchildcontroller")


## 推荐

- [iOS触摸事件全家桶](https://www.jianshu.com/p/c294d1bd963d)