---
title: "React笔记"
date: 2024-01-14T01:38:00+08:00
lastmod: 2025-03-07T14:00:00+08:00
draft: false
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
const jsonString = '{"componentName":"abc","theme":"light","debugMode":"1"}';
const obj = JSON.parse(jsonString, function (k, v) {
  if (k == "theme") {
    // 给自定义的属性赋值
    this.custom = v;
    // 返回undefined会把当前这个key从对象中移除
    return undefined;
  } else if (k == "") {
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
const arr = [];
console.log(arr[0]); // undefined
```

`undefined`问题：

![undefined](/images/reactnative/undefined.webp "undefined")

解决办法：

```javascript
const arr = undefined;
console.log(arr?.[0]); // undefined
```

## Q：JS中如何判断一个变量是数组还是对象？

```javascript
const arr = [];
const obj = {};

console.log(Array.isArray(arr)); // true
```

## Q: TypeScript中`unknown`和`never`

1. `unknown`表示不确定的类型，可以赋值给任何类型，但是在使用之前需要进行类型检查，否则在执行函数调用时会报错，而`any`不需要进行类型检查就可以执行，这点是与`any`的不同之处。
2. `never`可以用作类型检查，同时返回值为`never`表示它不会有任何的返回值，其中一个场景如下：
   ```typescript
   function foo(): never {
      const x: number = 999;
      if (x > 0) {
        //⚠️ error
        return;
      }
      console.log(x);
   }
   ```

参考： [TypeScript 中 any、unknown 和 never 完整指南](https://mp.weixin.qq.com/s/Ut77dt3wqvhePXxumXYMDQ)


## Q：<> vs React.Fragment

1. 相同点：

- 都可以包裹子元素
- 都不渲染任何真实的`DOM`标签
- 性能提升

2. 不同点：

- `React.Fragment`支持设置`key`属性

#### `Fragment`可以解决我们什么问题？

`map`函数中的组件需要设置`key`属性，`<>` 并不支持设置属性，而我们又不想增加`DOM`节点，此时`React.Fragment`就可以大展身手了：

```jsx
<Text style={style} numberOfLines={numberOfLines}>
    {icons?.map(({ width, height, url }, index) => {
        return (
            <React.Fragment key={index.toString()}>
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

## Q：手动触发React-Query请求

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

## useInfiniteQuery用法

```typescript
export interface IBaseResponse<T> {
    [propName: string]: any;
    message?: string;
    code?: string;
    data: T;
}

export function useQueryXXList() {
    const dispatch = useDispatch();
    const currentPageCount = useAppSelector(selectCurrentPageCount);

    return useInfiniteQuery<XXResponse>(
        ['a', 'b'],
        (params) => {
            return requestXXList({ cursor: params?.pageParam });
        },
        {
            onSuccess: (data) => {
                const listCount = data?.pages?.length ?? 0;
                if (currentPageCount == listCount) {
                    return;
                }
                if (listCount > 0) {
                    const xxData = data?.pages?.[listCount - 1]?.data;
                    dispatch(updateXXListData(xxData));
                } 
            },
            onError: (error) => {
                console.log(error);
            },
            getNextPageParam: (
                lastPage: IBaseResponse<XXListData>,
                _pages,
            ) => {
                if (lastPage?.data?.nextCursor !== 'XX') {
                    return lastPage?.data?.nextCursor;
                }
                // 没有更多数据
                return undefined;
            },
        },
    );
}
```

## Q：ListEmptyComponents 不能铺满：

给`SectionList`设置`contentContainerStyle`属性:

```jsx
<SectionList
  contentContainerStyle={{
    flexGrow: 1,
  }}
/>
```

## Q：条件渲染

> [React 中条件渲染的 N 种方法](https://mp.weixin.qq.com/s/ZOvR7htlTIppyr0_G39ezA)

在写组件时不要用`{ 判断条件 && 组件 }`这种写法，因为假如前面的条件是`false`，那这个结果就是 `{ false }` ，然而这并不是一个合法的组件，在某些场景下会报错。建议使用`{ 判断条件 ? 组件 : null  }`这种方式。

## Q: 条件渲染组件

> Repo: [Zero.js](https://github.com/faimin/zero.js)

```jsx
// ref solid.js: https://github.com/solidjs/solid/blob/19013bffa7c2494b9ce43d0f00172ee529996134/packages/solid/src/render/flow.ts

/**
 * Selects a content based on condition when inside a `<Switch>` control flow
 * ```typescript
 *   <ZShow when={state.count > 0} fallback={<div>Loading...</div>}>
 *      <div>My Content</div>
 *   </ZShow>
 * ```
 */
export function ZShow<T>(props: {
	when: T | undefined | null | false;
	fallback?: React.ReactNode;
	children: React.ReactNode;
}): React.JSX.Element | null {
	return props.when ? <>{props.children}</> : <>{props.fallback ?? null}</>;
}

/**
 * Switches between content based on mutually exclusive conditions
 * ```typescript
 * <ZSwitch fallback={<FourOhFour />}>
 *   <ZMatch when={state.route === 'home'}>
 *     <Home />
 *   </ZMatch>
 *   <ZMatch when={state.route === 'settings'}>
 *     <Settings />
 *   </ZMatch>
 * </ZSwitch>
 * ```
 */
export function ZSwitch(props: {
	fallback?: React.JSX.Element;
	children: React.JSX.Element | React.JSX.Element[];
}): React.JSX.Element | null {
	let conditions = props.children;

	if (!Array.isArray(conditions)) {
		conditions = [conditions];
	}

	for (let i = 0; i < conditions.length; ++i) {
		const matchProps = conditions[i].props;
		if (matchProps?.when) {
			return <>{matchProps.children}</>;
		}
	}
	return <>{props.fallback ?? null}</>;
}

export type ZMatchProps<T> = {
	when: T | undefined | null | false;
	children: React.ReactNode;
};

/**
 * Selects a content based on condition when inside a `<Switch>` control flow
 * ```typescript
 * <ZMatch when={condition()}>
 *   <Content/>
 * </ZMatch>
 * ```
 */
export function ZMatch<T>(props: ZMatchProps<T>): React.ReactNode | null {
	return props.when ? <>{props.children}</> : null;
}
```

## Q: 切圆角时如何把子类超出父视图的部分也切掉？

确保父元素的`overflow`属性设置为`hidden`。

```jsx
{
  overflow: "hidden";
}
```

## Q: 如何让文字纵向居中？

1. 让`View`组件包一层
2. 设置`lineHeight`与控件高度相同

```jsx
<Text style={{ textAlign: "center", lineHeight: 40 }}>文本内容</Text>
```

## Q: 如何让视图不响应事件？

```jsx
<View pointerEvents="none" />
```

## Q: 有哪些实用API？

```javascript
import {
  useWindowDimensions,
  NativeModules,
  StatusBar,
  Platform,
} from "react-native";

const { StatusBarManager } = NativeModules;

const windowWidth = useWindowDimensions().width;
const windowHeight = useWindowDimensions().height;

export const STATUS_BAR_HEIGHT =
  Platform.OS === "android" ? StatusBar.currentHeight : StatusBarManager.HEIGHT;

// Platform.select
const styles = StyleSheet.create({
  container: {
    marginTop: Platform.OS === "android" ? 25 : 0,
  },
  text: {
    ...Platform.select({
      ios: { color: "purple", fontSize: 24 },
      android: { color: "blue", fontSize: 30 },
    }),
    fontWeight: "bold",
    textAlign: "center",
  },
});
```

## Q: redux中一个reducer想读取其他reducer数据怎么办？

使用 `extraReducers`

```diff
export const xxxReducer = createSlice({
    name: 'xxxReducer',
    initialState: {
        data: undefined as IProp,
        show: false,
        enable: false,
    },
    reducers: {
        updateIPropInfo: (state, action: PayloadAction<IProp>) => {
            state.data = action.payload;
        },
        updateClockInLoadingStatus: (state, action: PayloadAction<boolean>) => {
            state.show = action.payload;
        },
    },
    // 在这里截获其他reducer中的数据，
    // 如下面的updateDetailData就是来自其他reducer
+    extraReducers: (builder) => {
+        builder.addCase(
+           updateDetailData,
+            (state, action: PayloadAction<DetailResponse>) => {
+                const model = action.payload?.data;
+                state.enable = model?.enable === 1;
+            },
+        );
+    },
});
```
