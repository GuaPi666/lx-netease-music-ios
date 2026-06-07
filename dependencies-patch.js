// 修补依赖源码以使构建的依赖恢复正常工作（Android + iOS）
// iOS: 为缺少 iOS 支持的 package 生成 stub podspec

const fs = require('node:fs')
const path = require('node:path')

const rootPath = path.join(__dirname, './')
const iosStubsDir = path.join(__dirname, 'ios', 'LxMusic', 'Libraries')

// 为没有 iOS podspec 的 package 创建 stub，使 pod install 不报错
// 这些 stub 提供空的 .h/.m 文件和一个指向该目录的 podspec
const iosStubPackages = [
  {
    name: 'react-native-file-system',
    podName: 'RNFileSystem',
    // This is an Android-only native module; provide empty stub
    header: `
#import <React/RCTBridgeModule.h>
@interface RNFileSystem : NSObject <RCTBridgeModule>
@end
`,
    impl: `
#import "RNFileSystem.h"
@implementation RNFileSystem
RCT_EXPORT_MODULE();
@end
`,
  },
  {
    name: 'react-native-local-media-metadata',
    podName: 'RNLocalMediaMetadata',
    header: `
#import <React/RCTBridgeModule.h>
@interface RNLocalMediaMetadata : NSObject <RCTBridgeModule>
@end
`,
    impl: `
#import "RNLocalMediaMetadata.h"
@implementation RNLocalMediaMetadata
RCT_EXPORT_MODULE();
@end
`,
  },
]

async function ensureStubPodspecs() {
  if (!fs.existsSync(iosStubsDir)) {
    fs.mkdirSync(iosStubsDir, { recursive: true })
  }

  for (const pkg of iosStubPackages) {
    const headerFile = path.join(iosStubsDir, `${pkg.podName}.h`)
    const implFile = path.join(iosStubsDir, `${pkg.podName}.m`)
    const podspecFile = path.join(iosStubsDir, `${pkg.podName}.podspec`)

    // Create .h
    if (!fs.existsSync(headerFile)) {
      fs.writeFileSync(headerFile, pkg.header.trimStart())
      console.log(`Created: ios/LxMusic/Libraries/${pkg.podName}.h`)
    }

    // Create .m
    if (!fs.existsSync(implFile)) {
      fs.writeFileSync(implFile, pkg.impl.trimStart())
      console.log(`Created: ios/LxMusic/Libraries/${pkg.podName}.m`)
    }

    // Create podspec
    if (!fs.existsSync(podspecFile)) {
      const podspec = `
Pod::Spec.new do |s|
  s.name         = "${pkg.podName}"
  s.version      = "1.0.0"
  s.summary      = "iOS stub for ${pkg.name}"
  s.homepage     = "https://github.com"
  s.license      = "MIT"
  s.author       = { "author" => "author@example.com" }
  s.platform     = :ios, "13.0"
  s.source       = { :git => "https://github.com", :tag => "v1.0.0" }
  s.source_files = "**/*.{h,m}"
  s.dependency   "React-Core"
end
`.trimStart()
      fs.writeFileSync(podspecFile, podspec)
      console.log(`Created: ios/LxMusic/Libraries/${pkg.podName}.podspec`)
    }

    // Also try to create a symlink or copy into node_modules so auto-linking picks it up
    const nodePkgDir = path.join(__dirname, 'node_modules', pkg.name)
    if (fs.existsSync(nodePkgDir)) {
      const nodePodsDir = path.join(nodePkgDir, 'ios')
      const nodePodspec = path.join(nodePodsDir, `${pkg.podName}.podspec`)
      if (!fs.existsSync(nodePodspec)) {
        if (!fs.existsSync(nodePodsDir)) {
          fs.mkdirSync(nodePodsDir, { recursive: true })
        }
        // Copy files from stubs to the package's ios/ dir
        fs.copyFileSync(headerFile, path.join(nodePodsDir, `${pkg.podName}.h`))
        fs.copyFileSync(implFile, path.join(nodePodsDir, `${pkg.podName}.m`))
        fs.copyFileSync(podspecFile, nodePodspec)
        console.log(`Copied stub podspec to node_modules/${pkg.name}/ios/`)
      }
    }
  }
}

;(async () => {
  console.log('\n=== Dependencies Patch (iOS) ===\n')
  await ensureStubPodspecs()

  // ====== Source-code patches (from original) ======
  const patchs = []

  for (const [filePath, fromStr, toStr] of patchs) {
    console.log(`Patching ${filePath.replace(rootPath, '')}`)
    try {
      const file = (await fs.promises.readFile(filePath)).toString()
      await fs.promises.writeFile(filePath, file.replace(fromStr, toStr))
    } catch (err) {
      console.error(`Patch ${filePath.replace(rootPath, '')} failed: ${err.message}`)
    }
  }

  console.log('\nDependencies patch finished.\n')
})()
