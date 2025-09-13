# Sample CI/CD Pipeline — GitLab + Docker + Flask + Pytest

This repository demonstrates a minimal CI/CD setup using **GitLab CI**, **Docker**, and a **Python/Flask** sample app.
The pipeline has two stages (`build`, `test`), builds a Docker image, pushes to **Docker Hub**, stores the image as an **artifact**, and runs both unit + simple integration tests inside CI.

---

## Project Structure

```
sample-ci-cd/
├─ app.py
├─ requirements.txt
├─ tests/
│  └─ test_app.py
├─ Dockerfile
├─ .gitlab-ci.yml
└─ README.md
```

**Endpoints**
- `GET /health` → `{ "status": "ok" }`

---

## Prerequisites

- GitLab project (with CI/CD enabled).
- **Docker Hub** account and repository (e.g., `docker.io/<username>/sample-ci`).
- GitLab Project → **Settings → CI/CD → Variables**:
  - `DOCKERHUB_USERNAME` = your Docker Hub username
  - `DOCKERHUB_PASSWORD` = your Docker Hub password or access token (masked, protected OFF for default branch usage)

---

## How the Pipeline Works

1. **Build stage**
   - Logs in to Docker Hub.
   - Builds image from `Dockerfile` and tags it `docker.io/$DOCKERHUB_USERNAME/sample-ci:$CI_COMMIT_SHORT_SHA`.
   - Pushes the image to Docker Hub.
   - Saves the image as an artifact (`image.tar`) and writes the tag into `image_tag`.

2. **Test stage**
   - Downloads artifacts (`image.tar`, `image_tag`).
   - Loads the image, runs **unit tests** (`pytest`) with `PYTHONPATH=/app` for module resolution.
   - Starts the container in background.
   - Performs a **health check** by running a tiny container in the **same network namespace** (`--network container:<name>`) so it can reach `http://127.0.0.1:5000/health` inside the app container.
   - Cleans up the container in `after_script`.

---

## `Dockerfile`

```dockerfile
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1     PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
EXPOSE 5000

CMD ["python", "app.py"]
```

---

## Local Development

Build & run locally:
```bash
docker build -t sample-ci:local .
docker run -d -p 5000:5000 --name app sample-ci:local
curl http://localhost:5000/health
# Stop & clean
docker rm -f app
```

Run unit tests locally (without Docker):
```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export PYTHONPATH=$PWD
pytest -q
```

---

## Assumptions

- Runner has DinD enabled and is **privileged**.
- Docker Hub credentials are correct and stored in project variables.
- The app is a simple Flask service started with `python app.py`.
- Artifact retention is 1 week (change if needed).
