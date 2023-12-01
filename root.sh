# To find root domains from crt.sh
# Find subdomains for the respective root domains
# Also find the httpx result

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cexit() {
    echo -e "${RED}[!] Script interrupted. Exiting...${NC}"
    exit "$1"
}


trap 'cexit 1' SIGINT;

if [ -z "$1" ] || [ "$#" -ne 1 ]; then
    echo -e "${GREEN}Usage: bash $0 <input_file>${NC}";
    cexit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is not present in the directory.${NC}";
    cexit 1
fi

if [ ! -s "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is empty.${NC}";
    cexit 1
fi
if [ ! -r "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is not readable.${NC}";
    cexit 1
fi

echo -e "${YELLOW}[!] Finding root domains from crt.sh${NC}";
for domain in $(cat "$input_file"); do 
        curl -s https://crt.sh/?q=${domain}\&output=json --retry 5 | jq | grep -e name_value -e common_name | sort -u | grep \* | cut -d ":" -f2 | sed 's/\"\|\"\,//g' | sed 's/\\n/\n/g' | sed 's/^ *//' | grep \* | sort -u | sed 's/\*\.//g' | tee -a root.txt > /dev/null || cexit $?; 
        sleep 20
done
cat "$input_file" | anew root.txt >> /dev/null || cexit $?;
echo -e "${GREEN}[*] All the root domains are stored to root.txt${NC}";
echo -e "${GREEN}[**]" $(cat root.txt | wc -l)" root domains found${NC}";
echo -e "${YELLOW}[!] Subfinder is running...${NC}";
cat root.txt | subfinder -all -silent | sort -u | tee subdomains.txt > /dev/null || cexit $?;
echo -e "${GREEN}[*] Subfinder result is stored to subdomains.txt${NC}";
echo -e "${GREEN}[**]" $(cat subdomains.txt | wc -l)" subdomains found.${NC}";
echo -e "${YELLOW}[!] httpx is running...${NC}";
httpx -l subdomains.txt -silent -sc -td -cl | tee -a httpx.txt > /dev/null || cexit $?;
echo -e "${GREEN}[*] httpx result is stored to httpx.txt${NC}";
echo "[*] .........................SCRIPT ENDED.....................";

