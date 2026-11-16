# CW3 — Firebase Cloud Quest: Signal Check

**Student / Project Owner / Submitted By:** Het Jani

**Course:** CSC 4360 — Mobile App Development

**Assignment:** Firebase Cloud Quest — Version 2: Signal Check

**Pathway:** Undergraduate · Individual Coursework

**Deadline:** November 15, 2026, 11:59 PM EST

**Repository:** https://github.com/het1406/firebase-cloud-quest-cw3 (public)

## Verified behavior

This application was created from a fresh Flutter project. It implements Material 3 registration, sign-in, sign-out, Auth-state routing, a shared daily challenge, private progress, a coach, and an explicit completion button. Responsive scrolling, loading/error states, validation, and retry controls are included.

The coach now has real provider evidence: `evidence/live-signal-check.json` records two authenticated callable requests using Genkit and `googleai/gemini-3.5-flash-lite`, with two synthetic learner accounts. Both responses have `source: genkit`; the recorded sequence starts with `readMyQuestState`, followed by `generate`. The ordinary hint references the stored challenge and zero points. The attack explicitly refuses private-data access and reward changes. Both learners' records remain unchanged.

The original official assignment sheet, detailed rubric descriptors, and provider-approval clarification were not supplied or found in the workspace. The audit uses the user's supplied requirements and seven rubric weights. Gemini has not been represented as instructor-approved.

## Architecture and trust boundaries

- `lib/main.dart`: Firebase Auth state routing and protected challenge/coach UI. The protected widget and controllers are disposed on sign-out.
- `lib/quest_callable.dart`: authenticated callable HTTP protocol for local emulators, avoiding Android's optional production Installations token lookup for demo projects. Cloud mode uses the Firebase Functions SDK.
- `challenges/today`: shared title and prompt, readable only after authentication.
- `users/{uid}/progress/today`: owner-only progress with `completed`, `points`, `badgeId`, and server-generated `completedAt`.
- `functions/src/core.js`: validates authentication and `challengeId: today`; derives UID from verified Auth; ignores client UID, points, and badge fields. A Firestore transaction awards exactly 10 points and `first-quest` once. Retries return `alreadyCompleted` without updating the reward or timestamp.
- `functions/src/index.js`: authenticates coach requests, validates 1–300 characters, and defines a request-local `readMyQuestState` Genkit tool with an empty strict input schema. The UID is bound by the backend, not supplied by the model. The tool is invoked before generation. Its only operations are reads.
- `functions/src/model.js`: configurable Genkit model, concise grounded instructions, and sanitized provider failures. The model receives only the read-only tool; it cannot invoke `completeToday`. `audit.steps` records execution order without credentials.
- `firestore.rules`: authenticated challenge reads, owner-only progress reads, and no client writes. Admin SDK authorization is separately enforced in the callables.

When a server-side key exists, both ordinary and adversarial requests reach the real model. Without a key, emulator mode offers a visibly labeled deterministic fallback and safety refusal. Server-controlled `QUEST_COACH_MODE=mock` forces this path only inside emulators. Production cannot activate the emulator fallback. `QUEST_EMULATOR_FALLBACK=false` disables fallback. Provider failures return `unavailable` without private error details.

## Setup and run

Use Flutter/Dart, Android SDK/JDK, Java 21 or newer, Node (22 recommended), npm, and Python 3.11+. Lockfiles pin resolved dependencies. Local verification used Node 24; the deployment target is Node 22. Selected mobile target: Pixel 4a Android emulator. iOS scaffolding exists but Xcode/CocoaPods are incomplete on this machine.

```sh
flutter pub get
npm ci
npm --prefix functions ci
cp -n functions/emulator-secret.example functions/.secret.local
npm run emulators
```

In another terminal:

```sh
FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm run seed
flutter run -d emulator-5554
```

The default project is `demo-cloud-quest`, using Android's host alias `10.0.2.2`. For another reachable emulator host, pass `--dart-define=EMULATOR_HOST=<host>`. Debug Android builds permit local HTTP. The generated APK depends on these local services; it is not a standalone production backend.

## Secure provider configuration

Run this in your own terminal. The prompt hides input and writes only to the Git-ignored server file with owner-only permissions:

```sh
python3 scripts/set_model_key.py
```

Never paste keys into chat, source, screenshots, logs, or submission files. `functions/.secret.local` is excluded from Git and the ZIP. For deployed Functions, configure the secret interactively with `npx firebase functions:secrets:set GOOGLE_GENAI_API_KEY --project het-cw3-quest-20261115`.

The installed `@genkit-ai/google-genai` version is 1.44.0. The default model is `googleai/gemini-3.5-flash-lite`; change `QUEST_MODEL` in server environment configuration to use another compatible approved model. The GoogleAI plugin is the current provider adapter; another provider requires changing that adapter and repeating tests. Google lists a free API tier for this model, subject to account eligibility and quota. Instructor approval remains unconfirmed. References: [Genkit Google plugin](https://genkit.dev/docs/js/integrations/google-genai/), [Google pricing](https://ai.google.dev/gemini-api/docs/pricing#gemini-3.5-flash-lite).

## Tests and evidence

```sh
flutter analyze
flutter test
npm test
# With standard emulators running and a real local key:
npm run test:live
LIVE_COACH=true python3 scripts/device_test.py
```

`npm test` runs isolated mock emulators on Auth 9098, Firestore 8082, and Functions 5002 via `firebase.test.json`. It does not require or use the provider key. Standard interactive/live emulators use 9099/8080/5001.

- `evidence/flutter-analyze.txt`: latest analysis output.
- `evidence/flutter-tests.txt`: three validation/widget tests.
- `evidence/backend-tests.txt`: backend, rules, concurrency, model-failure fixtures, and tool-boundary checks; final totals appear in the log.
- `evidence/live-signal-check.json`: actual live responses, tool-order audit, and before/after data for two synthetic learners.
- `evidence/signal-check.json`: deterministic emulator results, explicitly separate from live evidence.
- `evidence/android-journey.txt`: prior passing deterministic Android journey.
- `evidence/android-live-journey.txt`: current live-provider Android journey result.
- `evidence/credential-scan.json`: Git-history credential scan. The final archive scan report is delivered alongside the ZIP.

Historical failure logs and the initial live wording-assertion failure are labeled separately. They are retained as genuine debugging evidence, not represented as passing checks.

## Cloud and submission status

New cloud project: `het-cw3-quest-20261115`. Firestore, rules, Android/iOS registrations, and the daily challenge were created. Cloud Authentication initialization remains incomplete; deployed Functions require Blaze billing, which was not enabled. Real-model verification currently uses local Firebase emulators, not deployed cloud Functions.

`config/firebase-cloud.json` contains public Android Firebase identifiers, not provider/server credentials. After completing cloud Auth and Functions deployment, use `flutter run --dart-define-from-file=config/firebase-cloud.json` and repeat the full cloud journey. iOS, web, and desktop execution are not verified.

The final source ZIP is in `../submission/CW3_Het_Jani_Submission.zip`. It excludes dependencies, build caches, `.git`, and local secrets. See `FINAL_SUBMISSION_AUDIT.md`, `RUBRIC_AUDIT.md`, `ENGAGEMENT_EVIDENCE.md`, `REFLECTION.md`, `STUDENT_REFLECTION_GUIDE.md`, and `SUBMISSION_CHECKLIST.md`. No iCollege upload or receipt is verified.
