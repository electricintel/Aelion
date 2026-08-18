# Aelion

Aelion is a modular C application with core USP parsing, message routing,
engines, services, storage, and optional deployment integrations.

## Requirements

For the standard local workflow:

- GCC
- GNU Make

Docker, Docker Compose, Oracle Cloud, and external services are optional.

## Build

Run these commands from the repository root:

```bash
make all
```

The application binary is written to `build/aelion_binary`.

On Windows with a MinGW toolchain, the executable may be named
`build/aelion_binary.exe`.

## Test

Run the integration and USP unit tests:

```bash
make test
```

Run the application health check:

```bash
make check
```

Clean generated build output:

```bash
make clean
```

## Run

From PowerShell after building:

```powershell
.\build\aelion_binary.exe "system.check"
```

If the executable has no `.exe` suffix, use:

```powershell
.\build\aelion_binary "system.check"
```

With Git Bash, WSL, or another Bash environment:

```bash
./scripts/run_local.sh system.check
```

The PowerShell launcher builds the project when needed and forwards arguments:

```powershell
.\scripts\run_aelion.ps1 "justice.review"
```

## Persistent API

Start the local authenticated API server on port 8080:

```powershell
$env:AELION_API_TOKEN = "change-this-local-token"
.\build\aelion_binary.exe --serve 8080
```

The server listens on `127.0.0.1` and exposes:

```text
GET  /api/v1/health
GET  /api/v1/metrics       (Bearer token required)
GET  /api/v1/events        (Bearer token required)
POST /api/v1/requests      (Bearer token required)
```

Submit structured JSON with an `Authorization: Bearer <token>` header:

```json
{"request":"justice.review"}
```

The default development token is `aelion-local-token`; set
`AELION_API_TOKEN` for any shared or long-running environment. The API keeps
request counters and events in `AELION_DATA_DIR/events.log` (default: `data`),
so accepted requests and the latest event survive a process restart.
Protected routes require an exact `Authorization: Bearer <token>` header, and
request bodies are limited to 4 KiB. Oversized requests return HTTP `413` and
unsupported methods on `/api/v1/requests` return HTTP `405`.

Production startup should set an explicit token and data directory:

```powershell
$env:AELION_ENV = "production"
$env:AELION_API_HOST = "127.0.0.1"
$env:AELION_API_PORT = "8080"
$env:AELION_API_TOKEN = "use-a-secret-from-your-secret-store"
$env:AELION_DATA_DIR = "C:\ProgramData\Aelion"
.\build\aelion_binary.exe --serve
```

In production, startup fails if `AELION_API_TOKEN` is missing. Keep the API
bound to loopback unless it is placed behind a TLS-terminating reverse proxy.

Run the Windows API smoke test after building:

```powershell
.\scripts\api_smoke_test.ps1
```

The smoke test starts an isolated server, submits an authenticated structured
request, checks metrics, and terminates the process.

POSIX and Cygwin builds handle clients concurrently with synchronized metrics
and journal writes. Native Windows builds use the portable synchronous server
path; all platforms share the same API contract and persistence format.

Open `src/hud/web/index.html` in a browser to use the dashboard. Enter the API
endpoint and token, then submit requests and inspect live health, metrics, and
events.

Example requests:

```text
system.check
justice.review
recall.timeline
```

## Optional Tools

Generate the diagnostic PowerShell tools once:

```powershell
.\scripts\auto_generate_sequential.ps1
```

Generated tools are placed in `scripts/generated` and emit JSON reports.

Docker Compose is optional:

```bash
docker compose -f deploy/docker/docker-compose.yml up --build
```

Oracle deployment is also optional and is not required by the build, tests, or
local runtime.

## Project Layout

```text
src/core/       USP, bus, registry, security, and shared utilities
src/engines/    Domain engines
src/services/   API, scheduler, and supervisor services
src/storage/    Key-value, timeline, and log storage
tests/          Integration and unit-style C tests
scripts/        Build, run, validation, and diagnostic tooling
deploy/         Optional Docker and Oracle helpers
docs/           Architecture and deployment documentation
```

## Validation

The canonical local verification sequence is:

```bash
make all
make test
make check
```
