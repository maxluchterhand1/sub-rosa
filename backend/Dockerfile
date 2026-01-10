# Use a lightweight Node image
FROM node:25-slim

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY . .

#RUN npm run build

ENV PORT=8080

CMD [ "npm", "start" ]
