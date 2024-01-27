cmd(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/cmd/$1/g" "${0:A:h}/src/classes/cmd/cmd.class")
    else
        . <(sed "s/cmd/$1/g" $(dirname ${BASH_SOURCE[0]})/cmd.class)
    fi
}