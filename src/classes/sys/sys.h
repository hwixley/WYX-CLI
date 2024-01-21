sys(){
    . <(sed "s/sys/$1/g" $(dirname ${BASH_SOURCE[0]})/sys.class)
}