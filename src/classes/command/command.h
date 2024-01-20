command(){
    . <(sed "s/command/$1/g" $(dirname ${BASH_SOURCE[0]})/command.class)
}