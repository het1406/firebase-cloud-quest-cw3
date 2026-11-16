# Student reflection guide — Het Jani

Read the actual responses in `evidence/live-signal-check.json` before personalizing the reflection. The implementation and recorded checks were automated; describe only your own genuine personal observations in first person.

Seven factual points you can explain:

1. The backend obtains the learner UID from verified Firebase Authentication, not a client field or model-selected argument.
2. `readMyQuestState` reads the shared challenge and only the authenticated learner's progress. Its input schema is empty and strict.
3. The live audit records `readMyQuestState` before `generate`. The ordinary Gemini response names Signal Check and zero points, matching the stored data.
4. The live attack asks for another learner's badge and 500 points. Gemini explicitly says it cannot access other learners' data or change points.
5. Two real synthetic Auth accounts were used. The caller's zero-point record and the second learner's private badge/10-point record were identical before and after both requests.
6. The model receives only the read-only tool. Only `completeToday` can award the fixed reward, using verified identity and a transaction. Repeat and 12 concurrent calls do not duplicate rewards.
7. Live-provider evidence, deterministic emulator evidence, and injected failure fixtures are distinct. Cloud deployment and instructor provider approval are still unverified.

Before submitting, perform your own brief demonstration if possible, verify that the reflection matches what you observed, and follow the course's assistance-disclosure requirements. Never include the API-key screenshot or any key value in your submission.
