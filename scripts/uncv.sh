#this tests a web radio, exercising icy meta skip and chunk transfer

test_begin "uncv"
if [ $test_skip  = 1 ] ; then
return
fi

mp4file=$TEMP_DIR/file.heif
do_test "$GPAC uncvg:c=R,G,B:dur=0 -o $mp4file" "heif"
do_hash_test $mp4file "heif"

mp4file=$TEMP_DIR/file.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25 -o $mp4file" "simple"
do_hash_test $mp4file "simple"

suf="pix"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:pixel_size=4 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="blk"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:block_size=4 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="blkpix"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:block_size=4:pixel_size=6 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="pixa"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R9,G10+2,B9:dur=1/25 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="yuv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,V:dur=1/25:sampling=420:interleave=comp -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="yuyv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,Y,V:dur=1/25:sampling=422:interleave=multi -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"

suf="yyuyyv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,Y,U,Y,Y,V:dur=1/25:sampling=411:interleave=multi -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"


test_end

