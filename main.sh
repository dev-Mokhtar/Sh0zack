#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'
BOLD='\033[1m'
NORMAL='\033[0m'
complete_path() {
    local IFS=$'\n'
    COMPREPLY=($(compgen -f -- "${COMP_WORDS[COMP_CWORD]}"))
}
complete -F complete_path read
display_main_menu() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║         ${CYAN}${BOLD}Sh0zack Tool Suite       ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}╚══════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${YELLOW}1. ${GREEN}${BOLD} Port Scanner${RESET}"
    echo -e "${YELLOW}2. ${GREEN}${BOLD} DNS Scanner${RESET}"
    echo -e "${YELLOW}3. ${GREEN}${BOLD} Directory Scanner${RESET}"
    echo -e "${YELLOW}4. ${GREEN}${BOLD} Brute Force${RESET}"
    echo -e "${YELLOW}5. ${GREEN}${BOLD} Listener${RESET}"
    echo -e "${YELLOW}6. ${GREEN}${BOLD} Privilege Escalation Check${RESET}"
    echo -e "${YELLOW}7. ${GREEN}${BOLD} Shell Generator${RESET}"
    echo -e "${YELLOW}8. ${GREEN}${BOLD} Monitor Cronjob${RESET}"

    echo -e "${YELLOW}9. ${RED}${BOLD} Exit${RESET}"
    echo ""
}

run_port_scanner() {
    echo -e "${YELLOW}Port Scanner${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Nmap${RESET}"
    echo -e "${GREEN}2. Rustscan${RESET}"
    echo -e "${GREEN}3. Shozack Port Scan Tool${RESET}"
    read -p "Enter your choice: " tool_choice

    read -p "Enter target: " target
    if [ "$tool_choice" -eq 1 ]; then
        echo -e "${BLUE}Example Nmap usage: nmap -sV -p 1-65535 $target${RESET}"
        read -p "Enter Nmap command options: " nmap_options
        nmap $nmap_options $target
    elif [ "$tool_choice" -eq 2 ]; then
        echo -e "${BLUE}Example Rustscan usage: rustscan -a $target --ulimit 5000 -- -sV${RESET}"
        read -p "Enter Rustscan command options: " rustscan_options
        rustscan $rustscan_options $target
    elif [ "$tool_choice" -eq 3 ]; then
        echo -e "${BLUE}Example Shozack Port Scan Tool usage: ./tools/port-scanner.sh $target${RESET}"
        read -p "Enter Shozack Port Scan Tool options: " shozack_options
        ./tools/port-scanner.sh $target $shozack_options
    else
        echo -e "${RED}Invalid option.${RESET}"
    fi
}
run_dns_scanner() {
    echo -e "${YELLOW}DNS Scanner${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Gobuster${RESET}"
    echo -e "${GREEN}2. Advanced Sh0zack DNS Scan Tool${RESET}"
    read -p "Enter your choice: " tool_choice
    read -p "Enter URL: " url
    read -e -p "Enter path to wordlist (leave empty for default): " wordlist
    if [ -z "$url" ];then
        echo -e "\n${RED} $BOLD You didn't provide a target URL , No scanning for you :(  ${RESET}"
        return
    fi

    if [ -z "$wordlist" ]; then
        default_wordlist="tools/default_subdomains.txt"
        if [ ! -f "$default_wordlist" ]; then

            if ! which curl >/dev/null 2>&1; then
                if [ "$EUID" -ne 0 ]; then
                echo "run as root" &&  exit 1 # just to ensure u get curl on ur machine
                fi
                echo "curl not found, installing..."
                sudo apt-get install -y curl
            fi
            echo -e "${YELLOW}Default wordlist not found. Downloading...${RESET}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-5000.txt" -o "$default_wordlist"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Failed to download default wordlist. Please provide a wordlist you have locally.${RESET}"
                return
            fi
            echo -e "${GREEN}Default wordlist downloaded successfully.${RESET}"
        else
            echo -e "${GREEN}Using existing default wordlist.${RESET}"
        fi
        wordlist="$default_wordlist"
    elif [ ! -f "$wordlist" ]; then
        echo -e "${RED}Error: Wordlist file not found.${RESET}"
        return
    fi

    case $tool_choice in
        1)
            echo -e "${BLUE}Running Gobuster...${RESET}"
            echo -e "${BLUE}Your Gobuster usage: gobuster dns -d $url -w $wordlist${RESET}"
            gobuster dns -d "$url" -w "$wordlist"
            ;;
        2)
            echo -e "${BLUE}Running Advanced Sh0zack DNS Scan Tool...${RESET}"
            read -p "Enter number of threads (default: 50): " threads
            read -p "Enter timeout in seconds (default: 5): " timeout
            read -p "Resolve IP addresses? (y/n, default: y): " resolve_ip
            read -p "Enable verbose mode? (y/n, default: n): " verbose
            read -p "Enter output file name (default: subdomain_results.txt): " output_file

            threads=${threads:-50}
            timeout=${timeout:-5}
            resolve_ip=${resolve_ip:-y}
            verbose=${verbose:-n}
            output_file=${output_file:-subdomain_results.txt}

            cmd_args="-u '$url' -w '$wordlist' -o '$output_file' -t $threads -T $timeout"
            [ "$resolve_ip" = "n" ] && cmd_args="$cmd_args -n"
            [ "$verbose" = "y" ] && cmd_args="$cmd_args -v"

            echo -e "${BLUE}Running command: ./tools/dns.sh $cmd_args${RESET}"
            eval "./tools/dns.sh $cmd_args"
            ;;
        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
    esac
#  you can uncomment this if you wanna delete the file after downloading it
#     if [ "$wordlist" = "tools/default_subdomains.txt" ]; then
#         rm "$wordlist"
#     fi
}
run_dir_scanner() {
    echo -e "${YELLOW}Directory Scanner${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Gobuster${RESET}"
    echo -e "${GREEN}2. WFuzz${RESET}"
    echo -e "${GREEN}3. Advanced Sh0zack Directory Scan Tool${RESET}"
    read -p "Enter your choice: " tc
    read -p "Enter URL: " url
    read -e -p "Enter path to wordlist (leave empty for default): " wl

    if [ -z "$url" ]; then
        echo -e "\n${RED}${BOLD}You didn't provide a target URL. No scanning for you :( ${RESET}"
        return
    fi

    if [ -z "$wl" ]; then
        dw="tools/default_dirlist.txt"
        if [ ! -f "$dw" ]; then
            if ! which curl >/dev/null 2>&1; then
                if [ "$EUID" -ne 0 ]; then
                    echo -e "${RED}Run as root${RESET}" && exit 1
                fi
                echo -e "${YELLOW}curl not found, installing...${RESET}"
                sudo apt-get install -y curl
            fi
            echo -e "${YELLOW}Default wordlist not found. Downloading...${RESET}"
            curl -s "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/common.txt" -o "$dw"
            if [ $? -ne 0 ]; then
                echo -e "${RED}Failed to download default wordlist. Please provide a wordlist you have locally.${RESET}"
                return
            fi
            echo -e "${GREEN}Default wordlist downloaded successfully.${RESET}"
        else
            echo -e "${GREEN}Using existing default wordlist.${RESET}"
        fi
        wl="$dw"
    elif [ ! -f "$wl" ]; then
        echo -e "${RED}Error: Wordlist file not found.${RESET}"
        return
    fi

    case $tc in
        1)
            echo -e "${BLUE}Running Gobuster...${RESET}"
            echo -e "${BLUE}Your Gobuster usage: gobuster dir -u $url -w $wl${RESET}"
            gobuster dir -u "$url" -w "$wl"
            ;;
        2)
            echo -e "${BLUE}Running WFuzz...${RESET}"
            echo -e "${BLUE}Your WFuzz usage: wfuzz -c -z file,$wl --hc 404 $url/FUZZ${RESET}"
            wfuzz -c -z file,$wl --hc 404 "$url/FUZZ"
            ;;
        3)
            echo -e "${BLUE}Running Advanced Sh0zack Directory Scan Tool...${RESET}"
            read -p "Enter number of threads (default: 50): " thrd
            read -p "Enter timeout in seconds (default: 5): " to
            read -p "Enable verbose mode? (y/n, default: n): " vb
            read -p "Enter output file name (default: dir_results.txt): " of

            thrd=${thrd:-50}
            to=${to:-5}
            vb=${vb:-n}
            of=${of:-dir_results.txt}

            ca="-u '$url' -w '$wl' -o '$of' -t $thrd -T $to"
            [ "$vb" = "y" ] && ca="$ca -v"

            echo -e "${BLUE}Running command: ./tools/dir.sh $ca${RESET}"
            eval "./tools/dir.sh $ca"
            ;;
        *)
            echo -e "${RED}Invalid option.${RESET}"
            ;;
    esac
}


run_brute_force() {
    echo -e "${YELLOW}Brute Force${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Hydra${RESET}"
    echo -e "${GREEN}2. Shozack Brute Force Tool${RESET}"
    read -p "Enter your choice: " tool_choice

    read -p "Enter target: " target
    read -e -p "Enter path to user wordlist: " user_wordlist
    read -e -p "Enter path to password wordlist: " pass_wordlist
    read -p "Enter number of threads: " threads
    read -p "Enter service (e.g., ssh, ftp): " service
    read -p "Enter port (optional): " port
    read -e -p "Enter path to output file (optional): " output_file

    if [ "$tool_choice" -eq 1 ]; then
        echo -e "${BLUE}Example Hydra usage: hydra -L $user_wordlist -P $pass_wordlist -t $threads $service://$target${RESET}"
        hydra -L $user_wordlist -P $pass_wordlist -t $threads $service://$target
    elif [ "$tool_choice" -eq 2 ]; then
        echo -e "${BLUE}Example Shozack Brute Force Tool usage: ./tools/brute-force.sh -t $target -u $user_wordlist -p $pass_wordlist -T $threads -s $service${RESET}"
        ./tools/brute-force.sh -t $target -u $user_wordlist -p $pass_wordlist -T $threads -s $service
    else
        echo -e "${RED}Invalid option.${RESET}"
    fi
}

run_listener() {
    echo -e "${YELLOW}Listener${RESET}"
    ./tools/listener.sh
}

run_privesc_check() {
    echo -e "${YELLOW}Privilege Escalation Check${RESET}"
    ./tools/privesc.sh
}

run_shell_generator() {
    echo -e "${YELLOW}Shell Generator${RESET}"
    ./tools/shell-generator.sh
}

run_monitor_cronjob() {
    echo -e "${YELLOW}Monitor Cronjob${RESET}"
    ./tools/monitor-cronjob.sh
}

while true; do
    display_main_menu
    read -p "Enter your choice: " choice

    case $choice in
        1) run_port_scanner ;;
        2) run_dns_scanner ;;
        3) run_dir_scanner ;;
        4) run_brute_force ;;
        5) run_listener ;;
        6) run_privesc_check ;;
        7) run_shell_generator ;;
        8) run_monitor_cronjob ;;
        9) echo -e "${RED}Exiting Shozack !!!${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Repeat your choice.${RESET}" ;;
    esac

    echo
    read -p "Press enter to continue..."
done
