#!/usr/bin/env bash

# ============================================================
# URL Information Gathering Tool
# Usage:
#   ./urlinfo.sh https://example.com
#
# Optional:
#   ./urlinfo.sh -t https://example.com
#      -> ajoute traceroute
# ============================================================

set -u

URL=""
DO_TRACE=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -t|--trace)
            DO_TRACE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-t|--trace] <URL>"
            exit 0
            ;;
        *)
            URL="$1"
            shift
            ;;
    esac
done

if [[ -z "$URL" ]]; then
    echo "Usage: $0 [-t|--trace] <URL>"
    exit 1
fi

# ------------------------------------------------------------
# Vérification des outils
# ------------------------------------------------------------

TOOLS=(
    curl
    dig
    host
    whois
    openssl
    awk
    sed
    grep
)

echo "Checking required tools..."

for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "[WARNING] $tool is not installed"
    fi
done

# ------------------------------------------------------------
# Normalisation URL
# ------------------------------------------------------------

if [[ "$URL" != http://* && "$URL" != https://* ]]; then
    URL="https://$URL"
fi

DOMAIN=$(echo "$URL" | sed -E 's#https?://([^/:]+).*#\1#')
PATH_URL=$(echo "$URL" | sed -E "s#https?://$DOMAIN##")

if [[ -z "$PATH_URL" ]]; then
    PATH_URL="/"
fi

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo
echo "============================================================"
echo " URL INFORMATION REPORT"
echo "============================================================"
echo "URL       : $URL"
echo "Domain    : $DOMAIN"
echo "Path      : $PATH_URL"
echo "Date      : $TIMESTAMP"
echo "============================================================"


# ============================================================
# DNS
# ============================================================

echo
echo "============================================================"
echo " DNS INFORMATION"
echo "============================================================"

if command -v dig >/dev/null 2>&1; then

    echo
    echo "--- A records ---"
    dig +short A "$DOMAIN"

    echo
    echo "--- AAAA records ---"
    dig +short AAAA "$DOMAIN"

    echo
    echo "--- CNAME ---"
    dig +short CNAME "$DOMAIN"

    echo
    echo "--- MX ---"
    dig +short MX "$DOMAIN"

    echo
    echo "--- NS ---"
    dig +short NS "$DOMAIN"

    echo
    echo "--- TXT ---"
    dig +short TXT "$DOMAIN"

    echo
    echo "--- SOA ---"
    dig +short SOA "$DOMAIN"

else
    echo "dig not installed"
fi


# ============================================================
# IP addresses
# ============================================================

echo
echo "============================================================"
echo " IP ADDRESSES"
echo "============================================================"

IPS=()

if command -v dig >/dev/null 2>&1; then
    while read -r ip; do
        [[ -n "$ip" ]] && IPS+=("$ip")
    done < <(dig +short A "$DOMAIN" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')

    while read -r ip; do
        [[ -n "$ip" ]] && IPS+=("$ip")
    done < <(dig +short AAAA "$DOMAIN")
fi

printf '%s\n' "${IPS[@]}" | sort -u


# ============================================================
# Reverse DNS
# ============================================================

echo
echo "============================================================"
echo " REVERSE DNS"
echo "============================================================"

for IP in "${IPS[@]}"; do

    echo
    echo "--- $IP ---"

    if command -v host >/dev/null 2>&1; then
        host "$IP"
    else
        echo "host command not available"
    fi

done


# ============================================================
# WHOIS DOMAIN
# ============================================================

echo
echo "============================================================"
echo " DOMAIN WHOIS"
echo "============================================================"

if command -v whois >/dev/null 2>&1; then

    whois "$DOMAIN" 2>/dev/null |
        grep -Ei \
        '^(Domain Name|Registry Domain ID|Registrar|Registrar IANA ID|Registrar URL|Creation Date|Updated Date|Registry Expiry Date|Registrar Registration Expiration Date|Name Server|Registrant Organization|Registrant Country|Status):'

else
    echo "whois not installed"
fi


# ============================================================
# RDAP
# ============================================================

echo
echo "============================================================"
echo " RDAP"
echo "============================================================"

echo "Querying RDAP..."

RDAP=$(curl -L -s \
    --max-time 10 \
    -H "Accept: application/rdap+json" \
    "https://rdap.org/domain/$DOMAIN" 2>/dev/null)

if [[ -n "$RDAP" ]]; then
    echo "$RDAP" | sed 's/,/,\n/g' | head -100
else
    echo "No RDAP information available"
fi


# ============================================================
# HTTP HEADERS
# ============================================================

echo
echo "============================================================"
echo " HTTP HEADERS"
echo "============================================================"

if command -v curl >/dev/null 2>&1; then

    curl \
        -k \
        -I \
        -L \
        --max-time 15 \
        -A "Mozilla/5.0 URLInfo/1.0" \
        "$URL" 2>/dev/null

fi


# ============================================================
# HTTP RESPONSE
# ============================================================

echo
echo "============================================================"
echo " HTTP INFORMATION"
echo "============================================================"

HTTP_INFO=$(curl \
    -k \
    -L \
    -s \
    -o /dev/null \
    -w 'HTTP_CODE=%{http_code}\n\
REMOTE_IP=%{remote_ip}\n\
REMOTE_PORT=%{remote_port}\n\
LOCAL_IP=%{local_ip}\n\
LOCAL_PORT=%{local_port}\n\
HTTP_VERSION=%{http_version}\n\
SSL_VERIFY=%{ssl_verify_result}\n\
TIME_CONNECT=%{time_connect}\n\
TIME_STARTTRANSFER=%{time_starttransfer}\n\
TIME_TOTAL=%{time_total}\n\
SIZE_DOWNLOAD=%{size_download}\n\
CONTENT_TYPE=%{content_type}\n\
URL_EFFECTIVE=%{url_effective}\n' \
    --max-time 20 \
    "$URL" 2>/dev/null)

echo "$HTTP_INFO"


# ============================================================
# SERVER / TECHNOLOGIES
# ============================================================

echo
echo "============================================================"
echo " SERVER / TECHNOLOGY HINTS"
echo "============================================================"

HEADERS=$(curl \
    -k \
    -s \
    -I \
    -L \
    --max-time 15 \
    "$URL" 2>/dev/null)

echo "$HEADERS" |
    grep -Ei \
    '^(server|x-powered-by|x-generator|via|x-cache|x-served-by|cf-ray|cf-cache-status|x-amz-|x-drupal-|x-varnish|set-cookie):'


# ============================================================
# TLS CERTIFICATE
# ============================================================

echo
echo "============================================================"
echo " TLS / SSL CERTIFICATE"
echo "============================================================"

if [[ "$URL" == https://* ]]; then

    IP=$(printf '%s\n' "${IPS[@]}" | head -1)

    if [[ -n "${IP:-}" ]]; then

        echo
        echo "--- Certificate subject ---"

        echo | openssl s_client \
            -connect "$DOMAIN:443" \
            -servername "$DOMAIN" \
            -showcerts \
            2>/dev/null |
            openssl x509 \
            -noout \
            -subject \
            -issuer \
            -serial \
            -dates \
            -fingerprint \
            -sha256

        echo
        echo "--- Subject Alternative Names ---"

        echo | openssl s_client \
            -connect "$DOMAIN:443" \
            -servername "$DOMAIN" \
            2>/dev/null |
            openssl x509 \
            -noout \
            -text 2>/dev/null |
            grep -A2 "Subject Alternative Name"

    fi

else
    echo "URL is not HTTPS"
fi


# ============================================================
# IP GEOLOCATION
# ============================================================

echo
echo "============================================================"
echo " IP GEOLOCATION"
echo "============================================================"

for IP in $(printf '%s\n' "${IPS[@]}" | sort -u); do

    echo
    echo "--- $IP ---"

    GEO=$(curl \
        -s \
        --max-time 10 \
        "https://ipinfo.io/$IP/json" 2>/dev/null)

    if [[ -n "$GEO" ]]; then
        echo "$GEO"
    else
        echo "No geolocation information"
    fi

done


# ============================================================
# ASN / NETWORK
# ============================================================

echo
echo "============================================================"
echo " ASN / NETWORK"
echo "============================================================"

for IP in $(printf '%s\n' "${IPS[@]}" | sort -u); do

    echo
    echo "--- $IP ---"

    curl \
        -s \
        --max-time 10 \
        "https://ipinfo.io/$IP/json" 2>/dev/null |
        grep -E '"(org|asn|hostname|city|region|country|loc|postal|timezone)"'

done


# ============================================================
# ROBOTS.TXT
# ============================================================

echo
echo "============================================================"
echo " ROBOTS.TXT"
echo "============================================================"

curl \
    -k \
    -L \
    -s \
    --max-time 10 \
    "https://$DOMAIN/robots.txt" 2>/dev/null |
    head -100


# ============================================================
# SECURITY HEADERS
# ============================================================

echo
echo "============================================================"
echo " SECURITY HEADERS"
echo "============================================================"

echo "$HEADERS" |
    grep -Ei \
    '^(strict-transport-security|content-security-policy|x-frame-options|x-content-type-options|referrer-policy|permissions-policy|cross-origin-|access-control-allow-origin):'


# ============================================================
# TRACE ROUTE
# ============================================================

if [[ "$DO_TRACE" == true ]]; then

    echo
    echo "============================================================"
    echo " NETWORK TRACE"
    echo "============================================================"

    if command -v traceroute >/dev/null 2>&1; then
        traceroute "$DOMAIN"
    elif command -v tracepath >/dev/null 2>&1; then
        tracepath "$DOMAIN"
    else
        echo "Neither traceroute nor tracepath is installed"
    fi

fi


# ============================================================
# FINAL SUMMARY
# ============================================================

echo
echo "============================================================"
echo " SUMMARY"
echo "============================================================"

echo "URL       : $URL"
echo "Domain    : $DOMAIN"

echo
echo "IP(s):"
printf '%s\n' "${IPS[@]}" | sort -u

echo
echo "Generated : $TIMESTAMP"

echo
echo "============================================================"
echo " END"
echo "============================================================"