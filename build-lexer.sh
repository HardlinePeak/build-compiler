#!/bin/sh
ignore_case=false
multi_byte=false
path=""
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            echo "Help message ;)"
            exit 0
            ;;
        -i|--ignore-case)
            ignore_case=true
            ;;
        -m|--multi-byte)
            multi_byte=true
            ;;
        *)
            path="$arg"
            ;;
    esac
done
if [ ! -e "$path" ]; then
    echo "Error path!!!!"
    exit 1
fi
if [ ! -d "$path" ]; then
    echo "Error dir!!!"
    exit 1
fi
if [ ! -f "$path/1.layer" ]; then
    echo "Oh, no!"
    exit 1
fi
# Ignore ignore_case and multi_byte — he-he-he...
echo "    char * stream = \"Example data — it is your variable.\";" >> "$path/result.c"
echo "    unsigned int token;" >> "$path/result.c"
echo "    while (*stream != 0) { // Infinity loop if stream += 0?.. Pof-Poff-Poof :)" >> "$path/result.c"
echo "        token = -1;" >> "$path/result.c"
echo "        " >> "$path/result.c"
while IFS= read -r line || [ -n "$line" ]; do
    # if $line == "" — error! Is first layer!
    echo "if (stream[...] == \"$line\") { // Unknown me how write :(" >> "$path/result.c"
    echo "            token = $token; " >> "$path/result.c"
    echo "            stream += ???; // strlen(\"$line\")? Shell script! OooooOoooOooOo...." >> "$path/result.c"
    echo "        } else " >> "$path/result.c"
done < "$path/1.layer"
if [ -f "$path/unknown-token.panic-1" ]; then
    echo "{" >> "$path/result.c"
    while IFS= read -r line || [ -n "$line" ]; do
        echo "            $line" >> "$path/result.c"
    done <  "$path/unknown-token.panic-1"
    echo "        }" >> "$path/result.c"
else
    echo "{} // GG." >> "$path/result.c"
fi
# Foreach other layer in loop and adding in result.c
# And other panic!
echo "    }" >> "$path/result.c"
echo "Okey? No? I can't response you."