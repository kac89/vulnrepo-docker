FROM alpine:latest AS build
RUN mkdir /app
RUN apk add wget
RUN apk add unzip
WORKDIR /app
RUN wget https://github.com/kac89/vulnrepo-build-prod/archive/refs/heads/master.zip
RUN unzip master.zip
WORKDIR /app/vulnrepo-build-prod-master

FROM nginx:latest AS nginx
COPY --from=build /app/vulnrepo-build-prod-master /usr/share/nginx/html
COPY ./nginx.conf  /etc/nginx/conf.d/default.conf
EXPOSE 80
