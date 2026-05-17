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

### Exit codes

- `0` = appliance reachable
- `1` = appliance problem
- `2–6` = script/runtime problem

> Deep sleep is a privilege, not a right.  
> Not even CPR is a blanket guarantee.

```text
##############################################################################
# Universal network life support system
#
# Purpose:
# Attempts to generate small amounts of real network traffic to keep
# IP-connected appliances reachable during extended idle periods.
#
# Primary method:
#   curl  -> HTTP response + timing + stronger keepalive effect
#
# Fallback:
#   ping  -> heartbeat pulse only
#
# Optional logging:
# - CSV telemetry
# - response times
# - status and exit codes
#
# Exit codes:
#   0 = appliance reachable
#   1 = appliance problem
#   2-6 = script/runtime problem
#
# Deep sleep is a privilege, not a right.
# Not even CPR is a blanket guarantee.
##############################################################################
```
Q: Why shell and not Go/C++/Rust?

A: You don't optimize for elegance at 3am.
   You optimize for "works on the weird box in the corner."
