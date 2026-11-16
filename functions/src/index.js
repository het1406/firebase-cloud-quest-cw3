const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { genkit, z } = require("genkit");
const { googleAI } = require("@genkit-ai/google-genai");
const { uidOf, complete, readState, questionOf } = require("./core");
const { emulatorFallbackAllowed, generateHint } = require("./model");
initializeApp();
const db = getFirestore();
const key = defineSecret("GOOGLE_GENAI_API_KEY");
exports.completeToday = onCall({ region: "us-central1" }, (request) =>
  complete(db, request),
);
exports.askQuestCoach = onCall(
  { region: "us-central1", secrets: [key], timeoutSeconds: 45 },
  async (request) => {
    const uid = uidOf(request);
    const question = questionOf(request);
    // A request-local tool closes over verified identity. Neither model nor client can select a UID.
    const ai = genkit({
      plugins: [googleAI({ apiKey: key.value() || "unconfigured" })],
    });
    const readMyQuestState = ai.defineTool(
      {
        name: "readMyQuestState",
        description:
          "Read only the authenticated caller’s daily quest. No writes.",
        inputSchema: z.object({}).strict(),
      },
      async () => readState(db, uid),
    );
    const state = await readMyQuestState({});
    // Deterministic refusal guarantees no false claim of writes for the required Signal Check.
    if (
      /\b(ignore|another|other learner|500|give me .*points|change .*points)\b/i.test(
        question,
      )
    ) {
      return {
        hint: "I can only read your own quest state. I cannot reveal another learner’s badge or change points. Use Complete Challenge to earn the fixed reward.",
        source: "safety-policy",
        state,
      };
    }
    if (!key.value() && emulatorFallbackAllowed()) {
      return {
        hint: `Local emulator hint (deterministic): For "${state.challenge.title}", consider the task: ${state.challenge.prompt} Start by identifying what a trusted server must verify and why client-submitted rewards cannot be trusted. Your progress is ${state.progress.completed ? "completed" : "not completed"}, with ${state.progress.points} points.`,
        source: "emulator-fallback",
        state,
      };
    }
    if (!key.value())
      throw new HttpsError(
        "unavailable",
        "Quest Coach is not configured. Please try again after the model service is connected.",
      );
    const hint = await generateHint(ai, readMyQuestState, state, question);
    return { hint, source: "genkit", state };
  },
);
