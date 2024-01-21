cmd(){
    . <(sed "s/cmd/$1/g" $(dirname ${BASH_SOURCE[0]})/cmd.class)
}