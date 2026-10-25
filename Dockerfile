# Fetch the latest automatic production build of https://github.com/kac89/vulnrepo
FROM alpine:3.24 AS build
RUN apk add --no-cache wget unzip
WORKDIR /app
# BUILD_REF is the kac89/vulnrepo commit this image is built from. It only exists
# to invalidate the layer below, so a cached build can never ship a stale app.
ARG BUILD_REF=master
RUN wget -q -O build.zip https://github.com/kac89/vulnrepo-build-prod/archive/refs/heads/master.zip \
 && unzip -q build.zip \
 && rm build.zip \
 && rm -f vulnrepo-build-prod-master/README.md vulnrepo-build-prod-master/CNAME

FROM nginx:1.30-alpine AS nginx
COPY --from=build /app/vulnrepo-build-prod-master /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD wget -q --spider http://127.0.0.1/index.html || exit 1
