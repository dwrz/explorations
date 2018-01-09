# Version: 0.0.1
FROM node:carbon-alpine
RUN apk update
RUN apk upgrade
WORKDIR /usr/src/app
COPY index.js /usr/src/app
EXPOSE 3000
CMD ["node", "index.js"]
