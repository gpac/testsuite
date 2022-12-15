thumbs_test()
{
name=$(basename $1)
name=${name%%.*}

test_begin "thumbs-$name"

if [ $test_skip  = 1 ] ; then
 return
fi

myres=$TEMP_DIR/dump.png
myjs=$TEMP_DIR/dump.js

do_test "$GPAC -blacklist=vtbdec,nvdec,ohevcdec,osvcdec -font-dirs=$EXTERNAL_MEDIA_DIR/fonts/ -rescan-fonts -i $MEDIA_DIR/auxiliary_files/counter.hvc thumbs$2:list=$myjs -o $myres -graph" "run"
do_hash_test $myres "run"
do_hash_test $myjs "list"

test_end
}


thumbs_test "simple" ""
thumbs_test "times" ":txt='\$time\$'"
thumbs_test "mae" ":mae=7"
thumbs_test "grid" ":grid=3x4"
