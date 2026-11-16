# CW3 — Firebase Cloud Quest: Signal Check

**Student:** Het Jani

**Submitted By:** Het Jani

**Project Owner:** Het Jani

**Submission By:** Het Jani

**Course:** CSC 4360 — Mobile App Development

**Assignment:** CW3 — Firebase Cloud Quest — Version 2: Signal Check

**Deadline:** November 15, 2026, 11:59 PM EST

**Pathway:** Undergraduate

**Submission Type:** Individual Coursework

**Project Type:** Individual Coursework

**Repository:** https://github.com/het1406/firebase-cloud-quest-cw3

Cloud Quest is a new Flutter application built from an empty workspace for CW3. Students sign in, read a shared challenge, ask a coach for help, and earn a fixed reward through a trusted server function. No previous coursework source was copied.

## Current status

The Firebase Emulator Suite verifies rewards, security rules, and a grounded deterministic hint. Per the updated assignment request, missing model credentials trigger an explicitly labeled emulator-only fallback that uses the real retrieved challenge and caller progress. **Live model generation remains unverified**: no model key or course-approved gateway has been supplied. The adversarial request receives a deterministic safety refusal. Neither fallback behavior nor injected provider-failure tests are presented as live AI tests.

The fresh cloud project is `het-cw3-quest-20261115`. Firestore and its rules are deployed, and `challenges/today` is seeded. Android and iOS Firebase apps are registered. Cloud Functions deployment is blocked by the Blaze billing requirement. Cloud Authentication still needs initialization in the Firebase console. No course-portal submission has occurred.

## Stack and architecture

Flutter/Dart, Material 3, Firebase Authentication, Firestore, callable Cloud Functions, Node.js 22 deployment target, and Genkit with a Google Gemini adapter. The emulator API key uses Firebase’s standard non-secret demo format. Package lockfiles record the exact installed dependencies. Local tests currently run Node 24; Firebase reports this difference. Android uses Kotlin 2.4.21 to match the installed Firebase SDK metadata.

`lib/quest_callable.dart` uses the authenticated HTTP callable protocol for emulators to avoid an optional Android Firebase Installations/FCM token request against production. It sends the signed-in user’s ID token; Firebase still verifies identity and all authorization remains in the backend. Cloud mode uses the Flutter Functions SDK.

`lib/main.dart` uses `FirebaseAuth.instance.authStateChanges()` to route between authentication and protected screens. Registration and sign-in validate inputs and show loading/error states. Progress streams are scoped to the signed-in UID. Signing out disposes the protected screen, its question, hint, and subscriptions. Emulator persistence is disabled.

Firestore documents:

- `challenges/today`: shared `title` and `prompt`; authenticated reads only.
- `users/{uid}/progress/today`: private `completed`, `points`, `badgeId`, and server-generated `completedAt`.

`completeToday` authenticates the caller, requires `challengeId: "today"`, checks the challenge exists, and runs a Firestore transaction. It derives the UID from verified authentication and ignores submitted points, badge IDs, and UIDs. A first completion stores exactly 10 points and `first-quest`; repeat calls return `alreadyCompleted: true` without changing the document or timestamp. Transactions serialize concurrent reward attempts.

`askQuestCoach` authenticates and validates 1–300-character questions. Each request creates a Genkit `readMyQuestState` tool that closes over the verified UID and accepts no identity argument. The callable invokes this tool before generating a hint and exposes it as the model's only tool. The tool returns only the challenge and caller's progress, never credentials. No write or reward tool is available. The explicit Signal Check pattern is refused before model generation. Outside emulator fallback mode, missing configuration and generation errors return `unavailable`. The fallback is restricted to `FUNCTIONS_EMULATOR=true` and can be disabled with `QUEST_EMULATOR_FALLBACK=false`. Provider-failure tests verify that private error details are not returned. A model response remains untrusted text; broader prompt-injection resistance and live model grounding need provider-backed evaluation.

`firestore.rules` denies all client writes, anonymous reads, and reads of another user's progress. Admin SDK writes are outside those rules, so callable authentication and transaction logic form the trusted reward boundary.

## Run locally

Install Flutter, Android SDK/JDK, Node.js (22 recommended), npm, and Java 21 or later for emulators. Add Flutter to PATH. On the development machine the SDK is `/Users/hetjani/develop/flutter`.

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

The default configuration deliberately connects to `demo-cloud-quest` emulators at Android's host alias `10.0.2.2`. For a physical device, pass `--dart-define=EMULATOR_HOST=<reachable-host>` and configure emulator listening/network access. For web, pass `--dart-define=EMULATOR_HOST=127.0.0.1`; browser operation is not verified. Never use demo configuration as a production deployment.

## Coach configuration

Confirm the course-approved provider first. The implemented adapter uses Genkit's `@genkit-ai/google-genai`, with `QUEST_MODEL` defaulting to `googleai/gemini-2.5-flash`. A different gateway requires an adapter change and new tests. Put the approved key in ignored `functions/.secret.local` for emulator use:

```text
GOOGLE_GENAI_API_KEY=<your key, entered locally>
```

Do not commit this file. For deployment use Firebase Secret Manager:

```sh
npx firebase functions:secrets:set GOOGLE_GENAI_API_KEY --project het-cw3-quest-20261115
```

No real key was created, obtained, or committed. Repeat the ordinary hint and adversarial tests with the live model before claiming live AI completion. The current device test intentionally expects the labeled deterministic emulator fallback; use a separate provider-backed assertion when configuring the approved gateway.

## Finish cloud setup

1. Open the new [Firebase project](https://console.firebase.google.com/project/het-cw3-quest-20261115/overview), initialize Authentication, and enable Email/Password.
2. Decide whether to enable Blaze billing. This is required before deploying Functions; it was not enabled during this work.
3. Configure the approved model secret, then run `npx firebase deploy --only functions --project het-cw3-quest-20261115`.
4. Run Android with `flutter run --dart-define-from-file=config/firebase-cloud.json` and repeat the complete journey against cloud services.

`config/firebase-cloud.json` contains public Android Firebase client identifiers, not server credentials. Native client registration files are also included. Initialization uses explicit Dart options; the Android Google Services Gradle plugin is intentionally unnecessary. iOS cloud running requires its own app ID/configuration and working Xcode/CocoaPods. FlutterFire registration was attempted, but full iOS configuration stopped at a missing Ruby `xcodeproj` dependency.

## Verification and evidence

```sh
flutter analyze
flutter test
npm test
# Android emulator must already be booted; no model key for this test:
npx firebase emulators:exec --project demo-cloud-quest --only auth,firestore,functions 'node scripts/seed.js && python3 scripts/device_test.py'
```

- Standalone Android debug APK builds successfully (`evidence/android-build.txt`); generated APK: `build/app/outputs/flutter-apk/app-debug.apk`.
- Flutter static analysis: clean (`evidence/flutter-analyze.txt`).
- Flutter validation/widget tests: 3 passed (`evidence/flutter-tests.txt`).
- Backend/rules/callable/provider-failure tests: 15 passed (`evidence/backend-tests.txt`). Tests cover first/repeated/concurrent completion, manipulation, authentication, malformed questions, authorized reads, denied writes and cross-user reads, and callable Signal Check.
- `evidence/signal-check.json` contains real ordinary/adversarial responses and before/after reward state. The ordinary response is labeled `emulator-fallback`; this is grounded local behavior, not a successful live-model test.
- Android Pixel 4a emulator: 1 integration journey passed, including registration, sign-in, sign-out, grounded fallback, Signal Check, first reward, and duplicate completion. See `evidence/android-journey.txt` and seven current screenshots in `evidence/README.md`.
- `evidence/cloud-rules-deploy.txt` and `evidence/cloud-challenge-seed.txt` record successful cloud work. `evidence/cloud-functions-deploy.txt` records the billing blocker.

Test execution was automated during implementation. Het Jani must review the results, repeat the personal demonstration, and follow the course's assistance-disclosure requirements. No personal observations or earlier development history are invented.

## Submission package

The source archive is `../CW3_Het_Jani_Submission.zip`. It includes the committed source, tests, documentation, and evidence under `firebase_cloud_quest_cw3/`. Dependencies, private local configuration, and build caches are excluded. The standalone debug APK remains at `build/app/outputs/flutter-apk/app-debug.apk`.

## Limitations

Live AI generation and professor approval of the provisional provider, cloud Authentication, deployed callable functions, and full cloud operation remain unverified. iOS cannot be built with the current incomplete Xcode/CocoaPods environment. The daily document is a fixed coursework challenge, not a date-rotation system. Production hardening could add App Check and server-side quotas. This repository is private; grant the instructor access before submitting its URL.

See [REFLECTION.md](REFLECTION.md), [STUDENT_REFLECTION_GUIDE.md](STUDENT_REFLECTION_GUIDE.md), [RUBRIC_AUDIT.md](RUBRIC_AUDIT.md), and [SUBMISSION_CHECKLIST.md](SUBMISSION_CHECKLIST.md).

Implementation references: [Firebase callable functions](https://firebase.google.com/docs/functions/callable), [callable protocol](https://firebase.google.com/docs/functions/callable-reference), [Genkit tools](https://genkit.dev/docs/js/tool-calling/), and [Flutter setup](https://docs.flutter.dev/install).
