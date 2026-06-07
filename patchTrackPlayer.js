/**
 * Patch react-native-track-player (forked from lyswhut)
 * The fork has TypeScript sources but `npm install --ignore-scripts` skips compilation.
 * This patch ensures Metro bundler can resolve react-native-track-player during bundle.
 */
const fs = require('node:fs');
const path = require('node:path');

const pkgDir = path.join(__dirname, 'node_modules', 'react-native-track-player');

if (!fs.existsSync(pkgDir)) {
  console.log('[track-player] not found, skipping');
  process.exit(0);
}

const libDir = path.join(pkgDir, 'lib');
const libIndex = path.join(libDir, 'index.js');

if (fs.existsSync(libIndex)) {
  console.log('[track-player] lib/index.js exists, skipping');
  process.exit(0);
}

console.log('[track-player] creating lib/index.js stub for Metro bundler...');

if (!fs.existsSync(libDir)) fs.mkdirSync(libDir, { recursive: true });

// Comprehensive stub matching the react-native-track-player API surface
// All native methods are called through NativeModules at runtime - these stubs
// provide the correct function signatures for Metro to resolve the bundle.
const stub = `
// Auto-generated stub for Metro bundler
// Native methods resolve through NativeModules at runtime

var TrackPlayer = {
  // Setup
  setupPlayer: function(opts) { return Promise.resolve(); },
  destroy: function() { return Promise.resolve(); },
  registerPlaybackService: function(factory) { return factory(); },
  updateOptions: function(opts) { return Promise.resolve(); },

  // Queue management
  add: function(tracks, insertBeforeIndex) { return Promise.resolve(); },
  remove: function(trackIds) { return Promise.resolve(); },
  skip: function(trackId) { return Promise.resolve(); },
  getQueue: function() { return Promise.resolve([]); },
  removeUpcomingTracks: function() { return Promise.resolve(); },

  // Playback control
  reset: function() { return Promise.resolve(); },
  play: function() { return Promise.resolve(); },
  pause: function() { return Promise.resolve(); },
  stop: function() { return Promise.resolve(); },
  seekTo: function(position) { return Promise.resolve(); },
  skipToNext: function() { return Promise.resolve(); },
  skipToPrevious: function() { return Promise.resolve(); },

  // State
  getState: function() { return Promise.resolve(0); },
  getTrack: function(trackId) { return Promise.resolve(null); },
  getCurrentTrack: function() { return Promise.resolve(null); },
  getCurrentTrackId: function() { return Promise.resolve(null); },
  getPosition: function() { return Promise.resolve(0); },
  getBufferedPosition: function() { return Promise.resolve(0); },
  getDuration: function() { return Promise.resolve(0); },
  getRate: function() { return Promise.resolve(1); },
  getVolume: function() { return Promise.resolve(1); },

  // Metadata
  updateMetadataForTrack: function(trackId, metadata) { return Promise.resolve(); },

  // Volume
  setVolume: function(volume) { return Promise.resolve(); },

  // Rate
  setRate: function(rate) { return Promise.resolve(); },

  // Repeat mode
  setRepeatMode: function(mode) { return Promise.resolve(); },
  getRepeatMode: function() { return Promise.resolve(0); },

  // Events
  addEventListener: function(event, handler) {
    // No-op in stub
    return { remove: function() {} };
  },
  removeEventListener: function(event, handler) {},
};

// State enum
var State = {
  None: 0,
  Ready: 1,
  Playing: 2,
  Paused: 3,
  Stopped: 4,
  Buffering: 5,
  Connecting: 6,
};

// Event enum
var Event = {
  PlaybackState: 'playback-state',
  PlaybackError: 'playback-error',
  PlaybackTrackChanged: 'playback-track-changed',
  PlaybackQueueEnded: 'playback-queue-ended',
  RemotePlay: 'remote-play',
  RemotePause: 'remote-pause',
  RemoteStop: 'remote-stop',
  RemoteNext: 'remote-next',
  RemotePrevious: 'remote-previous',
  RemoteJumpForward: 'remote-jump-forward',
  RemoteJumpBackward: 'remote-jump-backward',
  RemoteSeek: 'remote-seek',
  RemoteDuck: 'remote-duck',
  RemoteVolume: 'remote-volume',
  RemoteVolumeUp: 'remote-volume-up',
  RemoteVolumeDown: 'remote-volume-down',
};

// RepeatMode enum
var RepeatMode = {
  Off: 0,
  Track: 1,
  Queue: 2,
};

// Capability enum
var Capability = {
  Play: 0,
  Pause: 1,
  Stop: 2,
  SkipToNext: 3,
  SkipToPrevious: 4,
  Seek: 5,
};

module.exports = TrackPlayer;
module.exports.default = TrackPlayer;
module.exports.State = State;
module.exports.Event = Event;
module.exports.RepeatMode = RepeatMode;
module.exports.Capability = Capability;
`;

fs.writeFileSync(libIndex, stub.trimStart());
console.log('[track-player] lib/index.js created');
