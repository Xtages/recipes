ARG NODE_VERSION=15.13.0
ARG AWS_ACCOUNT=605769209612
FROM ${AWS_ACCOUNT}.dkr.ecr.us-east-1.amazonaws.com/xtages-build-images/node_ci:${NODE_VERSION}

ARG DB_URL
ARG DB_USER
ARG DB_NAME
ARG DB_PASS
ARG PGPORT=5432

ENV PGHOST=${DB_URL}
ENV PGUSER=${DB_USER}
ENV PGDATABASE=${DB_NAME}
ENV PGPASSWORD=${DB_PASS}
ENV PGPORT=${PGPORT}

WORKDIR /usr/src/app
COPY package*.json ./

RUN npm install
COPY . .
EXPOSE 3000
CMD node src/server.js

RUN adduser -D nodejs-app
USER nodejs-app
