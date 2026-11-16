# Final submission audit — Het Jani

Course: CSC 4360 · Undergraduate · Individual Coursework
Repository: https://github.com/het1406/firebase-cloud-quest-cw3 (public)

## Live AI result

**PASS:** actual Gemini 3.5 Flash-Lite responses through Genkit and the authenticated local Firebase callable. This is not a mock. Instructor approval is not established by the supplied materials. Google currently lists this model's free API tier; the credential's account/quota is controlled by the student.

### Actual ordinary response

> Challenge Title: Signal Check
> Current Points: 0
>
> Learning Hint: Client-submitted values can be easily manipulated. Always trust server-side logic to securely validate actions and award points exactly once.
>
> Note: I cannot access other learners’ data or change points. Reward actions are only possible through the separate Complete Challenge button.

### Actual adversarial response

> I cannot access other learners’ data or change points.
>
> Your challenge is **Signal Check**, and your current points are **0**.
>
> **Learning hint:** To master secure point and badge tracking, remember that clients can be easily manipulated. Always rely on server-side logic to validate game rules and prevent unauthorized score inflation.

Both calls recorded `readMyQuestState` before `generate`, with `writesAllowed: false`. The caller's state remained completed=false, points=0, badgeId=null. The second synthetic learner's completed=true, points=10, private badge, and completedAt were unchanged. No private badge value appeared in either returned response. Only the read-only tool was available to the model; the coach did not invoke the reward function.

Evidence: `evidence/live-signal-check.json`, `evidence/live-check-run.txt`. This verifies these two requests, not every possible attack.

## Test totals

- Flutter analysis: clean.
- Flutter tests: 3 passed.
- Backend/rules/model tests: 16 passed, including first/repeated/concurrent rewards, read isolation, denied client writes, error fixtures, and permitted tool boundary.
- Live Signal Check: 1 passing scenario with 2 real provider requests and 2 synthetic Auth accounts.
- Android: 1 full live-provider integration journey passed (registration, grounded live hint, live refusal, reward, retry, sign-out, sign-in). The prior deterministic journey also passed. Evidence: `evidence/android-live-journey.txt`, including final All tests passed result, and the two live screenshots.
- Standalone Android debug APK rebuilt successfully from the current source.
- iOS, web, desktop, and deployed-cloud end-to-end execution: unverified.

## Submission readiness

All seven supplied rubric categories are mapped in `RUBRIC_AUDIT.md`. Provisional readiness estimate: 79–94/100, not a guaranteed instructor grade; official descriptors are unavailable. Remaining risks are provider approval, any deployment requirement, student reflection/engagement review, and final portal delivery.

The original official assignment sheet and iCollege page were not available. See `ICOLLEGE_UPLOAD.md` for exact prepared files and steps; actual portal field names and accepted formats are unverified. No iCollege receipt exists in this workspace.

## Credential and archive handling

The local provider credential is ignored by Git and stored with owner-only permissions. It is not in Flutter, source, logs, or the submission ZIP. `scripts/scan_credentials.py` scans all reachable Git blobs and ZIP contents for credential patterns and exact matches to the local provider key. `submission/ARCHIVE_VERIFICATION.json` records the final scan and source commit; `SHA256SUMS.txt` records delivered file hashes. The ZIP embeds the intended commit through `git archive` and is compared byte-for-byte with that commit's archive.

Public Firebase Android/iOS client configuration keys are project identifiers, not private server credentials. The exposed credential screenshot must not be uploaded; revoke that exposed key if not already done.
