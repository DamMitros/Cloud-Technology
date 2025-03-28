FROM node:16-alpine

WORKDIR /app
COPY app/ .
RUN npm install
ENV NODE_ENV=production
EXPOSE 8080

CMD ["node", "server.js"]