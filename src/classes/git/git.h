git(){
    . <(sed "s/git/$1/g" $(dirname ${BASH_SOURCE[0]})/git.class)
}