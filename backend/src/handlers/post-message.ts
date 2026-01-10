import { RequestHandler } from "express";
import { secretMessageDataService } from "#data/firestore.js";
import { secretMessageSchema } from "#types/timestamped-secret-message.js";
import { timestampMessage } from "#utils/timestamp-message.js";

export const postMessage: RequestHandler = async (req, res) => {
  const parsed = secretMessageSchema.safeParse(req.body);

  if (parsed.error) return res.status(401).send("Invalid data");

  const messageId = await secretMessageDataService.save(timestampMessage(parsed.data));

  res.status(200).send({
    id: messageId,
  });
};
