## Universal network life support system

This started as an annoyance remedy, but within 36 hours my chaotic brain
had churned out so much that it became a completely different beast.

What began as an attempt to keep a sleepy printer reachable turned into a
lightweight, platform-independent network keepalive utility for virtually
any IP-connected appliance.

It attempts to generate small amounts of real network traffic before
devices quietly wander into digital limbo.

No guarantees.  
No magic.  
Just telemetry, persistence, and mild stubbornness.

---

### Purpose

Attempts to generate small amounts of real network traffic to keep
IP-connected appliances reachable during extended idle periods.

### Primary method

`curl`  
HTTP response + timing + stronger keepalive effect

### Explicit ports

Targets may include explicit ports:

```bash
./keepalive.sh -t 192.168.1.100:8080
```

> [!WARNING]
>
> Most appliances are best observed through their normal service endpoints.
>
> Some appliances may interpret probe traffic as valid input.
>
> If your keepalive strategy starts consuming paper,
> consider planting trees first.
>
> Swiiings and roundabouts, my friend!

### Fallback

`ping`  
Heartbeat pulse only

### Optional logging

- CSV telemetry
- Response times
- Status and exit codes

Example:

```bash
./keepalive.sh -t 192.168.1.100 -l ./heartbeat.log
```

Produces:

```text
script,"./keepalive.sh","log initialized"
date,time,mode(c/p),target,status,http_code,exit_code,response_time
2026-05-18,01:00:02,c,"192.168.1.100","OK",307,0,0.195250
```

### Capacity planning for logging

Let's be realistic...

Current projections estimate approximately 10 MB of log growth
before the Sun burns out.

Infrastructure teams are monitoring the situation closely.

### Optional interactive mode

Use -i when staring at logs becomes emotionally exhausting.

Example:

```bash
./keepalive.sh -t 192.168.1.100 -i
```

Output:

```text
Patient: 192.168.1.100
Condition: stable
Diagnosis: OK
Vitals: HTTP=307 Response=0.037884s
```

Interactive mode can be combined with logging:

```bash
./keepalive.sh -t 192.168.1.100 -i -l ./heartbeat.log
```

Doctor speaks.  
Journal writes.

### Runtime behavior

Input errors:

- Display usage/help
- Show interactive guidance

Runtime events:

- Logging enabled → write runtime information to log
- Silent mode → exit code only
- Interactive mode → doctor-style status output

Log subsystem failures:

- stderr

### Docker

I wanted universal scripting and eventually thought:

*"Why the heck not?"*

Pop the hospital in a bag and take it with you.

Build:

```bash
docker build -t keepalive .
```

Run:

```bash
docker compose up -d
```

Example `docker-compose.yml`:

```yaml
services:
  keepalive:
    image: ghcr.io/eidodk/keepalive:latest
    container_name: keepalive
    restart: unless-stopped

    environment:
      TARGET: "192.168.1.100"
      INTERVAL: "21600"
      LOGFILE: "/tmp/heartbeat.log"

    # optional persistent logs:
    #
    # volumes:
    #   - ./logs:/data
    #
    # then set:
    #
    # LOGFILE: "/data/heartbeat.log"
```

Testing:

```bash
docker run --rm \
-e TARGET=192.168.1.100 \
-e INTERVAL=60 \
keepalive
```

Environment variables:

| Variable | Purpose | Default |
|---|---|---|
| `TARGET` | Appliance IP or URL | required |
| `INTERVAL` | Seconds between observations | `21600` |
| `LOGFILE` | Internal log path | `/tmp/heartbeat.log` |

Volumes are optional.

Without a mounted volume, logs remain inside the container and disappear
when the container is removed.

Example with persistent logs:

```bash
docker run -d \
-e TARGET=192.168.1.100 \
-e LOGFILE=/data/heartbeat.log \
-v ./logs:/data \
keepalive
```

Example without volumes:

```bash
docker run -d \
-e TARGET=192.168.1.100 \
keepalive
```

Docker allows multiple isolated keepalive instances:

```text
printer
NAS
camera
mysterious appliance in corner
```

One container per patient.

### Exit codes

- `0` = appliance reachable
- `1` = appliance problem
- `2–6` = script/runtime problem

---

> Deep sleep is a privilege, not a right.  
> Not even CPR is a blanket guarantee.

### Q/A

**Q: Why shell and not Go/C++/Rust?**

A: You don't optimize for elegance at 3am.  
   You optimize for "works on the weird box in the corner."

**Q: Why Docker?**

A: I wanted universal scripting and eventually thought:

   "Why the heck not?"
   Pop the hospital in a bag and take it with you.

**Q: Does this guarantee device availability?**

A: No.  
   This attempts to generate traffic and collect telemetry.  
   Some devices still wander into digital limbo anyway.

**Q: Can I specify a port?**

A: Yes.

Examples:

```bash
-t 192.168.1.100:9000
-t printer.local:8080
```

When specifying `host:port`, the service endpoint becomes the primary health target.

Ping fallback validates host reachability and may not behave as expected for `host:port` targets.

If a known service on a specific port stops responding, that is usually the condition you want to detect.

**Q: Why not ARP?**

A: Because heartbeat traffic and fallback behavior turned out to
   be more useful than assumptions.