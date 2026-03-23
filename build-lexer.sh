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
# Потом реализую ignore_case и multi_byte, если будет желание.
> "$path/result.c"
echo "#include <stdio.h>" >> "$path/result.c"
echo "" >> "$path/result.c"
echo "int main(void) {" >> "$path/result.c"
echo "    #define add_token(id) if (id != -1)\\" >> "$path/result.c"
echo "        printf(\"%u\\n\", id);" >> "$path/result.c"
echo "    char * stream = \"Example data — it is your variable.\";" >> "$path/result.c"
echo "    // char * stream и add_token(unsigned int) — на ваше попечение и реализацию!" >> "$path/result.c"
echo "    unsigned int token;" >> "$path/result.c"
echo "    while (*stream != 0) {" >> "$path/result.c"
echo "        token = -1;" >> "$path/result.c"
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
            elif [ "$next_char" = "u" ]; then
                char="u" # Я не буду этого делать. Не сегодня и не в ближайшее время.
            elif [ "$next_char" = "v" ]; then
                char="\\v"
            elif [ "$next_char" = "x" ]; then
                char="x" # Нужно ещё дальше парсить...
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
    echo "        if ($condition) {" >> "$path/result.c"
    echo "            token = $token; " >> "$path/result.c"
    echo "            stream += $length;" >> "$path/result.c"
    echo "        } else" >> "$path/result.c"
    token=$((token + 1))
done < "$path/1.layer"
echo "        {" >> "$path/result.c"
if [ -f "$path/panic.c" ]; then
    while IFS= read -r line; do
        echo "            $line" >> "$path/result.c"
    done <  "$path/panic.c"
else
    echo "            stream++;" >> "$path/result.c"
    echo "            continue;" >> "$path/result.c"
fi
echo "        }" >> "$path/result.c"
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
                    elif [ "$next_char" = "u" ]; then
                        char="u"
                    elif [ "$next_char" = "v" ]; then
                        char="\\v"
                    elif [ "$next_char" = "x" ]; then
                        char="x"
                    else
                        char="\\\\"
                        break
                    fi
                    string=${string#?}
                done
                condition="$condition && stream[$length] == '$char'"
                length=$((length + 1))
            done
            echo "        if ($condition) {" >> "$path/result.c"
            echo "            token = $token; " >> "$path/result.c"
            echo "            stream += $length;" >> "$path/result.c"
            echo "        } else" >> "$path/result.c"
            token=$((token + 1))
        fi
        previous=$((previous + 1))
    done < "$path/$layer.layer"
    echo "            ;" >> "$path/result.c"
    layer=$((layer + 1))
done
echo "        add_token(token);" >> "$path/result.c"
echo "    }" >> "$path/result.c"
echo "}" >> "$path/result.c"
echo "Okey? No? I can't response you."