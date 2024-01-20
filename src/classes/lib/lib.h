lib(){
    . <(sed "s/lib/$1/g" $(dirname ${BASH_SOURCE[0]})/lib.class)
}