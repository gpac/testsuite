test_begin "txtgen"
if [ $test_skip = 1 ]; then
	return
fi

dump=$TEMP_DIR/dump.vtt
do_test "$GPAC txtgen:w:fdur=1/5:dur=5:rollup=2:!rt tx3g2vtt -o $dump" "word-rollup"
do_hash_test $dump "word-rollup"

do_test "$GPAC txtgen:l:fdur=1/5:dur=5:rollup=2:!rt tx3g2vtt -o $dump" "line-rollup"
do_hash_test $dump "line-rollup"

do_test "$GPAC txtgen:fdur=1/5:dur=5:lmax=16:!rt tx3g2vtt -o $dump" "lmax"
do_hash_test $dump "lmax"

do_test "$GPAC txtgen:fdur=1:dur=5:!rt tx3g2vtt -o $dump" "udur"
do_hash_test $dump "udur"

test_end
