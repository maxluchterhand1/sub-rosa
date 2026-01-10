import { Firestore } from "@google-cloud/firestore";
import { SecretMessageDataService, SecretMessageId } from "#types/secret-message-data-service.js";
import { TimestampedSecretMessage, timestampedSecretMessageSchema } from "#types/timestamped-secret-message.js";
import { v4 } from "uuid";

const db = new Firestore({
  databaseId: process.env.FIRESTORE_DB_NAME,
  projectId: process.env.GCP_PROJECT_ID,
});

async function saveSecretMessage(message: TimestampedSecretMessage): Promise<SecretMessageId> {
  const id = v4();
  const docRef = db.collection("messages").doc(id);
  await docRef.set(message);
  return id;
}

async function retrieveAndDestroy(id: SecretMessageId): Promise<TimestampedSecretMessage | null> {
  const docRef = db.collection("messages").doc(id);
  return await db.runTransaction(async (t) => {
    const doc = await t.get(docRef);
    if (!doc.exists) return null;
    const parseResult = timestampedSecretMessageSchema.safeParse(doc.data());
    if (parseResult.error) return null;
    t.delete(docRef);
    return parseResult.data;
  });
}

const secretMessageDataService: SecretMessageDataService = {
  save: saveSecretMessage,
  retrieveAndDestroy: retrieveAndDestroy,
};

export { secretMessageDataService };
