# AELION System Architecture

AELION is a modular, message-driven intelligence and governance system built on the Universal Sentence Protocol (USP).  
It consists of three primary layers:

## 1. Interface Layer
- CLI (Termux/Linux)
- HUD (Web + Text UI)
- API endpoints

## 2. Logic Layer
- Justice Engine
- Recall Engine
- Emotional Engine
- Home Engine
- Community Engine
- Governance Engine
- Mining Engine (optional)

## 3. Infrastructure Layer
- Storage
- Scheduler
- Supervisor
- Adapters (Termux, Linux, USOS, Cloud)

USP sentences flow through the bus, into engines, through governance, and back to the HUD.

## Production Runtime

The API server is a persistent local HTTP process started with `--serve`.
It accepts structured JSON requests, requires bearer authentication on
protected routes, and exposes health, metrics, and event endpoints. Accepted
requests are appended to `AELION_DATA_DIR/events.log` and reloaded on startup.
Production mode requires an explicit `AELION_API_TOKEN`; the default bind
address remains loopback so a TLS reverse proxy can provide public access.
Client reads have a bounded timeout, request size is capped, and POSIX builds
support SIGINT/SIGTERM shutdown without abandoning the listening socket.
POSIX and Cygwin builds process clients on detached workers; metrics and journal
writes are synchronized so concurrent requests cannot corrupt shared state.
Native Windows builds retain a synchronous fallback until a native worker
adapter is introduced.
