ARG NODE_VERSION=15.13.0
FROM 606626603369.dkr.ecr.us-east-1.amazonaws.com/xtages-build-images/node_ci:${NODE_VERSION}

RUN adduser -D nodejs-app
WORKDIR /usr/src/app
COPY package*.json ./

RUN npm install
COPY . .
EXPOSE 3000
CMD node src/server.js
USER nodejs-app
