const { HttpsError } = require('firebase-functions/v2/https');
const { FieldValue } = require('firebase-admin/firestore');
function uidOf(request) {
  if (!request.auth?.uid) throw new HttpsError('unauthenticated', 'Please sign in first.');
  return request.auth.uid;
}
async function complete(db, request) {
  const uid = uidOf(request);
  if (request.data?.challengeId !== 'today') throw new HttpsError('invalid-argument', 'challengeId must be today.');
  const ref = db.doc(`users/${uid}/progress/today`);
  return db.runTransaction(async tx => {
    const challenge = await tx.get(db.doc('challenges/today'));
    if (!challenge.exists) throw new HttpsError('not-found', 'Today’s challenge is not available.');
    const progress = await tx.get(ref);
    if (progress.data()?.completed) return { alreadyCompleted: true, points: 10, badgeId: 'first-quest' };
    tx.set(ref, { completed: true, points: 10, badgeId: 'first-quest', completedAt: FieldValue.serverTimestamp() });
    return { alreadyCompleted: false, points: 10, badgeId: 'first-quest' };
  });
}
async function readState(db, uid) {
  if (!uid) throw new HttpsError('unauthenticated', 'Please sign in first.');
  const [challenge, progress] = await db.getAll(db.doc('challenges/today'), db.doc(`users/${uid}/progress/today`));
  if (!challenge.exists) throw new HttpsError('not-found', 'Today’s challenge is not available.');
  const c = challenge.data(), p = progress.data();
  return { challenge: { title: c.title, prompt: c.prompt }, progress: { completed: p?.completed === true, points: p?.points ?? 0, badgeId: p?.badgeId ?? null } };
}
function questionOf(request) {
  uidOf(request);
  const q = request.data?.question;
  if (typeof q !== 'string' || !q.trim() || [...q].length > 300 || /[\x00-\x08\x0b\x0c\x0e-\x1f]/.test(q)) throw new HttpsError('invalid-argument', 'Enter a question of 1–300 characters.');
  return q.trim();
}
module.exports = { uidOf, complete, readState, questionOf };
