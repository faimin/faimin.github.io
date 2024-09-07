---
title: "Git备忘录"
date: 2024-09-07T18:50:00+08:00
lastmod: 2024-09-07T18:50:00+08:00
draft: false
authorLink: "https://github.com/faimin"
description: "Git不常用命令备忘录"
tags: ["git"]
categories: ["git"]

images: []
featuredImage: "/images/git/git.png"
featuredImagePreview: "/images/git/git.png"
---


## Git备忘录

#### 覆盖最近一次commit

```bash
$ git commit --amend -m "message"
```

#### 合并多个commit

```bash
$ git rebase -i [startpoint] [endpoint]
$ git rebase -i HEAD~2 # 合并最近两次提交
```

`endpoint`默认为当前分支指向的`HEAD`节点。参数`-i`表示`interactive(交互)`，该命令执行之后会进入一个`vim`的交互编辑界面，下面会有一些参数的说明：

```sql
pick：保留该commit（缩写:p）
reword：保留该commit，但我需要修改该commit的注释（缩写:r）
edit：保留该commit, 但我要停下来修改该提交(不仅仅修改注释)（缩写:e）
squash：将该commit和前一个commit合并（缩写:s）
fixup：将该commit和前一个commit合并，但我不要保留该提交的注释信息（缩写:f）
exec：执行shell命令（缩写:x）
drop：我要丢弃该commit（缩写:d）
```

#### 永久删除git内二进制

如果我们开发中忘了把某二进制文件加入`.gitignore`，而放入了`git`文件，那它就会一直存在。比如`Pod`目录，当引入很多库时，`git`文件会越来越大，即使后面再加入到`.gitignore`，`git`历史里也会存有记录，这个是无法删除的。好在`git`给我们提供了一个补救措施：

```bash
$ git filter-branch --tree-filter 'rm -f target.file'
```
后面的命令里可以执行删除语句。注意该命令会重写整个`git`历史，多人协作时更应该慎用。


#### git仓库迁移

git仓库的迁移，在一些git管理平台像是gitlab和github是有的，推荐使用平台提供的方法，如果没有的话我们则可以使用git语句操作：

```bash
$ git clone --bare git@host/old.git # clone原仓库的裸仓库
$ cd old.git
$ git push --mirror git@host/new.git # 使用mirror参数推送至新仓库
```


## 参考

[iOS摸鱼周报 第二期](https://juejin.cn/post/6913750369604468744)