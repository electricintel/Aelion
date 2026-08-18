#!/usr/bin/env bash
set -euo pipefail

cat <<'MSG'
AELION local deployment does not require Oracle Cloud.

Use the repository-root commands instead:
	make all
	make test
	./scripts/run_local.sh system.check

Oracle deployment is intentionally opt-in and is not part of the default
build, test, local, optional Docker, Linux, or Termux workflows.
MSG
