#!/bin/sh
path=""
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            echo "Help message ;)"
            exit 0
            ;;
        *)
            path="$arg"
            ;;
    esac
done
if [ "$path" = "" ]; then
    echo "Required args!!!!!"
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
result="$path/result.c"
> "$result"
echo "#include <stdio.h>" >> "$result"
echo "" >> "$result"
echo "int main(void) {" >> "$result"
echo "    #define add_token(id) if (id != ~0) printf(\"%u\\n\", id)" >> "$result" # По-хорошему, надо и вовсе завернуть в блок и т.д., но... Это излишне в простом примере.
echo "    const char * stream = \"Example data — it is your variable.\";" >> "$result"
echo "    // const char * stream и add_token(unsigned int) — на ваше попечение и реализацию!" >> "$result" # Обратите внимание: контракт add_token это unsigned int, а остальное вас не волнует, ведь token вне вашей ответственности.
echo "    unsigned token;" >> "$result"
echo "    while (*stream != 0) {" >> "$result"
echo "        token = ~0;" >> "$result"
token=0
while IFS= read -r line; do
    if [ "$line" = "" ]; then
        echo "Empty line!!"
        exit 1
    fi
    condition=""
    length=0
    string=$line
    while test -n "$string"; do
        char=${string%"${string#?}"}
        string=${string#?}
        if [ "$char" = "'" ]; then
            char="\\'"
        fi
        while [ "$char" = "\\" ]; do # Слегка уродливо, но по-своему неплохо, да и лучше сейчас не придумал.
            next_char=${string%"${string#?}"}
            if [ "$next_char" = "0" ]; then
                char="\\0"
            elif [ "$next_char" = "a" ]; then
                char="\\a"
            elif [ "$next_char" = "n" ]; then
                char="\\n"
            elif [ "$next_char" = "r" ]; then
                char="\\r"
            elif [ "$next_char" = "t" ]; then
                char="\\t"
            elif [ "$next_char" = "v" ]; then
                char="\\v"
            else
                char="\\\\"
                break
            fi
            string=${string#?}
        done
        if [ $length = 0 ]; then
            condition="stream[0] == '$char'"
        else
            condition="$condition && stream[$length] == '$char'"
        fi
        length=$((length + 1))
    done
    echo "        if ($condition) {" >> "$result"
    echo "            token = $token; " >> "$result"
    echo "            stream += $length;" >> "$result"
    echo "        } else" >> "$result"
    token=$((token + 1))
done < "$path/1.layer"
if [ -f "$path/panic.c" ]; then
    echo "        {" >> "$result"
    while IFS= read -r line; do
        echo "            $line" >> "$result"
    done <  "$path/panic.c"
    echo "        }" >> "$result"
else
    echo "            { stream++; continue; }" >> "$result"
fi
max_token=token
layer=2
while [ -f "$path/$layer.layer" ]; do
    previous=0
    while IFS= read -r line; do
        if [ "$line" != "" ]; then
            if [ $previous -gt $max_token ]; then
                echo "Incorrect layer!"
                exit 1
            fi
            condition="token == $previous"
            length=0
            string=$line
            while test -n "$string"; do
                char=${string%"${string#?}"}
                string=${string#?}
                if [ "$char" = "'" ]; then
                    char="\\'"
                fi
                while [ "$char" = "\\" ]; do
                    next_char=${string%"${string#?}"}
                    if [ "$next_char" = "0" ]; then
                        char="\\0"
                    elif [ "$next_char" = "a" ]; then
                        char="\\a"
                    elif [ "$next_char" = "n" ]; then
                        char="\\n"
                    elif [ "$next_char" = "r" ]; then
                        char="\\r"
                    elif [ "$next_char" = "t" ]; then
                        char="\\t"
                    elif [ "$next_char" = "v" ]; then
                        char="\\v"
                    else
                        char="\\\\"
                        break
                    fi
                    string=${string#?}
                done
                condition="$condition && stream[$length] == '$char'"
                length=$((length + 1))
            done
            echo "        if ($condition) {" >> "$result"
            echo "            token = $token; " >> "$result"
            echo "            stream += $length;" >> "$result"
            echo "        } else" >> "$result"
            token=$((token + 1))
        fi
        previous=$((previous + 1))
    done < "$path/$layer.layer"
    echo "            ;" >> "$result"
    layer=$((layer + 1))
done
echo "        add_token(token);" >> "$result"
echo "    }" >> "$result"
echo "}" >> "$result"
echo "Okey? No? I can't response you."