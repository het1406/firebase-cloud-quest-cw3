// Explicit cloud seed for this newly created coursework project, using Firebase CLI login.
const { requireAuth } = require("firebase-tools/lib/requireAuth");
const { configstore } = require("firebase-tools/lib/configstore");
const { Client } = require("firebase-tools/lib/apiv2");
(async () => {
  const project = "het-cw3-quest-20261115";
  await requireAuth({
    project,
    user: configstore.get("user"),
    tokens: configstore.get("tokens"),
  });
  const client = new Client({
    urlPrefix: "https://firestore.googleapis.com",
    apiVersion: "v1",
  });
  await client.patch(
    `/projects/${project}/databases/(default)/documents/challenges/today`,
    {
      fields: {
        title: { stringValue: "Signal Check" },
        prompt: {
          stringValue:
            "Explain why a trusted server, rather than a mobile client, should award points. Ask the coach for a hint, test an adversarial request, then complete the challenge.",
        },
      },
    },
  );
  console.log("Published challenges/today to the new CW3 project.");
})().catch((e) => {
  console.error(e.message);
  process.exitCode = 1;
});
