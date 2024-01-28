sys(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/sys/$1/g" "${0:A:h}/src/classes/sys/sys.class")
    else
        . <(sed "s/sys/$1/g" $(dirname ${BASH_SOURCE[0]})/sys.class)
    fi
}