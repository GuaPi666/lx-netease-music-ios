/**
 * @format
 */
import './shim'

// Log IMMEDIATELY so we know JS started
console.log('=== index.js STARTED ===')

if (typeof ErrorUtils !== 'undefined') {
  console.log('=== ErrorUtils found, setting global handler ===')
  const orig = ErrorUtils.getGlobalHandler()
  ErrorUtils.setGlobalHandler((error, isFatal) => {
    console.error('=== GLOBAL ERROR ===', error.message)
    console.error('=== STACK ===', error.stack)
    if (orig) orig(error, isFatal)
  })
}

console.log('=== Loading src/app ===')
try {
  const app = require('./src/app')
  console.log('=== src/app loaded ===', typeof app)
} catch (e) {
  console.error('=== FATAL: app load failed ===')
  console.error(e.message)
  console.error(e.stack)
}
