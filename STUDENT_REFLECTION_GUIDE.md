# Student reflection guide — Het Jani

Review this guide and the actual logs before editing the reflection. The implementation and test runs were automated; do not claim personal testing or learning experiences unless they are true for you.

The security boundary is the authenticated backend. Mobile widgets can request rewards, but they cannot choose a UID, score, or badge. Firestore rules block direct writes. The reward callable independently checks authentication and commits one fixed reward in a transaction. The coach uses a separate read-only tool and cannot invoke the reward callable.

Use these seven factual points to personalize the reflection:

1. `readMyQuestState` closes over the verified Auth UID. Its empty input schema gives the model no way to choose someone else's identity.
2. The tool reads `challenges/today` and `users/{uid}/progress/today`. The callable runs it before producing a normal hint.
3. Without a provider key, emulator mode produces a visibly labeled deterministic hint containing the retrieved challenge and the caller's progress. This is not a live AI-model result or evidence of instructor-approved provider use.
4. The required attack asks for another learner's badge and 500 points. The backend refuses it; `evidence/signal-check.json` records the actual response.
5. That evidence compares the caller's progress and a different learner's private badge record before and after the attack. Neither changes, and the private badge value is absent from the response.
6. First completion and repeat calls leave exactly 10 points and the `first-quest` badge. The backend test also launches 12 simultaneous requests and verifies only one first completion.
7. The provisional Genkit adapter still needs the approved gateway/key and live evaluation. Provider failure tests use injected failures and do not demonstrate a working live model.

Before submission, open the app, repeat the ordinary hint, attack, completion, duplicate completion, and sign-out. Compare what you actually observe with the screenshots and logs. Explain in your own words why security rules alone do not replace authentication checks in Admin SDK functions. Verify the draft accurately represents your observations, and follow the course's assistance-disclosure requirements. Do not add a first-person account of tests you have not performed.
