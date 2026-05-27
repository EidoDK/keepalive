# Changelog

## v1.1.3

### Added
- Optional `KEEPALIVE_NAME` environment variable for custom log source identification.
- Docker Compose example updated with optional patient naming.

### Changed
- Log initialization now supports human-readable appliance identities.
- Script path remains default source when no override is supplied.

### Notes
- Still no functional changes.
- Just quality-of-life improvements.
- Still mildly stubborn.


## v1.1.2 - Docker learned what a real clock looks like

### Added

- Optional timezone support for Docker containers via `TZ`

### Changed

- Container log timestamps can now follow local time instead of UTC
- Dockerfile now includes `tzdata`
- docker-compose.yml introduces `TZ` environment variable support

### Notes

- No `keepalive.sh` logic changes
- Reality remains optional. UTC is still the default.
- Realized that Docker doesn't know how a real clock looks, finally taught it.


## v1.1.1 – CPR certification renewed

Still no changes in functionality. Why change what works.  
It's more important to focus on what DOESN'T work.

### Added

- Extra protection against creative command-line archaeology
- Improved log initialization behavior

### Changed

- Taught the script that `-t` without a target is not a philosophical statement
- Fixed ping/curl disagreement during emergencies
- Example output now uses `.csv`, because pretending otherwise became exhausting
- Continued attempts at keeping firmware-induced coma patients among the living

### Notes

- Deep sleep is a privilege, not a right.
- Not even CPR is a blanket guarantee.


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
It tightens communication behavior and adds an optional interactive mode.

### Added

- Centralized `output_handling()`
- Added `-i` / `--interactive`
- Interactive doctor-style status output

### Changed

- Clarified runtime/output behavior
- Runtime edge cases converted to structured status events
- Removed runtime help/output noise

### Notes

- No protocol changes
- No scheduler changes
- No telemetry format changes
- Deep sleep is still a privilege, not a right.


## v1.0.0

Initial public release.

### Features

- curl-based keepalive with HTTP response timing
- ping fallback heartbeat
- CSV telemetry logging
- exit code support
- scheduler-friendly behavior
- cross-platform shell support
- BusyBox / ash compatibility
- GitHub public release

### Verified on

- Synology BusyBox / ash
- Ubuntu WSL
- Debian WSL
- Fedora WSL
- Kali WSL
- Windows with scripting environment

### Notes

No guarantees.  
No magic.  
Just telemetry, persistence, and mild stubbornness.
