#!/bin/bash

# if [ "$EUID" -ne 0 ]; then
#     echo "Please run as root"
#     exit 1
# fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 <target> [-u for UDP Scan]"
    exit 1
fi

target="$1"
timeout=2
max_processes=1
do_udp_scan=false

if [[ "$2" == "-u" ]]; then
    do_udp_scan=true
fi

get_domain_info() {
    local domain="$1"
    echo "Domain: $domain"
    local ip=$(host -t A $domain | awk '/has address/ { print $4; exit }')
    echo "IP Address: $ip"
#     local whois_info=$(whois $domain | grep -E "Registrar:|Creation Date:|Updated Date:|Expiration Date:" | sed 's/^[ \t]*//')
#     echo "$whois_info"
}

os_fingerprint() {
    local ip="$1"
    local ttl=$(ping -c 1 -W 1 $ip 2>/dev/null | awk -F'ttl=' '/ttl=/{print $2}' | cut -d' ' -f1)
    if [ -z "$ttl" ]; then
        echo "OS: Unable to determine (host might be down or blocking ICMP)"
    elif [ "$ttl" -le 64 ]; then
        echo "OS: Likely Linux/Unix (TTL: $ttl)"
    elif [ "$ttl" -le 128 ]; then
        echo "OS: Likely Windows (TTL: $ttl)"
    else
        echo "OS: Unknown (TTL: $ttl)"
    fi
}

get_detailed_info() {
    local port="$1"
    local proto="$2"
    local service=$(grep -w "$port/$proto" /etc/services 2>/dev/null | awk '{print $1}' | head -1)
    local banner=""
    local version_info=""
    local ssl_info=""
    local http_info=""

    if [[ "$proto" == "tcp" ]]; then
        banner=$(timeout $timeout nc -w1 -v $target $port </dev/null 2>&1 | grep -v "Connection to" | tr -d '\0' | tr -d '\r' | tr '\n' ' ' | cut -c 1-100)
        version_info=$(nmap -p$port -sV --version-intensity 2 $target 2>/dev/null | awk -v port="$port" '$1 == port {$1=""; $2=""; print $0}' | sed 's/^[ \t]*//')

        if echo | openssl s_client -connect $target:$port -quiet 2>/dev/null | grep -q "BEGIN CERTIFICATE"; then
            ssl_info=$(openssl s_client -connect $target:$port -quiet 2>/dev/null | openssl x509 -noout -subject -issuer | tr '\n' ' ')
        fi

        if [[ "$service" == "http" || "$port" == "80" || "$port" == "8080" ]]; then
            http_info=$(curl -sI -m $timeout "http://$target:$port" | grep -E "Server:|X-Powered-By:" | tr -d '\r' | tr '\n' ' ')
        elif [[ "$service" == "https" || "$port" == "443" || "$port" == "8443" ]]; then
            http_info=$(curl -sI -m $timeout "https://$target:$port" | grep -E "Server:|X-Powered-By:" | tr -d '\r' | tr '\n' ' ')
        fi
    fi

    echo "Port: $port"
    echo "Protocol: $proto"
    echo "Service: ${service:-Unknown}"
    [ ! -z "$version_info" ] && echo "Version Info: $version_info"
    [ ! -z "$banner" ] && echo "Banner: $banner"
    [ ! -z "$ssl_info" ] && echo "SSL Info: $ssl_info"
    [ ! -z "$http_info" ] && echo "HTTP Info: $http_info"
    echo "----------------------------------------"
}

scan_port() {
    local port=$1
    local proto=$2
    if timeout $timeout bash -c "echo >/dev/$proto/$target/$port" 2>/dev/null ||
       nc -z -w $timeout $target $port 2>/dev/null; then
        echo "$port open ($proto)"
    fi
}

echo "Starting comprehensive scan on $target..."
echo "=========================================="

# Get domain and IP information
get_domain_info $target

# Get OS fingerprint
os_fingerprint $target
echo


common_ports=(21 22 23 25 53 80 110 111 135 139 143 443 445 993 995 1723 3306 3389 5900 8080
              8443 8888 9418 27017 27018 50000 50070 50075 5432 5672 6379 7001 7002 8000 8001
              8005 8081 8088 8090 8091 8444 8880 8883 9000 9001 9042 9060 9080 9092 9200 9300
              9999 11211 15672 18080 19888 27016 50030 50060 50090 5044 5601 6000 7007 7180
              7443 7777 8002 8060 8082 8089 8099 8123 8181 8383 8744 8889 8983 9002 9069 9090
              9207 9306 9443 9800 9990 10000 11300 14222 14444 16010 18081 19000 19889 27015
              27019 34443 50070 51111 54321 55555 55672 60010 60030 61440 65535)

echo "Scanning common TCP ports..."
for port in "${common_ports[@]}"; do
    scan_port $port "tcp" &
done
wait

echo "Scanning remaining TCP ports (1-65535)..."
for ((port=1; port<=65535; port++)); do
    if ! [[ " ${common_ports[@]} " =~ " ${port} " ]]; then
        scan_port $port "tcp" &
        while [ $(jobs -r | wc -l) -ge $max_processes ]; do
            sleep 0.0001
        done
    fi
done
wait

if $do_udp_scan; then
    echo "Scanning UDP ports (1-65535)..."
    for ((port=1; port<=65535; port++)); do
        scan_port $port "udp" &
        while [ $(jobs -r | wc -l) -ge $max_processes ]; do
            sleep 0.1
        done
    done
    wait
fi

echo "Scan complete."
