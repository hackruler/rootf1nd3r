# To find root domains from crt.sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

cexit() {
    echo -e "${RED}[!] Script interrupted. Exiting...${NC}"
    exit "$1"
}


show_help() {
    echo "   Usage: bash root.sh -l <root domains file>"
    echo ""
    echo "   Options:"
    echo "   -h                              Help Menu"
    echo "   -l <input file name>            Specify the domain file."
    echo "   -o <output file name>           file to write output result."
}


trap 'cexit 1' SIGINT;

while getopts ":o:l:h" opt; do
    case $opt in
        o)
            output_file="$OPTARG"
            ;;
        l)
            input_file="$OPTARG"
            ;;
        h)
            show_help 
            ;;            
        \?)
            echo -e "${RED}Invalid option.${NC}"
            show_help
            ;;
    esac
done

if [ -z "$input_file" ]; then
    exit 0
fi

if [ ! -f "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is not present in the directory.${NC}"
    exit 0
fi

if [ ! -s "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is empty.${NC}"
    exit 0
fi

if [ ! -r "$input_file" ]; then
    echo -e "${RED}Error: The specified input file '$input_file' is not readable.${NC}"
    exit 0
fi

echo -e "${YELLOW}[!] Finding root domains from crt.sh${NC}";
for domain in $(cat "$input_file"); do 
        curl -s https://crt.sh/?q=${domain}\&output=json --retry 5 | jq | grep -e name_value -e common_name | sort -u | grep \* | cut -d ":" -f2 | sed 's/\"\|\"\,//g' | sed 's/\\n/\n/g' | sed 's/^ *//' | grep \* | sort -u | sed 's/\*\.//g' | { [ -z "$output_file" ] && cat || tee -a "$output_file" > /dev/null; }
        sleep 20
done
{
    [ -z "$output_file" ] && 
    cat ||
    cat "$input_file" | anew "$output_file" > /dev/null;
}


{
    [ -z "$output_file" ] && 
    cat ||
    echo -e "${GREEN}[**]" $(cat root.txt | wc -l)" root domains found${NC}";
}

echo -e "${GREEN}[**] ..................SCRIPT ENDED......................${NC}"
