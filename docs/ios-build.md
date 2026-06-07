# LX Music iOS 构建指南

## 概述

本项目原本仅支持 Android。本分支为项目添加了 iOS 支持，使用 **ldid 假签名**生成 IPA，**仅适用于越狱设备**。

## 项目结构 (iOS)

```
ios/
├── Podfile                              # CocoaPods 配置
├── LxMusic.xcodeproj/
│   └── project.pbxproj                  # Xcode 项目文件（由 generate-xcodeproj.js 生成）
├── LxMusic/
│   ├── AppDelegate.h / .mm              # 应用入口（集成 react-native-navigation）
│   ├── main.m                           # main 函数
│   ├── Info.plist                        # 应用配置（Bundle ID: com.lxmusic.ios）
│   ├── LaunchScreen.storyboard           # 启动屏
│   ├── Images.xcassets/                  # 应用图标
│   ├── UtilsModule.h / .m               # ⭐ 原生模块 Stub
│   ├── CacheModule.h / .m               # ⭐ 原生模块 Stub
│   ├── CryptoModule.h / .m              # ⭐ 原生模块 Stub
│   ├── LyricModule.h / .m               # ⭐ 原生模块 Stub
│   ├── MusicWidgetModule.h / .m         # ⭐ 原生模块 Stub
│   ├── UserApiModule.h / .m             # ⭐ 原生模块 Stub
│   └── Libraries/
│       ├── RNFileSystem.h / .m / .podspec     # Android-only 包的 iOS Stub
│       └── RNLocalMediaMetadata.h / .m / .podspec # Android-only 包的 iOS Stub
.github/workflows/
└── ios-build.yml                        # GitHub Actions 构建配置
build-ios.sh                             # 本地构建脚本
```

## 构建方式

### 方式一：GitHub Actions（推荐）

Push 到 `main` 或 `ios-*` 分支会自动触发 iOS 构建：

1. 在 GitHub 仓库 → **Actions** → **iOS Build (Unsigned/Fake-Signed)**
2. 点击 **Run workflow**，可手动触发或等自动触发
3. 构建完成后下载 `lx-music-ios-unsigned` artifact
4. 解压获得 `LxMusic-unsigned.ipa`

### 方式二：本地构建 (macOS)

```bash
# 需要有 macOS + Xcode 15+
chmod +x build-ios.sh
./build-ios.sh
```

输出在 `ios/build/LxMusic-unsigned.ipa`

## iOS 设备安装

### 越狱设备（推荐）

1. 将 `LxMusic-unsigned.ipa` 传到设备
2. 用 **Filza** 打开 → 选择 **AppSync Unified** 安装
3. 或用 **TrollStore** 安装

### 非越狱设备（需要替换签名方式）

将 `CODE_SIGNING_ALLOWED=NO` 替换为使用免费 Apple ID 签名：

```bash
# 使用 xcodebuild -allowProvisioningUpdates 或 fastlane sigh
xcodebuild ... \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=你的TeamID \
  -allowProvisioningUpdates
```

签名有效期 7 天。

## 已知限制

| 功能 | 状态 | 说明 |
|------|------|------|
| 音乐播放 | ✅ | 通过 react-native-track-player 支持 |
| 搜索 | ✅ | 全部搜索源支持 |
| 歌单管理 | ✅ | 完整支持 |
| 下载 | ✅ | 通过 react-native-fs 支持 |
| 通知栏控制 | ✅ | iOS 原生支持 |
| 后台播放 | ✅ | Info.plist 已配置 |
| 桌面歌词 | ❌ | iOS stub — 无实际浮动窗口 |
| 桌面组件 | ❌ | iOS stub — 未实现真正的 Widget Extension |
| 加密模块 | ⚠️ | Stub 实现，基本功能可用 |
| WebDAV 同步 | ✅ | JS 层实现 |
| 用户 API 脚本 | ❌ | iOS stub — 不支持 |
| APK 安装 | N/A | iOS 无此概念 |

## 贡献

如需为 iOS 添加真正的原生功能（如桌面歌词、小组件），需要：

1. 在 `ios/LxMusic/` 下创建相应的 Swift/ObjC 实现
2. 在 `ios/LxMusic.xcodeproj` 中添加文件引用
3. 更新 Info.plist 添加权限描述

## 技术细节

### react-native-navigation (v7)

本项目使用 `react-native-navigation` 替代默认的 React Native 导航。
AppDelegate 使用 RNN 的 `bootstrapWithDelegate:` 方法启动。

### 假签名原理

1. `CODE_SIGNING_ALLOWED=NO` 让 Xcode 跳过真正的签名步骤
2. `ldid -S` 注入一个简单的 code directory 到 Mach-O 二进制中
3. 越狱设备的 AppSync 允许安装任意签名的应用
