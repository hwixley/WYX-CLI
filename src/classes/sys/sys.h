system(){
    . <(sed "s/system/$1/g" $(dirname ${BASH_SOURCE[0]})/system.class)
}