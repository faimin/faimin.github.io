# 前端开发环境配置



## 问题

### Python12 移除 distutils 包，导致 pnpm 执行失败

```bash
❯ pnpm add canvas -D
Packages: +804
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Progress: resolved 804, reused 804, downloaded 0, added 0, done
node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/node_modules/canvas: Running install script, failed in 1.7s
.../node_modules/canvas install$ node-pre-gyp install --fallback-to-build --update-binary
│ node-pre-gyp info it worked if it ends with ok
│ node-pre-gyp info using node-pre-gyp@1.0.11
│ node-pre-gyp info using node@20.11.0 | darwin | arm64
│ node-pre-gyp http GET https://github.com/Automattic/node-canvas/releases/download/v2.11.2/canvas-v2.11.2-node-v115-darwin-unknown-ar…
│ node-pre-gyp ERR! install response status 404 Not Found on https://github.com/Automattic/node-canvas/releases/download/v2.11.2/canva…
│ node-pre-gyp WARN Pre-built binaries not installable for canvas@2.11.2 and node@20.11.0 (node-v115 ABI, unknown) (falling back to so…
│ node-pre-gyp WARN Hit error response status 404 Not Found on https://github.com/Automattic/node-canvas/releases/download/v2.11.2/can…
│ gyp info it worked if it ends with ok
│ gyp info using node-gyp@9.4.1
│ gyp info using node@20.11.0 | darwin | arm64
│ gyp info ok 
│ gyp info it worked if it ends with ok
│ gyp info using node-gyp@9.4.1
│ gyp info using node@20.11.0 | darwin | arm64
│ gyp info find Python using Python version 3.12.1 found at "/Users/zero_d_saber/.pyenv/versions/3.12.1/bin/python"
│ gyp info spawn /Users/zero_d_saber/.pyenv/versions/3.12.1/bin/python
│ gyp info spawn args [
│ gyp info spawn args   '/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/node-gyp/gyp/gyp…
│ gyp info spawn args   'binding.gyp',
│ gyp info spawn args   '-f',
│ gyp info spawn args   'make',
│ gyp info spawn args   '-I',
│ gyp info spawn args   '/Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/node_modules/canvas…
│ gyp info spawn args   '-I',
│ gyp info spawn args   '/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/node-gyp/addon.g…
│ gyp info spawn args   '-I',
│ gyp info spawn args   '/Users/zero_d_saber/Library/Caches/node-gyp/20.11.0/include/node/common.gypi',
│ gyp info spawn args   '-Dlibrary=shared_library',
│ gyp info spawn args   '-Dvisibility=default',
│ gyp info spawn args   '-Dnode_root_dir=/Users/zero_d_saber/Library/Caches/node-gyp/20.11.0',
│ gyp info spawn args   '-Dnode_gyp_dir=/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/n…
│ gyp info spawn args   '-Dnode_lib_file=/Users/zero_d_saber/Library/Caches/node-gyp/20.11.0/<(target_arch)/node.lib',
│ gyp info spawn args   '-Dmodule_root_dir=/Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/n…
│ gyp info spawn args   '-Dnode_engine=v8',
│ gyp info spawn args   '--depth=.',
│ gyp info spawn args   '--no-parallel',
│ gyp info spawn args   '--generator-output',
│ gyp info spawn args   'build',
│ gyp info spawn args   '-Goutput_dir=.'
│ gyp info spawn args ]
│ Traceback (most recent call last):
│   File "/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/node-gyp/gyp/gyp_main.py", line…
│     import gyp  # noqa: E402
│     ^^^^^^^^^^
│   File "/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/node-gyp/gyp/pylib/gyp/__init__…
│     import gyp.input
│   File "/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_modules/node-gyp/gyp/pylib/gyp/input.py…
│     from distutils.version import StrictVersion
│ ModuleNotFoundError: No module named 'distutils'
│ gyp ERR! configure error 
│ gyp ERR! stack Error: `gyp` failed with exit code: 1
│ gyp ERR! stack     at ChildProcess.onCpExit (/Users/zero_d_saber/.volta/tools/image/packages/pnpm/lib/node_modules/pnpm/dist/node_mo…
│ gyp ERR! stack     at ChildProcess.emit (node:events:518:28)
│ gyp ERR! stack     at ChildProcess._handle.onexit (node:internal/child_process:294:12)
│ gyp ERR! System Darwin 23.2.0
│ gyp ERR! command "/Users/zero_d_saber/.volta/tools/image/node/20.11.0/bin/node" "/Users/zero_d_saber/.volta/tools/image/packages/pnp…
│ gyp ERR! cwd /Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/node_modules/canvas
│ gyp ERR! node -v v20.11.0
│ gyp ERR! node-gyp -v v9.4.1
│ gyp ERR! not ok 
│ node-pre-gyp ERR! build error 
│ node-pre-gyp ERR! stack Error: Failed to execute '/Users/zero_d_saber/.volta/tools/image/node/20.11.0/bin/node /Users/zero_d_saber/.…
│ node-pre-gyp ERR! stack     at ChildProcess.<anonymous> (/Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/@mapbox+node-pr…
│ node-pre-gyp ERR! stack     at ChildProcess.emit (node:events:518:28)
│ node-pre-gyp ERR! stack     at maybeClose (node:internal/child_process:1105:16)
│ node-pre-gyp ERR! stack     at ChildProcess._handle.onexit (node:internal/child_process:305:5)
│ node-pre-gyp ERR! System Darwin 23.2.0
│ node-pre-gyp ERR! command "/Users/zero_d_saber/.volta/tools/image/node/20.11.0/bin/node" "/Users/zero_d_saber/Dev/Tauri/solid-pnpm/n…
│ node-pre-gyp ERR! cwd /Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/node_modules/canvas
│ node-pre-gyp ERR! node -v v20.11.0
│ node-pre-gyp ERR! node-pre-gyp -v v1.0.11
│ node-pre-gyp ERR! not ok 
│ Failed to execute '/Users/zero_d_saber/.volta/tools/image/node/20.11.0/bin/node /Users/zero_d_saber/.volta/tools/image/packages/pnpm…
└─ Failed in 1.7s at /Users/zero_d_saber/Dev/Tauri/solid-pnpm/node_modules/.pnpm/canvas@2.11.2_encoding@0.1.13/node_modules/canvas
 ELIFECYCLE  Command failed with exit code 1.
``` 

#####  解决方案

```bash
❯ brew install pkg-config cairo pango libpng jpeg giflib librsvg pixman #node-canvas的依赖
❯ pip install setuptools
```

### yarn4 module找不到

![](/images/h5/cannot_find_module.webp "yarn4 node_modules")

#### 解决方案

```bash
yarn config set nodeLinker node-modules
``` 


