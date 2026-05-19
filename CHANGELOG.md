# Changelog

## v1.1.1 – CPR certification renewed

Still no changes in functionality. Why change what works.
It's more important to focus on what DOESN'T work.

### Changes
- Taught the script that `-t` without a target is not a philosophical statement
- Fixed ping/curl disagreement during emergencies
- Added extra protection against creative command-line archaeology
- Improved log initialization handling
- Example output now uses `.csv`, because pretending otherwise became exhausting
- Continued attempts at keeping firmware-induced coma patients among the living

### Notes

> Deep sleep is a privilege, not a right.
>
> Not even CPR is a blanket guarantee.

## v1.1.0

### Added

- Docker container support
- Docker entrypoint runtime wrapper
- Docker Compose deployment
- Runtime environment variables:
  - TARGET
  - INTERVAL
  - LOGFILE
- Portable "hospital in a bag" deployment support

### Changed

- README expanded with Docker documentation
- Logging behavior documented for container environments
- Deployment model expanded from shell-only to shell + container

### Notes

- One container per patient.


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
- Windows with scripting environment

No guarantees.
No magic.
Just telemetry, persistence, and mild stubbornness.
