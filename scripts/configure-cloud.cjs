// Uses the existing Firebase CLI login; never writes or prints credentials.
const { requireAuth } = require("firebase-tools/lib/requireAuth");
const { ensure } = require("firebase-tools/lib/ensureApiEnabled");
const { Client } = require("firebase-tools/lib/apiv2");
(async () => {
  const project = "het-cw3-quest-20261115";
  const { configstore } = require("firebase-tools/lib/configstore");
  await requireAuth({
    project,
    user: configstore.get("user"),
    tokens: configstore.get("tokens"),
  });
  for (const api of [
    "firestore.googleapis.com",
    "identitytoolkit.googleapis.com",
    "firebaserules.googleapis.com",
  ])
    await ensure(project, api, "CW3");
  const client = new Client({
    urlPrefix: "https://identitytoolkit.googleapis.com",
    apiVersion: "v2",
  });
  await client.patch(
    `/projects/${project}/config`,
    { signIn: { email: { enabled: true, passwordRequired: true } } },
    { queryParams: { updateMask: "signIn.email" } },
  );
  console.log("Email/password provider enabled.");
})().catch((e) => {
  console.error(e.message);
  process.exitCode = 1;
});
