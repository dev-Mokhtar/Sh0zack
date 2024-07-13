#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

display_main_menu() {
    clear
    echo -e "${MAGENTA}╔══════════════════════════════════╗${RESET}"
    echo -e "${MAGENTA}║         ${CYAN}Shozack Tool Suite       ${MAGENTA}║${RESET}"
    echo -e "${MAGENTA}╚══════════════════════════════════╝${RESET}"
    echo -e "${YELLOW}1. ${GREEN}Port Scanner${RESET}"
    echo -e "${YELLOW}2. ${GREEN}DNS Scanner${RESET}"
    echo -e "${YELLOW}3. ${GREEN}Directory Scanner${RESET}"
    echo -e "${YELLOW}4. ${GREEN}Brute Force${RESET}"
    echo -e "${YELLOW}5. ${GREEN}Listener${RESET}"
    echo -e "${YELLOW}6. ${GREEN}Privilege Escalation Check${RESET}"
    echo -e "${YELLOW}7. ${GREEN}Shell Generator${RESET}"
    echo -e "${YELLOW}8. ${GREEN}Monitor Cronjob${RESET}"
    echo -e "${YELLOW}9. ${RED}Exit${RESET}"
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
    echo -e "${GREEN}2. Shozack DNS Scan Tool${RESET}"
    read -p "Enter your choice: " tool_choice

    read -p "Enter URL: " url
    read -p "Enter path to wordlist: " wordlist
    if [ "$tool_choice" -eq 1 ]; then
        echo -e "${BLUE}Example Gobuster usage: gobuster dns -d $url -w $wordlist${RESET}"
        gobuster dns -d $url -w $wordlist
    elif [ "$tool_choice" -eq 2 ]; then
        echo -e "${BLUE}Example Shozack DNS Scan Tool usage: ./tools/dns.sh -u $url -w $wordlist${RESET}"
        ./tools/dns.sh -u $url -w $wordlist
    else
        echo -e "${RED}Invalid option.${RESET}"
    fi
}

run_dir_scanner() {
    echo -e "${YELLOW}Directory Scanner${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Gobuster${RESET}"
    echo -e "${GREEN}2. WFuzz${RESET}"
    echo -e "${GREEN}3. Shozack Directory Scan Tool${RESET}"
    read -p "Enter your choice: " tool_choice

    read -p "Enter URL: " url
    read -p "Enter path to wordlist: " wordlist
    if [ "$tool_choice" -eq 1 ]; then
        echo -e "${BLUE}Example Gobuster usage: gobuster dir -u $url -w $wordlist${RESET}"
        gobuster dir -u $url -w $wordlist
    elif [ "$tool_choice" -eq 2 ]; then
        echo -e "${BLUE}Example WFuzz usage: wfuzz -c -z file,$wordlist --hc 404 $url/FUZZ${RESET}"
        wfuzz -c -z file,$wordlist --hc 404 $url/FUZZ
    elif [ "$tool_choice" -eq 3 ]; then
        echo -e "${BLUE}Example Shozack Directory Scan Tool usage: ./tools/dir.sh -u $url -w $wordlist${RESET}"
        ./tools/dir.sh -u $url -w $wordlist
    else
        echo -e "${RED}Invalid option.${RESET}"
    fi
}

run_brute_force() {
    echo -e "${YELLOW}Brute Force${RESET}"
    echo -e "${YELLOW}Choose tool to use:${RESET}"
    echo -e "${GREEN}1. Hydra${RESET}"
    echo -e "${GREEN}2. Shozack Brute Force Tool${RESET}"
    read -p "Enter your choice: " tool_choice

    read -p "Enter target: " target
    read -p "Enter path to user wordlist: " user_wordlist
    read -p "Enter path to password wordlist: " pass_wordlist
    read -p "Enter number of threads: " threads
    read -p "Enter service (e.g., ssh, ftp): " service
    read -p "Enter port (optional): " port
    read -p "Enter path to output file (optional): " output_file

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
        9) echo -e "${RED}Exiting Shozack. Goodbye!${RESET}"; exit 0 ;;
        *) echo -e "${RED}Invalid option. Please try again.${RESET}" ;;
    esac

    echo
    read -p "Press enter to continue..."
done
