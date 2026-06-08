import { NativeModules, NativeEventEmitter } from 'react-native'

const { MusicWidgetModule } = NativeModules
const M = (MusicWidgetModule || {}) as any

const widgetEmitter = MusicWidgetModule ? new NativeEventEmitter(MusicWidgetModule) : null

export const updateWidget = async (
    title: string,
    artist: string,
    isPlaying: boolean,
    artworkUrl?: string,
): Promise<void> => {
  if (M.updateWidget) return M.updateWidget(title, artist, isPlaying, artworkUrl ?? '')
}

export const onWidgetPlayPause = (callback: () => void) => {
  if (widgetEmitter) return widgetEmitter.addListener('widget-play-pause', callback)
  return { remove: () => {} }
}

export const onWidgetPrev = (callback: () => void) => {
  if (widgetEmitter) return widgetEmitter.addListener('widget-prev', callback)
  return { remove: () => {} }
}

export const onWidgetNext = (callback: () => void) => {
  if (widgetEmitter) return widgetEmitter.addListener('widget-next', callback)
  return { remove: () => {} }
}
