# Deployment Guide

AELION runs locally without any cloud provider:

## Termux (Android)
Lightweight local deployment with CLI HUD.

## Linux
Full deployment with systemd services.

## Local Linux

Build and run the application directly from the repository root:

```bash
make all
make test
./scripts/run_local.sh system.check
```

No Oracle account, Docker installation, cloud credentials, or external service is required.

## Optional Docker Compose

Docker Compose is an optional container workflow. It is not required for building,
testing, or running AELION locally. When Docker is available, start it with:

```bash
docker compose -f deploy/docker/docker-compose.yml up --build
```

The container uses the same `scripts/run_local.sh` entry point as the local workflow.

## Optional Oracle Deployment

The files under `deploy/oracle` and `src/adapters/cloud` are optional infrastructure helpers. They are not used by the build, test, local, Linux, Termux, or Docker workflows.
