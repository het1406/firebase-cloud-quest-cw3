# Evidence inventory — Het Jani

All artifacts are from actual automated execution. Local dates use America/New_York; UTC logs may show November 16. No provider credential or its screenshot belongs in this folder.

## Live provider evidence

- `live-signal-check.json`: passing real Gemini 3.5 Flash-Lite ordinary and adversarial requests through the authenticated Firebase callable, tool-before-generation audit, and unchanged before/after records for two synthetic learners.
- `live-check-run.txt`: sanitized live-check summary.
- `android-live-journey.txt`: latest Android live-provider journey and final result.
- `03-live-model-hint.png`: actual generated hint in the Android application.
- `04-live-signal-check.png`: actual live adversarial response in the Android application.
- `01-signed-out.png`, `02-signed-in.png`, `05-earned-reward.png`, `06-duplicate-reward.png`, `07-signed-out-again.png`: most recent journey captures, including exactly 10 points and the badge.

## Deterministic mocks and failure fixtures

- `signal-check.json`: deterministic emulator fallback and safety-policy response, not a model-generated hint.
- `android-journey.txt`, `03-grounded-emulator-hint.png`, `04-signal-check.png`: prior passing deterministic journey and screenshots.
- `backend-tests.txt`: 16 passing tests. Provider-error and empty-response tests use injected fixtures; ordinary callable checks run in server-controlled mock mode on isolated emulators.
- `flutter-analyze.txt`: clean analysis; `flutter-tests.txt`: 3 passing Flutter tests.

## Historical attempts and environment

- `live-signal-check-initial.json`: first live request pair kept records safe but failed the explicit-refusal wording assertion. It is not labeled a passing test.
- `android-live-journey-initial-failure.txt`: initial device test with a missing test-selector assertion; the final rerun is in `android-live-journey.txt`.
- Files named `initial-failure` or `disk-failure` preserve resolved build/launch issues.
- `03-coach-unavailable.png` is a historical missing-provider error before fallback/live configuration.
- `cloud-rules-deploy.txt` and `cloud-challenge-seed.txt`: successful cloud Firestore work.
- `cloud-configure.txt` and `cloud-functions-deploy.txt`: unresolved cloud Auth/billing blockers.
- `flutter-doctor.txt`, `flutter-devices.txt`, and `flutterfire-configure.txt`: actual environment and iOS limitations.
- `credential-scan.json`: history scan for its recorded Git head. The final scan and ZIP-to-commit verification are alongside the archive in `submission/ARCHIVE_VERIFICATION.json`.

ANSI sequences, incidental environment-dump lines, and trailing whitespace are removed from text captures for readability and privacy. Actual responses, results, and timestamps are preserved. Model behavior is verified only for the recorded scenarios; general injection resistance and instructor approval are not claimed.
