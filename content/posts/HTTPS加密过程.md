---
title: "HTTPS加密过程"
date: 2024-08-22T14:08:00+08:00
lastmod: 2024-08-22T14:08:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: ""
tags: ["网络", "原理", "面试"]
categories: ["网络"]

images: []
featuredImage: ""
featuredImagePreview: "/images/network/http_to_https_cover.webp"
---

HTTPS加密过程

<!--more-->

## HTTPS加密过程

{{< bilibili id=BV1w4411m7GL p=1 >}}

发送HTTPS请求首先要进行SSL/TLS握手，握手过程大致如下：

    1. 客户端发起握手请求，携带随机数1、支持算法列表、SSL/TLS版本等参数；
    2. 服务端收到请求，选择合适的算法，下发随机数2和包含公钥证书的数字证书；
    3. 客户端对服务端证书进行校验，校验通过后用系统证书对数字证书解密拿到公钥。之后发送随机数3 和对随机数1、2的hash值，该信息使用公钥加密；
    4. 服务端通过私钥获取随机数3，同时它也会对随机数1、2进行hash然后和收到的hash做对比，看看客户端是否是可信的；
    5. 双方根据以上交互的信息（比如3个随机数）生成`session ticket`，用作该连接后续数据传输的加密密钥。

![](/images/network/HTTPS_TLS.webp "https_tls")

