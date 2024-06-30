#!/bin/bash

url=""
wordlist=""

usage() {
    echo "Usage: $0 -u <url> -w <wordlist>"
    echo "Example: $0 -u http://example.com -w /path/to/wordlist.txt"
    exit 1
}

while getopts "u:w:" opt; do
    case $opt in
        u) url="$OPTARG";;
        w) wordlist="$OPTARG";;
        *) usage;;
    esac
done

if [ -z "$url" ] || [ -z "$wordlist" ]; then
    usage
fi

dir_enum() {
    local endpoint="$1"
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url/$endpoint")
    if [ "$response" == "200" ]; then
        echo "| $(printf "%-50s" "$url/$endpoint") | Found |"
    elif [ "$response" == "401" ]; then
        echo "| $(printf "%-50s" "$url/$endpoint") | not allowed |"
    elif [ "$response" == "403" ]; then
        echo "| $(printf "%-50s" "$url/$endpoint") | Forbidden |"
    fi
}

enumerate() {
    local wordlist="$1"
    local total_lines=$(wc -l < "$wordlist")
    local counter=0
    local successful_count=0

    echo "| Directory                                          | Status               |"
    echo "|---------------------------------------------------------------|----------------------|"

    while IFS= read -r line; do
        dir_enum "$line" &
        ((counter++))

        if (( counter % 50 == 0 )); then
            wait
        fi
    done < "$wordlist"

    wait

    echo "=================================================================="
    echo "Directory enumeration complete. Processed $counter entries."
}

echo "Starting directory enumeration on $url using wordlist: $wordlist..."
echo "=================================================================="

enumerate "$wordlist"
