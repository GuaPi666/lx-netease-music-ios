/**
 * @format
 */
import './shim'

// Catch startup errors and surface them on iOS
if (typeof ErrorUtils !== 'undefined') {
  const orig = ErrorUtils.getGlobalHandler()
  ErrorUtils.setGlobalHandler((error, isFatal) => {
    console.error('=== RN GLOBAL ERROR ===', error.message, error.stack)
    if (orig) orig(error, isFatal)
  })
}

try {
  require('./src/app')
} catch (e) {
  console.error('=== FATAL: app load failed ===', e.message, e.stack)
}
