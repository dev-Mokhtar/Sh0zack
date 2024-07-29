
# Sh0zack

**Penetration Testing** tool-suite and framework written in **Bash**, designed for security assessments on platforms like TryHackMe (THM) and Hack The Box (HTB), as well as real-world pentesting scenarios. It features a collection of customized tools with a user-friendly interface for efficient execution of attacks to identify and exploit vulnerabilities across various environments.
## Usage

```
git clone https://github.com/dev-Mokhtar/Sh0zack
chmod +x sh0zack.sh && ./sh0zack.sh
```


## Features : 



- **Port Scanning**: Scan open ports using Nmap, Rustscan, or the Sh0zack Port Scan Tool.
- **DNS Scanning**: Discover subdomains with Gobuster or the Advanced Sh0zack DNS Scan Tool.
- **Directory Scanning**: Enumerate directories and files using Gobuster, WFuzz, or the Sh0zack Directory Scan Tool.
- **Brute Force**: Perform brute force attacks with Hydra or the Sh0zack Brute Force Tool.
- **Listener Setter**: code to Set up a listener to catch reverse shells.
- **Privilege Escalation Check**: customized binary to Identify potential privilege escalation vectors on LINUX 
- **Shell Generator**: Generate various types of reverse and bind shells and others ...
- **Decrypting Tools**: Decrypt encoded data using multiple methods 
- **Web Scanner**: Scan websites for vulnerabilities using Nikto, OWASP ZAP, Skipfish, WPScan, or CMSmap..

## Examples

Sh0zack DNS Scan Tool: `./tools/dns.sh -u <url> -w <wordlist> -o <output_file> -t <threads> -T <timeout> -n -v`

Sh0zack Port Scan Tool: `./tools/port-scanner.sh <target>`

Sh0zack Directory Scan Tool: `./tools/dir.sh -u <url> -w <wordlist> -o <output_file> -t <threads> -T <timeout> -v`
.

and many others ....




## Feedback

If you have any feedback, please dm at mokhtarderbazi@gmail.com


## Authors

- [@dev-mokhtar](https://www.github.com/dev-mokhtar)

