/**
 * @format
 */
import { AppRegistry } from 'react-native'
import './shim'

console.error('=== CRASH TEST: index.js started ===')

// Simple vanilla RN entry point as safety net
const EmptyView = () => null
AppRegistry.registerComponent('LxMusic', () => EmptyView)

try {
  const app = require('./src/app')
  console.error('=== src/app loaded OK ===', typeof app)
} catch (e) {
  console.error('=== FATAL: app load failed ===', e.message)
}
