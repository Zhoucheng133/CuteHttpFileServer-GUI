# chfs 图形化版本

## 关于这个软件

鉴于原始程序CuteHttpFileServer对于macOS和Linux平台没有对应的GUI界面，因此开发了这个软件

基于Flutter开发，支持所有的桌面平台，包括Windows、macOS和Linux

该软件可能存在一些问题，欢迎指正

## 使用方法

- 你仍需要下载对应的程序包，[点击这里](http://iscute.cn/chfs)跳转到chfs下载页，Mac系统请选择`chfs-mac-amd64`，Linux系统根据你系统来选择
- 打开本软件，选择程序和分享目录
- ❗️务必一定要在退出该软件前结束运行，软件本身可以在退出前检测是否在运行，但是在Mac端如果直接使用快捷键不会有任何提示
- ❗️务必一定选择官方的正确程序

## 如果你希望运行在Windows电脑上
注意，本程序主要为macOS系统设计，虽然可以在Windows系统上运行，但是因为系统因素运行可能出现问题，因此如果你需要运行在Windows系统上，你可以选择使用官方的GUI版本，或者进行如下操作修改程序

- 对于文件`windows\runner\main.cpp`

  添加如下的两行：

  ```cpp
  #include <bitsdojo_window_windows/bitsdojo_window_plugin.h>
  auto bdw = bitsdojo_window_configure(BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP);
  ```

- 对于文件`lib/main.dart`

  需要修改的代码位于733行：

  ```dart
  // 注意，这里如果是Windows系统，需要修改为chfs.exe
  if((tmp?.files.single.name).toString()!="chfs"){
    // 其它代码
  }
  ```

  修改为：

  ```dart
  // 注意，这里如果是Windows系统，需要修改为chfs.exe
  if((tmp?.files.single.name).toString()!="chfs.exe"){
    // 其它代码
  }
  ```

后续版本可能会修改这部分操作

## 已知的问题和缺陷
1. 无法判断用户是否选择了正确的程序【只能判断文件名称是否正确】
2. (Mac)如果运行中使用`快捷键`退出本软件则会导致程序一直在运行

上述问题因为本人能力问题暂时没有得到修复，欢迎大佬协助修复


【附】问题修复指南:  
使用Flutter基于Dart语言编写，本人开发环境：Dart版本`2.19.6`，Flutter版本`3.7.12`  
对于问题1，暂时没有找到合适的方式验证程序的合理性  
对于问题2，暂时没有找到合适的方式能判断程序在Mac平台退出

## 版本更新

- ### 1.1.1 (2023/5/6)

  - 增加打开链接按钮
  - 在推出软件时可以检测是否在运行（Mac平台使用快捷键不适用）

- ### 1.1.0 (2023/5/5)

  - 可以设置是否记住上一次的输入
  - 增加查看ip地址的功能
  - 可以复制ip地址

- ### 1.0.1 (2023/5/3)
  
  - 实现release后可用
  - 根据不同的系统可以选择不同的执行文件
  
- ### 1.0.0 (2023/5/2)
  
  - 正式发布

## 各种依赖

- `bitsdojo_window` 用于控制窗口大小位置和边框透明
- `file_picker` 用于实现文件和目录选择
- `process_run` 用于实现终端中运行命令
- `shared_preferences` 用于保存设置
- `url_launcher` 用于打开链接
- `window_manager` 用于在关闭窗口时判断程序是否在运行