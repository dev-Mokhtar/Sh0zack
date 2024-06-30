#!/bin/bash

usage() {
    echo "Usage: $0 -u <url> -w <wordlist>"
    echo "Example: $0 -u https://example.com/wordlist.txt -w subdomains.txt"
    exit 1
}

custom_url=""
wordlist=""

while getopts "u:w:" opt; do
    case $opt in
        u) custom_url="$OPTARG";;
        w) wordlist="$OPTARG";;
        *) usage;;
    esac
done

if [ -z "$custom_url" ] || [ -z "$wordlist" ]; then
    usage
fi

check_wordlist() {
    if [ ! -f "$wordlist" ]; then
        echo "Downloading wordlist from $custom_url..."
        curl -sSL "$custom_url" -o "$wordlist"
    else
        echo "Using existing wordlist: $wordlist"
    fi
}

if [ $# -eq 0 ]; then
    usage
fi

domain="$1"

echo "Starting DNS subdomain enumeration on $domain..."
echo "================================================="

check_wordlist

dns_enum() {
    local subdomain="$1"
    local result=$(host "$subdomain.$domain" | grep 'has address' | awk '{print $1, $4}')
    if [ -n "$result" ]; then
        echo "$result"
    fi
}

print_results() {
    local subdomain="$1"
    local ip="$2"
    printf "| %-30s | %-15s |\n" "$subdomain" "$ip"
}

export -f dns_enum
export domain
xargs -P 50 -I {} -a "$wordlist" -n 1 bash -c 'dns_enum "$@"' _ {} | while read -r result; do
    if [ -n "$result" ]; then
        subdomain=$(echo "$result" | awk '{print $1}' | cut -d. -f1)
        ip=$(echo "$result" | awk '{print $2}')
        print_results "$subdomain" "$ip"
    fi
done

echo "================================================="
echo "DNS enumeration complete."
