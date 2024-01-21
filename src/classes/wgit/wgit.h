wgit(){
    . <(sed "s/wgit/$1/g" $(dirname ${BASH_SOURCE[0]})/wgit.class)
}