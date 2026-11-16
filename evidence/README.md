# Genuine evidence inventory

These artifacts were produced by actual automated commands and Android emulator interactions on November 15, 2026 (America/New_York). Some service logs use UTC and therefore show November 16. No screenshots or model responses were fabricated.

| File | What it demonstrates |
|---|---|
| `flutter-doctor.txt`, `flutter-devices.txt` | Initial environment inspection and platform limitations |
| `flutter-analyze.txt` | Final static analysis result |
| `flutter-tests.txt` | Three Flutter validation/widget tests |
| `backend-tests.txt` | 15 passing Firebase emulator/provider-failure tests, including denied unauthorized writes |
| `signal-check.json` | Grounded deterministic emulator hint, deterministic adversarial refusal, caller and other-user before/after state, first and duplicate completion |
| `android-build.txt` | Successful standalone debug APK build after clearing disposable build intermediates |
| `android-launch.txt` | Installing and launching the standalone app on Android |
| `android-journey.txt` | Passing Android integration journey result |
| `device-suite.txt` | Emulator startup, callable activity, and Android test orchestration |
| `01-signed-out.png` | Actual signed-out screen |
| `02-signed-in.png` | Actual challenge and initial progress |
| `03-grounded-emulator-hint.png` | Real challenge-grounded deterministic fallback, **not** live model evidence |
| `03-coach-unavailable.png` | Historical missing-model error captured before the updated prompt authorized fallback |
| `04-signal-check.png` | Actual deterministic security refusal |
| `05-earned-reward.png` | First completion, 10 points, and First Quest badge |
| `06-duplicate-reward.png` | Duplicate completion without an increased reward |
| `07-signed-out-again.png` | Protected screen removed after sign-out |
| `firebase-project-create.txt` | New cloud project creation |
| `cloud-rules-deploy.txt` | Successful security rules deployment |
| `cloud-challenge-seed.txt` | Successful cloud challenge seed |
| `cloud-configure.txt` | Cloud Authentication configuration blocker |
| `cloud-functions-deploy.txt` | Actual Blaze billing deployment blocker |
| `flutterfire-configure.txt` | Attempted registration and missing iOS Ruby dependency |

Read test results to distinguish implementation from verified behavior. All seven current numbered journey stages are present and the Android integration test passes. The additional historical unavailable screenshot predates the fallback requirement. A successful live-model AI hint and the full live-cloud journey remain missing. Backend safety checks do not prove live model quality or general prompt-injection resistance.

CLI environment-dump lines and ANSI control sequences are removed from captured text for privacy/readability. Remaining messages and results are genuine. `signal-check.json` excludes session tokens and passwords.
