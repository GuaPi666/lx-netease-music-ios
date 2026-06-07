module.exports = {
  project: {
    ios: {
      sourceDir: './ios',
      automaticPodsInstallation: false,
    },
  },
  assets: [
    './src/resources/fonts',
  ],
  dependencies: {
    'react-native-navigation': {
      platforms: {
        android: null,
        ios: null,
      },
    },
    'react-native-file-system': {
      platforms: {
        ios: null,
      },
    },
    'react-native-local-media-metadata': {
      platforms: {
        ios: null,
      },
    },
  },
}
