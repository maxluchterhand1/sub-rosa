import { z } from "zod";

export const secretMessageSchema = z.object({
  encryptedData: z.string().readonly(),
  iv: z.string().readonly(),
});

export const secretMessageTimestampSchema = z.object({
  createdAtUnixTimestamp: z.number().readonly(),
  expirationUnixTimestamp: z.number().readonly(),
});

export const timestampedSecretMessageSchema = z.object({
  ...secretMessageSchema.shape,
  ...secretMessageTimestampSchema.shape,
})

export type SecretMessage = z.infer<typeof secretMessageSchema>;

export type secretMessageTimestamp = z.infer<typeof secretMessageTimestampSchema>;

export type TimestampedSecretMessage = z.infer<typeof timestampedSecretMessageSchema>;
