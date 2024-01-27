wgit(){
    if [[ "$OSTYPE" == "darwin"* ]] || [[ "$(ps -o args= -p $$)" = *"zsh"* ]]; then
        . <(sed "s/wgit/$1/g" "${0:A:h}/src/classes/wgit/wgit.class")
    else
        . <(sed "s/wgit/$1/g" $(dirname ${BASH_SOURCE[0]})/wgit.class)
    fi
}