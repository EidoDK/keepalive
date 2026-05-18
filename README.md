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

### Optional interactive mode

Provides human-readable doctor-style status output.

Example:

```bash
./keepalive.sh -t 192.168.1.100 -i
```

Output:

```text
Doctor:
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
   
**Q: Does this guarantee device availability?**

A: No.

This attempts to generate traffic and collect telemetry.
Some devices still wander into digital limbo anyway.

**Q: Why not ARP?**

A: Because heartbeat traffic and fallback behavior turned out to be
more useful than assumptions and less dependent on implementation details.