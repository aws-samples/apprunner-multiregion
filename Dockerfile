ARG GO_VERSION=1.18.1
ARG NODE_VERSION=16.15.0
ARG ALPINE_VERSION=3.15.4

# build frontend
FROM node:${NODE_VERSION}-alpine AS build-node
WORKDIR /app
COPY nextjs/package.json ./
RUN npm install
COPY nextjs/ .
ENV NEXT_TELEMETRY_DISABLED=1
RUN npm run export

# build backend
FROM golang:${GO_VERSION} AS build-go
WORKDIR /app
COPY go.mod go.sum *.go ./
COPY --from=build-node /app/dist ./nextjs/dist
ENV GOPROXY=direct
RUN CGO_ENABLED=0 GOOS=linux go build -v -o app .

FROM --platform=linux/amd64 alpine:${ALPINE_VERSION}
WORKDIR /app
COPY --from=build-go /app/app .
ENTRYPOINT ["./app"]
