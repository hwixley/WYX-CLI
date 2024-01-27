lib(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/lib/$1/g" "${0:A:h}/src/classes/lib/lib.class")
    else
        . <(sed "s/lib/$1/g" $(dirname ${BASH_SOURCE[0]})/lib.class)
    fi
}