FROM node:12-buster-slim AS builder

RUN apk --no-cache add make python3 g++
RUN apt-get update && apt-get install -y python
ENV PYTHON=/usr/bin/python3
RUN npm config set python3 /usr/bin/python


USER node
WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "./"]
RUN npm install
COPY --chown=node:node . .
RUN npm run build



FROM node:16-alpine AS deps

USER node
WORKDIR /home/node

COPY --chown=node:node ["package.json", "package-lock.json", "./"]
RUN npm install --omit=dev



FROM node:16-alpine AS runner

USER node
WORKDIR /home/node

COPY --chown=node:node --from=deps ["/home/node/node_modules", "node_modules/"]
COPY --chown=node:node --from=builder ["/home/node/dist", "dist/"]
COPY --chown=node:node ["server/", "./server"]
COPY --chown=node:node ["public/", "./public"]

CMD [ "node", "server/start.js" ]
