import { AppState, NativeEventEmitter, NativeModules } from 'react-native'

const { UtilsModule } = NativeModules

// Safe wrapper: native modules may not be available at import time
const U = (UtilsModule || {}) as any

export const exitApp = U.exitApp || (() => { console.warn('exitApp not available') })

export const getSupportedAbis = U.getSupportedAbis || (() => Promise.resolve(['arm64']))

export const installApk = (filePath: string, fileProviderAuthority: string) =>
  U.installApk ? U.installApk(filePath, fileProviderAuthority) : Promise.reject(new Error('Not available on iOS'))

export const screenkeepAwake = () => {
  if (global.lx.isScreenKeepAwake) return
  global.lx.isScreenKeepAwake = true
  if (U.screenkeepAwake) U.screenkeepAwake()
}
export const screenUnkeepAwake = () => {
  if (!global.lx.isScreenKeepAwake) return
  global.lx.isScreenKeepAwake = false
  if (U.screenUnkeepAwake) U.screenUnkeepAwake()
}

export const getWIFIIPV4Address = (U.getWIFIIPV4Address || (() => Promise.resolve('127.0.0.1'))) as () => Promise<string>

export const getDeviceName = async (): Promise<string> => {
  if (!U.getDeviceName) return 'iPhone'
  return U.getDeviceName().then((deviceName: string) => deviceName || 'Unknown')
}

export const isNotificationsEnabled = (U.isNotificationsEnabled || (() => Promise.resolve(false))) as () => Promise<boolean>

export const requestNotificationPermission = async () =>
  new Promise<boolean>((resolve) => {
    let subscription = AppState.addEventListener('change', (state) => {
      if (state != 'active') return
      subscription.remove()
      setTimeout(() => {
        void isNotificationsEnabled().then(resolve)
      }, 1000)
    })
    if (U.openNotificationPermissionActivity) {
      U.openNotificationPermissionActivity().then((result: boolean) => {
        if (result) return
        subscription.remove()
        resolve(false)
      })
    } else {
      resolve(true)
    }
  })

export const shareText = async (shareTitle: string, title: string, text: string): Promise<void> => {
  if (U.shareText) U.shareText(shareTitle, title, text)
}

export const getSystemLocales = async (): Promise<string> => {
  if (U.getSystemLocales) return U.getSystemLocales()
  return 'zh-CN'
}

export const onScreenStateChange = (handler: (state: 'ON' | 'OFF') => void): (() => void) => {
  if (!U || !UtilsModule) return () => {}
  const eventEmitter = new NativeEventEmitter(UtilsModule)
  const eventListener = eventEmitter.addListener('screen-state', (event) => {
    handler(event.state as 'ON' | 'OFF')
  })
  return () => { eventListener.remove() }
}

export const onMediaVolumeChange = (
  handler: (event: { volume: number; prevVolume: number; maxVolume: number }) => void
): (() => void) => {
  if (!U || !UtilsModule) return () => {}
  const eventEmitter = new NativeEventEmitter(UtilsModule)
  const eventListener = eventEmitter.addListener('media-volume-changed', (event) => {
    handler(event as { volume: number; prevVolume: number; maxVolume: number })
  })
  return () => { eventListener.remove() }
}

export const getWindowSize = async (): Promise<{ width: number; height: number }> => {
  if (U.getWindowSize) return U.getWindowSize()
  return { width: 393, height: 852 }
}

export const onWindowSizeChange = (
  handler: (size: { width: number; height: number }) => void
): (() => void) => {
  if (!U || !UtilsModule) return () => {}
  if (U.listenWindowSizeChanged) U.listenWindowSizeChanged()
  const eventEmitter = new NativeEventEmitter(UtilsModule)
  const eventListener = eventEmitter.addListener('screen-size-changed', (event) => {
    handler(event as { width: number; height: number })
  })
  return () => { eventListener.remove() }
}

export const isIgnoringBatteryOptimization = async (): Promise<boolean> => {
  if (U.isIgnoringBatteryOptimization) return U.isIgnoringBatteryOptimization()
  return true
}

export const requestIgnoreBatteryOptimization = async () =>
  new Promise<boolean>((resolve) => {
    let subscription = AppState.addEventListener('change', (state) => {
      if (state != 'active') return
      subscription.remove()
      setTimeout(() => {
        void isIgnoringBatteryOptimization().then(resolve)
      }, 1000)
    })
    if (U.requestIgnoreBatteryOptimization) {
      U.requestIgnoreBatteryOptimization().then((result: boolean) => {
        if (result) return
        subscription.remove()
        resolve(false)
      })
    } else {
      resolve(true)
    }
  })

export const getUiMode = (U.getUiMode || (() => Promise.resolve(1))) as () => Promise<number>

export const adjustSystemMediaVolume = (direction: 'up' | 'down'): Promise<void> =>
  U.adjustSystemMediaVolume ? U.adjustSystemMediaVolume(direction) : Promise.resolve()
