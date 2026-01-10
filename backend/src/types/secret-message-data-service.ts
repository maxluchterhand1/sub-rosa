import { TimestampedSecretMessage } from "#types/timestamped-secret-message.js";

export type SecretMessageId = string;

export interface SecretMessageDataService {
  readonly save: (message: TimestampedSecretMessage) => Promise<SecretMessageId>;
  readonly retrieveAndDestroy: (id: SecretMessageId) => Promise<TimestampedSecretMessage | null>;
}
