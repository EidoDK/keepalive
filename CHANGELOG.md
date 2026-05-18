# Changelog

## v1.0.1

Contract precision update.

This release does not redesign functionality.
It tightens communication behavior and adds an optional
interactive mode.

Changes:

- Added centralized `output_handling()`
- Clarified runtime/output behavior
- Added `-i` / `--interactive`
- Interactive doctor-style status output
- Runtime edge cases converted to structured status events
- Removed runtime help/output noise

No protocol changes.
No scheduler changes.
No telemetry format changes.

Deep sleep is still a privilege, not a right.


## v1.0.0

Initial public release.

Features:

- curl-based keepalive with HTTP response timing
- ping fallback heartbeat
- CSV telemetry logging
- exit code support
- scheduler-friendly behavior
- cross-platform shell support
- BusyBox / ash compatibility
- GitHub public release

Verified on:

- Synology BusyBox / ash
- Ubuntu WSL
- Debian WSL
- Fedora WSL
- Kali WSL

No guarantees.
No magic.
Just telemetry, persistence, and mild stubbornness.