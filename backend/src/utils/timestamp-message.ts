import { SecretMessage, TimestampedSecretMessage } from "#types/timestamped-secret-message.js";

const keyTtlHours = 24;

export function timestampMessage(secretMessage: SecretMessage): TimestampedSecretMessage {
  return {
    ...secretMessage,
    createdAtUnixTimestamp: Date.now(),
    expirationUnixTimestamp: Date.now() + keyTtlHours * 60 * 60 * 1000,
  };
}
