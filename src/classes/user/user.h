user(){
    . <(sed "s/user/$1/g" $(dirname ${BASH_SOURCE[0]})/user.class)
}