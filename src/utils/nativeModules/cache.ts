import { NativeModules } from 'react-native'

const { CacheModule } = NativeModules
const C = (CacheModule || {}) as any

export const getAppCacheSize = async (): Promise<number> =>
  C.getAppCacheSize ? C.getAppCacheSize().then((size: number) => Math.trunc(size)) : Promise.resolve(0)
export const clearAppCache = (C.clearAppCache || (() => Promise.resolve())) as () => Promise<void>
