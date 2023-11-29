# To find root domains from crt.sh
# Find subdomains for the respective root domains
# Also find the httpx result

if [ -z "$1" ] || [ "$#" -ne 1 ]; then
    echo "Usage: bash $0 <input_file>"
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: The specified input file '$input_file' is not present in the directory."
    exit 1
fi

if [ ! -s "$input_file" ]; then
    echo "Error: The specified input file '$input_file' is empty."
    exit 1
fi

if [ ! -r "$input_file" ]; then
    echo "Error: The specified input file '$input_file' is not readable."
    exit 1
        fi

echo "[!] Finding root domains from crt.sh"
for domain in $(cat "$input_file"); do 
        curl -s https://crt.sh/?q=${domain}\&output=json --retry 5 | jq | grep -e name_value -e common_name | sort -u | grep \* | cut -d ":" -f2 | sed 's/\"\|\"\,//g' | sed 's/\\n/\n/g' | sed 's/^ *//' | grep \* | sort -u | sed 's/\*\.//g' |tee -a root.txt > /dev/null;
        sleep 20
done
cat domains.txt | anew root.txt >> /dev/null;
echo "[*] All the root domains are stored to root.txt"
echo "[**]" $(cat root.txt | wc -l)" root domains found"
echo "[!] Subfinder is running"
cat root.txt | subfinder -all -silent | sort -u | tee subdomains.txt > /dev/null;
echo "[*] Subfinder result is stored to subdomains.txt "
echo "[**]" $(cat subdomains.txt | wc -l)" subdomains found"
echo "[!] httpx is running"
httpx -l subdomains.txt -silent -sc -td -cl | tee -a httpx.txt > /dev/null;
echo "[*] httpx result is stored to httpx.txt"
echo "[*] .........................SCRIPT ENDED....................."
