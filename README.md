# Roadmaster × Zoom — Executive Brief

Static, single-page executive brief (React + Babel compiled in-browser).
Designed to be served as plain static files — no build step, no backend.

## Deploy to Fly.io

Prerequisites: [flyctl](https://fly.io/docs/hands-on/install-flyctl/) installed
and logged in (`fly auth login`).

### First deploy

```bash
# From the project root:
fly launch --no-deploy --copy-config --name <your-app-name>
# accept the existing fly.toml when prompted, skip Postgres / Redis
fly deploy
```

`fly launch` will rewrite `app = "..."` in `fly.toml` to your chosen name.
Pick something unique — Fly app names are global.

### Subsequent deploys

```bash
fly deploy
```

Your app will be live at `https://<your-app-name>.fly.dev`.

### Custom domain

```bash
fly certs add brief.example.com
# then point a CNAME (or A/AAAA) at your app's fly hostname
fly certs show brief.example.com
```

## What gets deployed

Only these files are copied into the container (see `.dockerignore`):

- `index.html`
- `assets/` — Roadmaster + Zoom logos (`roadmaster-logo-animated.webp`, `roadmaster-logo.jpeg`, `zoom-logo.png`)

The `uploads/` folder (source BOMs, PDFs, drafts) is excluded from the image.

## Local preview

Nothing to build — just serve the folder:

```bash
python3 -m http.server 8080
# then open http://localhost:8080
```

Or test the exact production container:

```bash
docker build -t roadmaster-brief .
docker run --rm -p 8080:8080 roadmaster-brief
# open http://localhost:8080
```

## Files

| File | Purpose |
|---|---|
| `index.html` | The entire executive brief (React in Babel, inline styles) |
| `assets/roadmaster-logo-animated.webp` | Animated Roadmaster wordmark (nav) |
| `assets/roadmaster-logo.jpeg` | Roadmaster square mark (password gate) |
| `assets/zoom-logo.png` | Official Zoom wordmark (nav) |
| `Dockerfile` | nginx:alpine base, serves the static files |
| `nginx.conf` | Listens on 8080, gzip, cache headers, `/health` endpoint |
| `fly.toml` | Fly.io app config — single shared-cpu-1x machine, auto-stop/start |
| `.dockerignore` | Keeps uploads + tooling out of the image |

## Notes

- The `nginx.conf` sets `Cache-Control: no-store` on `index.html` and long
  cache + `immutable` on `/assets/`. Safe to redeploy any time — browsers will
  always pick up the new HTML.
- `auto_stop_machines = "stop"` in `fly.toml` means the machine sleeps when
  idle and wakes on the next request (~1-2s cold start). Flip to `"off"` and
  set `min_machines_running = 1` if you want it always hot.
