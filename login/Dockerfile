FROM node:0.12.0-slim
add ./ /src/

RUN cd /src/ && npm install && apt-get update && apt-get install apache2-utils

EXPOSE 8080

CMD node /src/auth.js
