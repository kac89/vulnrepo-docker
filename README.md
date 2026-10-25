# vulnrepo-docker

Docker packaging for **VULNRΞPO** — a free, end-to-end encrypted vulnerability report
generator and repository ([vulnrepo.com](https://vulnrepo.com)).

[![DOCKER PUBLISH](https://github.com/kac89/vulnrepo-docker/actions/workflows/docker-image.yml/badge.svg)](https://github.com/kac89/vulnrepo-docker/actions/workflows/docker-image.yml)
[![Docker pulls](https://img.shields.io/docker/pulls/kac89/vulnrepo)](https://hub.docker.com/r/kac89/vulnrepo)
[![Image size](https://img.shields.io/docker/image-size/kac89/vulnrepo/latest)](https://hub.docker.com/r/kac89/vulnrepo/tags)

This repository contains only the `Dockerfile`, the nginx config and the publish
workflow. The application itself lives in
[kac89/vulnrepo](https://github.com/kac89/vulnrepo), and the image ships its
prebuilt output from
[kac89/vulnrepo-build-prod](https://github.com/kac89/vulnrepo-build-prod).

VULNREPO is a fully client-side app: the container is a plain nginx serving static
files. There is no backend, no database and no telemetry — your reports are
encrypted and stay in your browser.

## Quick start

```bash
docker run -d --name vulnrepo -p 8080:80 kac89/vulnrepo:latest
```

Then open <http://localhost:8080>.

To stop and remove it:

```bash
docker rm -f vulnrepo
```

### docker compose

```yaml
services:
  vulnrepo:
    image: kac89/vulnrepo:latest
    container_name: vulnrepo
    ports:
      - "8080:80"
    restart: unless-stopped
```

```bash
docker compose up -d
```

## Image

Published to [hub.docker.com/r/kac89/vulnrepo](https://hub.docker.com/r/kac89/vulnrepo).

| Tag | Meaning |
| --- | --- |
| `latest` | Most recent build of the VULNREPO `master` app build |
| `sha-<short>` | Pinned to a specific `kac89/vulnrepo` commit (first 7 chars) |

- **Platforms:** `linux/amd64`, `linux/arm64`
- **Base:** `nginx:1.30-alpine`
- **Exposed port:** `80` (plain HTTP)
- **Healthcheck:** built in — `wget --spider http://127.0.0.1/index.html` every 30s

Pin `sha-<short>` for reproducible deployments; `latest` moves whenever the app is
rebuilt. The short sha refers to the commit in the **app** repo, not to a commit in
this packaging repo.

## Configuration

The image is deliberately configuration-free. Two things are worth knowing:

**Serving on another port** — remap the published port, the container always listens
on 80:

```bash
docker run -d -p 3000:80 kac89/vulnrepo:latest
```

**TLS** — the image speaks HTTP only. Terminate TLS in front of it (Traefik, Caddy,
nginx, a cloud load balancer). The app uses browser crypto APIs, several of which
require a secure context, so serve it over HTTPS anywhere other than `localhost`.

**Custom nginx config** — [`nginx.conf`](nginx.conf) sets gzip, the document root
and an SPA fallback (`try_files … /index.html`). Override it without rebuilding:

```bash
docker run -d -p 8080:80 \
  -v "$PWD/my-nginx.conf:/etc/nginx/conf.d/default.conf:ro" \
  kac89/vulnrepo:latest
```

## Building locally

```bash
docker build -t vulnrepo:local .
docker run --rm -p 8080:80 vulnrepo:local
```

The build has two stages: the first downloads
`vulnrepo-build-prod/archive/refs/heads/master.zip` and strips its `README.md` and
`CNAME`; the second copies the result into nginx. Because the download is a layer
like any other, the `BUILD_REF` build arg exists purely to invalidate it:

```bash
docker build --build-arg BUILD_REF="$(git rev-parse HEAD)" -t vulnrepo:local .
```

CI passes the upstream commit sha there and also builds with `--no-cache`, so a
cached layer can never ship a stale app. Do the same if you automate your own
builds.

## License

The packaging in this repository follows the application's license,
[Apache-2.0](https://github.com/kac89/vulnrepo/blob/master/LICENSE).

## Credits

VULNRΞPO is created and maintained by [kac89](https://github.com/kac89).
Report issues with the application itself at
[kac89/vulnrepo/issues](https://github.com/kac89/vulnrepo/issues), and issues with
the image here.
