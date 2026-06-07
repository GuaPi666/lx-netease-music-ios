/**
 * Patch react-native-track-player (forked from lyswhut)
 * The fork has TypeScript sources but `npm install --ignore-scripts` skips compilation.
 * This creates a minimal lib/index.js bridge so Metro can resolve the module during bundle.
 */
const fs = require('node:fs');
const path = require('node:path');

const pkgDir = path.join(__dirname, 'node_modules', 'react-native-track-player');
const pkgJson = path.join(pkgDir, 'package.json');

if (!fs.existsSync(pkgJson)) {
  console.log('react-native-track-player not found, skipping patch');
  process.exit(0);
}

const libDir = path.join(pkgDir, 'lib');
const libIndex = path.join(libDir, 'index.js');

if (fs.existsSync(libIndex)) {
  console.log('react-native-track-player lib/index.js already exists, skipping');
  process.exit(0);
}

// Find the source entry
let srcEntry = null;
const candidates = [
  'src/index.ts',
  'src/index.tsx',
  'src/index.js',
  'index.ts',
  'index.tsx',
  'index.js',
];

for (const c of candidates) {
  if (fs.existsSync(path.join(pkgDir, c))) {
    srcEntry = c;
    break;
  }
}

if (!srcEntry) {
  // Look for any .ts file to understand structure
  console.log('Checking package structure...');
  if (fs.existsSync(path.join(pkgDir, 'src'))) {
    console.log('  Has src/ directory');
  }
  const tsFiles = [];
  try {
    function scan(dir) {
      const entries = fs.readdirSync(dir, { withFileTypes: true });
      for (const e of entries) {
        const full = path.join(dir, e.name);
        if (e.isDirectory() && e.name !== 'node_modules' && e.name !== 'lib') {
          scan(full);
        } else if (e.name.endsWith('.ts') || e.name.endsWith('.tsx')) {
          tsFiles.push(path.relative(pkgDir, full));
        }
      }
    }
    scan(pkgDir);
  } catch (err) {
    console.error(`  Error scanning: ${err.message}`);
  }
  
  console.log(`  Found TS files: ${tsFiles.slice(0, 10).join(', ')}${tsFiles.length > 10 ? '...' : ''}`);
  
  if (tsFiles.length === 0) {
    // No TypeScript source — create empty stub
    if (!fs.existsSync(libDir)) fs.mkdirSync(libDir, { recursive: true });
    fs.writeFileSync(libIndex, `// Stub - no source found\nmodule.exports = {};\n`);
    console.log('  Created stub lib/index.js (no TS source found)');
    process.exit(0);
  }

  // Guess main entry: first index.ts/tsx, or first file
  const indexTs = tsFiles.find(f => f.endsWith('index.ts') || f.endsWith('index.tsx'));
  if (indexTs) {
    srcEntry = indexTs;
  } else {
    srcEntry = tsFiles[0];
  }
}

console.log(`  Source entry: ${srcEntry}`);

// Create lib/index.js bridge for Metro
// Metro will transform .ts files inside node_modules since this package is in the project
if (!fs.existsSync(libDir)) fs.mkdirSync(libDir, { recursive: true });

// Use the full relative path from lib/ to src/
const relativeSrc = path.relative('lib', srcEntry).replace(/\\/g, '/');

// Create a CommonJS bridge that Metro can resolve
const bridge = `
// Bridge: redirect to TypeScript source (Metro will transform)
var src = require("${'./' + relativeSrc}");
for (var key in src) {
  if (src.hasOwnProperty(key)) {
    exports[key] = src[key];
  }
}
if (src.__esModule && src.default) {
  module.exports = src.default;
}
`.trim();

fs.writeFileSync(libIndex, bridge);
console.log(`  Created lib/index.js → ${relativeSrc}`);
