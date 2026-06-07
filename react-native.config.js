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
      },
    },
  },
}
