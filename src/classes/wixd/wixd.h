wixd(){
    . <(sed "s/wixd/$1/g" $(dirname ${BASH_SOURCE[0]})/wixd.class)
}