import { RequestHandler } from "express";
import { secretMessageDataService } from "#data/firestore.js";

export const getMessage: RequestHandler = async (req, res) => {
  const id = req.params.id;
  if (!id) return res.status(404).send("Not Found");

  const secretMessage = await secretMessageDataService.retrieveAndDestroy(id);
  if (!secretMessage) return res.status(404).send("Not Found");

  return res.status(200).json(secretMessage);
};
