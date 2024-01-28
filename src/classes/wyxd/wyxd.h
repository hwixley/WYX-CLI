wyxd(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/wyxd/$1/g" "${WYX_DIR}/src/classes/wyxd/wyxd.class")
    else
        . <(sed "s/wyxd/$1/g" $(dirname ${BASH_SOURCE[0]})/wyxd.class)
    fi
}