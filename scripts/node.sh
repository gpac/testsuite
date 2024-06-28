
function node_test() {

    name=$(basename $1)
    name=${name%.*}

    test_begin "node-$name"

    if [ $test_skip = 1 ] ; then
        return
    fi


    do_test "node $1" "node"

    test_end


}



function node_gpac() {

    name=$(basename $1)
    name=${name%.*}

    test_begin "node-gpac-$name"

    if [ $test_skip = 1 ] ; then
        return
    fi

    shift

    do_test "node $*" "node"

    test_end



}


if [ "$HAS_GPAC_NODE" = "yes" ] ; then

    for i in $MEDIA_DIR/node/*.js ; do
        node_test $i
    done

    node_gpac "inspect" ../share/nodejs/test/gpac.js -src=$EXTERNAL_MEDIA_DIR/noFragsDefault/counter-bifs-10sec-320x180-bipbop_420_avc.mp4 -f=inspect:deep

fi
