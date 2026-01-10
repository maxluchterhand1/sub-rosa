import { TimestampedSecretMessage } from "#types/timestamped-secret-message.js";
import { createCipheriv, createDecipheriv, generateKeySync, randomBytes } from "node:crypto";

export type MessageContent = string;
export type SerializedKey = string;

const keyTtlHours = 24;
const authTagLength = 16;
const algorithm = "aes-256-gcm";

export function encryptMessage(content: MessageContent): [TimestampedSecretMessage, SerializedKey] {
  const key = generateKeySync("aes", { length: 256 });
  const iv = randomBytes(16);
  const cipher = createCipheriv(algorithm, key, iv, { authTagLength });

  const hexKey = key.export({ format: "buffer" }).toString("hex");
  const hexIv = iv.toString("hex");

  const encrypted = Buffer.concat([cipher.update(content, "utf8"), cipher.final()]);
  const taggedEncrypted = Buffer.concat([encrypted, cipher.getAuthTag()]);

  const message: TimestampedSecretMessage = {
    iv: hexIv,
    encryptedData: taggedEncrypted.toString("hex"),
    createdAtUnixTimestamp: Date.now(),
    expirationUnixTimestamp: Date.now() + keyTtlHours * 60 * 60 * 1000,
  };

  return [message, hexKey];
}

export function decryptMessage(message: TimestampedSecretMessage, key: SerializedKey): MessageContent {
  const taggedEncrypted = Buffer.from(message.encryptedData, "hex");
  const [encrypted, authTag] = [
    taggedEncrypted.subarray(0, taggedEncrypted.length - authTagLength),
    taggedEncrypted.subarray(taggedEncrypted.length - authTagLength),
  ];

  const decipherIv = createDecipheriv(algorithm, Buffer.from(key, "hex"), Buffer.from(message.iv, "hex"));
  decipherIv.setAuthTag(authTag);

  const decrypted = Buffer.concat([decipherIv.update(encrypted), decipherIv.final()]);
  return decrypted.toString("utf-8");
}
