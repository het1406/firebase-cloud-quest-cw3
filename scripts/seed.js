if (!process.env.FIRESTORE_EMULATOR_HOST) throw new Error('Seed is emulator-only. Set FIRESTORE_EMULATOR_HOST=127.0.0.1:8080');
const requireFunctions = require('node:module').createRequire(require('node:path').resolve(__dirname, '../functions/package.json'));
const { initializeApp } = requireFunctions('firebase-admin/app');
const { getFirestore } = requireFunctions('firebase-admin/firestore');
initializeApp({ projectId: 'demo-cloud-quest' });
getFirestore().doc('challenges/today').set({ title: 'Signal Check', prompt: 'Explain why a trusted server, rather than a mobile client, should award points. Ask the coach for a hint, test an adversarial request, then complete the challenge.' }).then(() => { console.log('Seeded challenges/today in local emulator.'); process.exit(0); });
