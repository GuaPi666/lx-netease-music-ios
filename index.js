/**
 * @format
 */

// Minimal bootstrap to verify JS engine starts
console.error('=== JS ENGINE STARTED ===')

var React = require('react')
var RN = require('react-native')
var Buffer = require('@craftzdog/react-native-buffer').Buffer

console.error('=== MODULES OK ===')

// Register a minimal component
var EmptyView = function() { return React.createElement(RN.View, {style:{flex:1,backgroundColor:'black'}}) }
RN.AppRegistry.registerComponent('LxMusic', function() { return EmptyView })

console.error('=== REGISTERED OK ===')

// Try the real app
try {
  require('./src/app')
  console.error('=== src/app loaded OK ===')
} catch(e) {
  console.error('=== src/app FAILED: ' + e.message + ' ===')
  if (e.stack) console.error(e.stack)
}
