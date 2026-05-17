#!/usr/bin/env sh

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
##############################################################################
TIMEOUT=20

usage() {
    cat <<EOF
Universal network life support system

Deep sleep is a privilege, not a right
Not even CPR is a blanket guarantee!

Usage:    $0 -t TARGET [-l LOGFILE]
          (You can spell out --target or --log, but smart lazy is still smart)

Example:  $0 -t 192.168.1.100 [-l "./heartbeat.log"]
          Swiiings and roundabouts, my friend!

curl:     response time + HTTP codes

ping:     universal fallback, heartbeat pulse only.
		   
Note:     TARGET must NOT include http:// or https://
          No log means silent mode; use exit code for status.
          Runtime output is written to log when enabled.
 
I may be a tool, but I am not an oracle.
Drama is for movies, not schedulers.
EOF
}

run_ping() {
# "You can check out anytime you want,
# but you can never leave."
    	
	PING="${PING:-ping}"

    if ! command -v "$PING" >/dev/null 2>&1; then
        return 127
    fi

    HOST="$URL"

    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*|CYGWIN*)
            PING_COUNT="-n"
            ;;
        *)
            PING_COUNT="-c"
            ;;
    esac

    PING_OUT="$("$PING" "$PING_COUNT" 1 "$HOST" 2>/dev/null)"
    PING_RC=$?
    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*|CYGWIN*)
            printf '%s\n' "$PING_OUT" | grep -q "Reply from $HOST: bytes="
            return $?
            ;;
        *)
            return "$PING_RC"
            ;;
    esac
}

if [ "$#" -eq 0 ]; then
    usage
    exit 1
fi

while [ "$#" -gt 0 ]; do
    case "$1" in
        --target|-t)
            URL="$2"
            shift 2
            ;;
        --log|-l)
            LOG="$2"
            shift 2
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            usage >&2
            printf '\nERROR: Unknown option: %s\n' "$1" >&2
            exit 1
            ;;
    esac
done

if [ -z "$URL" ]; then
    usage >&2
    printf '\nERROR: Missing -t\n' >&2
    exit 1
fi

case "$URL" in
    http://*|https://*)
        usage >&2
        printf '\nERROR: TARGET must not include http:// or https://\n' >&2
        exit 1
        ;;
esac

#   o
#  /|\
#  / \
# LOGGING?
# Who cares about the past.
# I'm here to poke things NOW.

if [ -z "$LOG" ]; then
    LOG="/dev/null"
fi

LOG_DIR="$(dirname "$LOG")"

if [ ! -d "$LOG_DIR" ]; then
    printf 'ERROR: Log directory does not exist: %s\n' "$LOG_DIR" >&2
    exit 3
fi

if [ ! -w "$LOG_DIR" ]; then
    printf 'ERROR: Log directory is not writable: %s\n' "$LOG_DIR" >&2
    exit 4
fi

DATE="$(date '+%Y-%m-%d')"
TIME="$(date '+%H:%M:%S')"

#   o
#  /|\
#  / \
# Hmm...
# "Let's see if curl is around..."

CURL="${CURL:-curl}"

if command -v "$CURL" >/dev/null 2>&1; then

    # \o/
    #  |
    # / \
    # WHEE, BONUS!
    #
    # curl used for stronger keepalive effect.

    MODE="c"

    CURL_URL="http://$URL"

    RESULT="$($CURL -k -s -o /dev/null \
        -w "%{http_code} %{time_total}" \
        --max-time "$TIMEOUT" \
        "$CURL_URL" 2>/dev/null)"

    RC=$?

    HTTP_CODE="$(printf '%s\n' "$RESULT" | awk '{print $1}')"
    TIME_TOTAL="$(printf '%s\n' "$RESULT" | awk '{print $2}')"

# Appliance:
# "You can check out anytime you want,
# but you can never leave."

    case "$RC" in
        0)
            STATUS="OK"
            ;;
        6)
            STATUS="DNS lookup failed"
            ;;
        7|28|52|56)
            # Sonar detecting entity, entity identified!

            run_ping
            PING_RC=$?

            case "$PING_RC" in

                0)
                    STATUS="Service unavailable, network alive"
                    MODE="p"
                    ;;
                127)
                    STATUS="Service failed, ping unavailable"
                    ;;
                *)
                    case "$RC" in
                        7)  STATUS="Connection failed" ;;
                        28) STATUS="Timeout or URL mismatch" ;;
                        52) STATUS="Empty reply from server" ;;
                        56) STATUS="Connection interrupted" ;;
                    esac
                    ;;
            esac
            ;;
        *)
            STATUS="Unknown error"
            ;;
    esac

else

    #   o
    #  /|\
    #  / \
    # COB:
    # "One ping only, please"

    #   _o_
    #    |
    #   / \

    MODE="p"

    run_ping
    RC=$?

    HTTP_CODE="N/A"
    TIME_TOTAL="N/A"

    case "$RC" in
        0)   STATUS="Ping OK" ;;
        127)
             usage >&2
             printf '\n\nWHOOPS, curl AND ping missing.\n\n' >&2
             printf 'Invisibility is a skill, not a tool!\n' >&2
             exit 2
             ;;
        *)   STATUS="Ping failed" ;;
    esac
fi

if [ ! -f "$LOG" ]; then

    if command -v readlink >/dev/null 2>&1; then
        SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || printf '%s\n' "$0")"
    else
        SCRIPT_PATH="$0"
    fi

    if ! printf 'script,"%s","log initialized"\n' "$SCRIPT_PATH" >> "$LOG"; then
        printf 'ERROR: Could not create log file: %s\n' "$LOG" >&2
        exit 5
    fi

    printf 'date,time,mode(c/p),target,status,http_code,exit_code,response_time\n' >> "$LOG"
fi

   #    o
   #   /|\
   #   / \
   #  _/ \_
   #
   # Alright...
   # Data finally collected.
   # Burying deep in logs!

if ! printf '%s,%s,%s,"%s","%s",%s,%s,%s\n' \
    "$DATE" \
    "$TIME" \
    "$MODE" \
    "$URL" \
    "$STATUS" \
    "$HTTP_CODE" \
    "$RC" \
    "$TIME_TOTAL" >> "$LOG"
then
    printf 'ERROR: Could not write to log file: %s\n' "$LOG" >&2
    exit 6
fi

case "$STATUS" in
    "OK"|"Ping OK"|"Service unavailable, network alive")
        exit 0
        ;;
    *)
        exit 1
        ;;
esac
