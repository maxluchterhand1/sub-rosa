import express from "express";
import { getMessage } from "#handlers/get-message.js";
import { postMessage } from "#handlers/post-message.js";
import bodyParser from "body-parser";
import cors from "cors";

const app = express();
const port = process.env.PORT ?? "8080";


if (process.env.ENVIRONMENT === "development") {
  app.use((cors as (options: cors.CorsOptions) => express.RequestHandler)({}));
}

app.use(bodyParser.json());

app.get("/v1/message/:id", getMessage);
app.post("/v1/message", postMessage);

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
