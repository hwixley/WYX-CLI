wixd(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/wixd/$1/g" "${0:A:h}/src/classes/wixd/wixd.class")
    else
        . <(sed "s/wixd/$1/g" $(dirname ${BASH_SOURCE[0]})/wixd.class)
    fi
}