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
# Runtime modes:
#   silent      -> exit codes only
#   interactive -> doctor-style output
#   logging     -> CSV telemetry
#
# Optional container deployment:
#   Docker-supported for portable appliance monitoring
#
# Optional identity:
#   KEEPALIVE_NAME -> source name written when log is initialized
#
# Exit codes:
#   0 = appliance reachable
#   1 = appliance problem
#   2-6 = script/runtime problem
#
# Deep sleep is a privilege, not a right.
# Not even CPR is a blanket guarantee.
##############################################################################

TIMEOUT=20

usage() {
    cat <<EOF
Universal network life support system

Deep sleep is a privilege, not a right
Not even CPR is a blanket guarantee!

Usage:    $0 -t TARGET [-l LOGFILE] [-i]
          (You can spell out --target, --log or --interactive)

Example:  $0 -t 192.168.1.100 [-l "./heartbeat.csv"]
          Swiiings and roundabouts, my friend!

curl:     response time + HTTP codes

ping:     universal fallback, heartbeat pulse only.

Note:     TARGET must NOT include http:// or https://
          No log means silent mode; use exit code for status.
          Use -i for interactive doctor-style status.
          Runtime output is written to log when enabled.
          KEEPALIVE_NAME may be used to identify the log source.

I may be a tool, but I am not an oracle.
Drama is for movies, not schedulers.
EOF
}

output_handling() {
    TYPE="$1"
    MSG="$2"
    CODE="$3"

    case "$TYPE" in
        user)
            usage >&2
            printf '\nERROR: %s\n' "$MSG" >&2
            exit "$CODE"
            ;;

        runtime)
            STATUS="$MSG"
            MODE="!"
            RC="$CODE"
            HTTP_CODE="N/A"
            TIME_TOTAL="N/A"
            ;;

        logsystem)
            printf 'ERROR: %s\n' "$MSG" >&2
            exit "$CODE"
            ;;
    esac
}

run_ping() {
# "You can check out anytime you want,
# but you can never leave."

    PING="${PING:-ping}"

    if ! command -v "$PING" >/dev/null 2>&1; then
        return 2
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
        #     O_o
        #    /|\
        #    / \
        #
        # Future me discovered that users can be... creative.
        #
        # Examples observed in the wild:
        #
        #   ./keepalive.sh -t
        #   ./keepalive.sh -i -t
        #   ./keepalive.sh -t -l -i
        #   ./keepalive.sh -i -t 192.168.1.100 -l
        #
        # Let's see if I can figure out what he means...
        #
        --target|-t)
            if [ "$#" -lt 2 ] || [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                output_handling user "-t requires a target value" 1
            fi

            URL="$2"
            shift 2
            ;;

        --log|-l)
            if [ "$#" -lt 2 ] || [ -z "$2" ] || [ "${2#-}" != "$2" ]; then
                output_handling user "-l requires a log filename" 1
            fi

            LOG="$2"
            shift 2
            ;;

        --interactive|-i)
            INTERACTIVE=1
            shift
            ;;

        --help|-h)
            usage
            exit 0
            ;;

        *)
            output_handling user "Unknown option: $1" 1
            ;;
    esac
done

if [ -z "$URL" ]; then
    output_handling user "Missing -t" 1
fi

case "$URL" in
    http://*|https://*)
        output_handling user "TARGET must not include http:// or https://" 6
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

INTERACTIVE="${INTERACTIVE:-0}"

if [ "$LOG" != "/dev/null" ]; then

    LOG_DIR="$(dirname "$LOG")"

    if [ ! -d "$LOG_DIR" ]; then
        output_handling logsystem "Log directory does not exist: $LOG_DIR" 3
    fi

    if [ ! -w "$LOG_DIR" ]; then
        output_handling logsystem "Log directory is not writable: $LOG_DIR" 4
    fi
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

    RESULT="$($CURL -s -o /dev/null \
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
                2)
                    output_handling runtime "Service failed, ping unavailable" 2
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
        0)
            STATUS="Ping OK"
            ;;
        2)
            output_handling runtime "curl and ping missing" 2
            ;;
        *)
            STATUS="Ping failed"
            ;;
    esac
fi

if [ ! -e "$LOG" ]; then

    if [ -n "$KEEPALIVE_NAME" ]; then
        LOG_SOURCE="$KEEPALIVE_NAME"
    elif command -v readlink >/dev/null 2>&1; then
        LOG_SOURCE="$(readlink -f "$0" 2>/dev/null || printf '%s\n' "$0")"
    else
        LOG_SOURCE="$0"
    fi

    if ! printf 'source,"%s","log initialized"\n' "$LOG_SOURCE" >> "$LOG"; then
        output_handling logsystem "Could not create log file: $LOG" 5
    fi

    if ! printf 'date,time,mode(c/p),target,status,http_code,exit_code,response_time\n' >> "$LOG"; then
        output_handling logsystem "Could not write log header: $LOG" 6
    fi
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
    output_handling logsystem "Could not write to log file: $LOG" 6
fi

case "$STATUS" in
    "OK"|"Ping OK"|"Service unavailable, network alive")
        EXIT_CODE=0
        ;;
    *)
        case "$RC" in
            2|3|4|5|6)
                EXIT_CODE="$RC"
                ;;
            *)
                EXIT_CODE=1
                ;;
        esac
        ;;
esac

if [ "$INTERACTIVE" = "1" ]; then
    case "$STATUS" in
        "OK"|"Ping OK"|"Service unavailable, network alive")
            printf 'Patient: %s\n' "$URL"
            printf 'Condition: stable\n'
            printf 'Diagnosis: %s\n' "$STATUS"

            if [ "$HTTP_CODE" != "N/A" ]; then
                printf 'Vitals: HTTP=%s Response=%ss\n' \
                    "$HTTP_CODE" "$TIME_TOTAL"
            fi
            ;;
        *)
            printf 'Patient: %s\n' "$URL"
            printf 'Condition: requires attention\n'
            printf 'Diagnosis: %s\n' "$STATUS"
            printf 'Exit code: %s\n' "$EXIT_CODE"
            ;;
    esac
fi

case "$STATUS" in
    "OK"|"Ping OK"|"Service unavailable, network alive")
        exit 0
        ;;
    *)
        case "$RC" in
            2|3|4|5|6)
                exit "$RC"
                ;;
            *)
                exit 1
                ;;
        esac
        ;;
esac
