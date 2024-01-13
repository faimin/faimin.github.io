---
weight: 7
title: "React Native笔记"
date: 2024-01-14T01:38:00+08:00
lastmod: 2024-01-14T01:38:00+08:00
draft: false
author: "Zero.D.Saber"
authorLink: "https://github.com/faimin"
description: "记录React Native学习过程中的一点收获"
tags: ["ReactNative"]
categories: ["学习笔记"]

images: []
featuredImage: "/images/reactnative/react_native.webp"
featuredImagePreview: "/images/reactnative/react_native.webp"
---

<!--more-->

## Q：JSON转JavaScript对象时自定义key

```javascript
const jsonString = '{"componentName":"abc","theme":"light","debugMode":"1"}'
const obj = JSON.parse(jsonString, function(k, v){
	if (k == 'theme') {
        // 给自定义的属性赋值
		this.custom = v;
        // 返回undefined会把当前这个key从对象中移除
		return undefined;
	} else if (k == '') {
		console.log("宝儿姐");
	}
	return v;
});

console.log(obj);
```

## Q：对象如何判空？

```javascript
let obj;

console.log(obj == null); // true
console.log(obj == undefined); // true
console.log(obj == false); // false
```

## Q：?? 与 || 区别

`??` 只有当`value`是`null`、`undefined`时才会取后面的值，而 `||` 则认为`null`、`undefined`、`0`、`""`、`false` 这些都是`false`。

## Q：JS数组取值需要注意越界问题吗？

不需要，`JS`的数组不会发生越界的异常，我们使用时只需关注数组是否 `undefined`的问题。

```javascript
const arr = []
console.log(arr[0]) // undefined
```

undefined问题：

![undefined](/images/reactnative/undefined.webp "undefined")

解决办法：
```javascript
const arr = undefined
console.log(arr?.[0]) // undefined
```

## Q：JS中如何判断一个变量是数组还是对象？

```javascript
const arr = []
const obj = {}

console.log(Array.isArray(arr)) // true
```

## Q：<> vs React.flagment

1. 相同点：

- 都可以包裹子元素
- 都不渲染任何真实的`DOM`标签
- 性能提升

2. 不同点：

- `React.flagment`支持设置`key`属性

#### `fragment`可以解决我们什么问题？ 

`map`函数中的组件需要设置`key`属性，`<>` 并不支持设置属性，而我们又不想增加`DOM`节点，此时`React.fragment`就可以大展身手了：

```jsx
<Text style={style} numberOfLines={numberOfLines}>
    {icons?.map(({ width, height, url }, index) => {
        return (
            <React.fragment key={index.toString()}>
                <Image
                    style={styles.iconImg}
                    resizeMode={'contain'}
                    source={{
                        uri: url,
                    }}
                />
                <Text>&nbsp;</Text>
            </React.Fragment>
        );
    })}

    {props.children ?? ''}
</Text>
```

## Q：hook函数不让在函数中使用怎么办？

使用`useMutation`

```jsx
export function useQueryProviderNextPage() {
    const bookId = 123
    const dispatch = useAppDispatch();
    return useMutation(
        (params: IParams) => {
            return request({
                method: 'POST',
                url: '/a/b/c',
                params: {
                    id: bookId,
                    currentPage: params.currentPage ?? 2,
                },
            });
        },
        {
            onSuccess: (response) => {
                if (response) {
                    dispatch(updateProviderList(response.data));
                }
            },
            onError: (response) => {
                console.log('--- 请求失败---', console.log(JSON.stringify(response)));
            },
        },
    );
}

const fetchNextPageMutation = useQueryNextPage();

// 调用
fetchNextPageMutation.mutate({
    currentPage: (section?.currentPage ?? 1) + 1,
	bookId: section?.id,
});
```

## Q：ListEmptyComponets 不能铺满：

给`SectionList`设置如下属性:

```jsx
contentContainerStyle={{
  flexGrow: 1,                    
}}
```

## Q：条件渲染

在写组件时不要用`{ 判断条件 && 组件 }`这种写法，因为假如前面的条件是`false`，那这个结果就是 `{ false }` ，然而这并不是一个合法的组件，在某些场景下会报错。建议使用`{ 判断条件 ? 组件 : null  }`这种方式。