# Rubric audit — Het Jani

CSC 4360 — CW3 — Undergraduate individual coursework. This audit maps all 100 available points; it is not a grade estimate or a claim that every requirement is complete.

| Category | Available | Implementation / evidence | Status and remaining requirement |
|---|---:|---|---|
| Engagement and learning process | 5 | Fresh Git repository, environment logs, README setup and architecture | Partial: student must review implementation and demonstrate their own learning; no invented participation history. |
| Conceptual understanding | 15 | `functions/src/core.js`, `functions/src/index.js`, `firestore.rules`, README | Implemented: verified UID boundary, transaction idempotency, read-only tool. Student should explain these choices. |
| Core application | 30 | `lib/main.dart`, `test/widget_test.dart`, `integration_test/journey_test.dart`, device evidence | Verified on Android with a passing integration journey and seven screenshots. Cloud Auth and deployed Functions remain unfinished. |
| AI agent | 15 | `functions/src/index.js`, `evidence/signal-check.json` | Partial: actual Genkit tool and provider adapter exist. Grounded deterministic emulator hint and safety refusal verified. Missing approved model configuration and live generation; fallback is not proof of live model quality or resistance. |
| Reasoning and reflection | 10 | `REFLECTION.md` (128 words), `STUDENT_REFLECTION_GUIDE.md`, actual Signal Check before/after state | Draft prepared, student review required. Revise after live-model evaluation. |
| Testing and evidence | 15 | 3 Flutter tests; 15 emulator backend/rules/provider-failure tests; Android journey; `evidence/` | 3 widget tests, 15 backend tests, and 1 Android journey pass; analysis is clean. Successful live model hint screenshot/evaluation and cloud journey still missing. |
| Communication and delivery | 10 | README, reflection, audit, checklist; new private GitHub repository | Documents prepared. Verify instructor access and final push; course portal not submitted. |
| **Total available** | **100** | All categories mapped | **Not fully verified; no guaranteed grade.** |

Resolvable implementation failures were corrected during testing: analyzer scanned Node package Dart templates, Kotlin was too old for the installed Firebase SDK, the emulator seed needed correct Node package resolution, Android debug builds needed local HTTP access, and the demo API key needed the SDK’s expected format. Exact final outcomes are in the evidence files; the ordinary fallback is explicitly not counted as live model success.
