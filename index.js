/**
 * @format
 */
import './shim'

console.log('=== index.js STARTED ===')

console.log('=== Loading src/app ===')
try {
  require('./src/app')
  console.log('=== src/app loaded OK ===')
} catch (e) {
  console.error('=== FATAL: app load failed ===', e.message)
}
