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
echo "#include <stdio.h>" >> "$path/result.c" # Временная вставка, которая должна, по-хорошему, определяться аргументами.
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
        if [ "$char${string%"${string#?}"}" = "\\n" ]; then
            char="\\n" # И все остальные последовательности, начинающиеся слешем.
            string=${string#?}
        elif [ "$char" = "\\" ]; then
            char="\\\\"
        elif [ "$char" = "'" ]; then
            char="\\'"
        fi
        if [ $length = 0 ]; then # Ненавижу подобное...
            condition="stream[0] == '$char'"
        else
            condition="$condition && stream[$length] == '$char'"
        fi
        length=$((length + 1))
    done
    echo "        if ($condition) {" >> "$path/result.c"
    echo "            token = $token; " >> "$path/result.c"
    echo "            stream += $length;" >> "$path/result.c" # По-хорошему, можно делать инкремент при единицах, но у нас тут кодо-генерация, да и плодить условие разди такой фигни, когда уже разок-другой пренебрёг внешним видом...
    echo "        } else" >> "$path/result.c"
    token=$((token + 1))
done < "$path/1.layer"
if [ -f "$path/unknown-token.panic-1" ]; then
    echo "        {" >> "$path/result.c" # Стилистически не очень, но это лучше, чем возиться со строками, пытаясь избежать переноса строки.
    while IFS= read -r line; do
        echo "            $line" >> "$path/result.c"
    done <  "$path/unknown-token.panic-1"
    echo "        }" >> "$path/result.c"
else
    echo "        {" >> "$path/result.c"
    echo "            stream++;" >> "$path/result.c"
    echo "            continue;" >> "$path/result.c"
    echo "        }" >> "$path/result.c"
fi
max_token=token
layer=2
while [ -f "$path/$layer.layer" ]; do
    previous=0
    while IFS= read -r line; do
        if [ "$line" != "" ]; then
            if [ previous > max_token ]; then
                echo "Incorrect layer!"
                exit 1
            fi
            condition="token == $previous"
            length=0
            string=$line
            while test -n "$string"; do
                char=${string%"${string#?}"}
                string=${string#?}
                if [ "$char${string%"${string#?}"}" = "\\n" ]; then
                    char="\\n"
                    string=${string#?}
                elif [ "$char" = "\\" ]; then
                    char="\\\\"
                elif [ "$char" = "'" ]; then
                    char="\\'"
                fi
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
    if [ -f "$path/unknown-token.panic-$layer" ]; then
        echo "        {" >> "$path/result.c"
        while IFS= read -r line; do
            echo "            $line" >> "$path/result.c"
        done <  "$path/unknown-token.panic-$layer"
        echo "        }" >> "$path/result.c"
    else
        echo "        {" >> "$path/result.c"
        echo "            stream++;" >> "$path/result.c"
        echo "            continue;" >> "$path/result.c"
        echo "        }" >> "$path/result.c"
    fi
    layer=$((layer + 1))
done
echo "        add_token(token);" >> "$path/result.c"
echo "    }" >> "$path/result.c"
echo "}" >> "$path/result.c"
echo "Okey? No? I can't response you."