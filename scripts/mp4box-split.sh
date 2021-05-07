

test_split()
{
test_begin "mp4box-split-$1"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/base.mp4"
do_test "$MP4BOX -add $2:dur=10 -new $mp4file" "add"
do_hash_test $mp4file "add"

do_test "$MP4BOX -split 1 $mp4file" "split-1s"
do_hash_test $TEMP_DIR/base_001.mp4 "split-1"
do_hash_test $TEMP_DIR/base_005.mp4 "split-5"
do_hash_test $TEMP_DIR/base_009.mp4 "split-9"

do_test "$MP4BOX -splitx 4:8.5 $mp4file" "splitx"
do_hash_test $TEMP_DIR/base_001.mp4 "splitx"

do_test "$MP4BOX -splitz 4:7.5 $mp4file" "splitz"
do_hash_test $TEMP_DIR/base_001.mp4 "splitz"


mv $mp4file $TEMP_DIR/base_s.mp4
mp4file="$TEMP_DIR/base_s.mp4"

do_test "$MP4BOX -splits 100 $mp4file" "split-100kb"
do_hash_test $TEMP_DIR/base_001.mp4 "splits-1"
do_hash_test $TEMP_DIR/base_002.mp4 "splits-2"


test_end
}

test_split "avc" $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264

test_split "aac" $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac


test_split_av()
{
test_begin "mp4box-split-av"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/src.mp4"
#create AV file video B-frames and AAC priming of 1 frame
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:sopt:#Delay=-1024 -new $mp4file" "mksrc"
do_hash_test $mp4file "mksrc"

#result is 2.0->4.2
dst="$TEMP_DIR/splitx.mp4"
do_test "$MP4BOX -splitx 2.7:4.2 $mp4file -out $dst" "splitx"
do_hash_test $dst "splitx"

#result is 3.0->5
dst="$TEMP_DIR/splitz.mp4"
do_test "$MP4BOX -splitz 2.7:4.2 $mp4file -out $dst" "splitz"
do_hash_test $dst "splitz"

#result is 2.0->5.0
dst="$TEMP_DIR/splitg.mp4"
do_test "$MP4BOX -splitg 2.7:4.2 $mp4file -out $dst" "splitg"
do_hash_test $dst "splitg"

#result is 2.7->4.2
dst="$TEMP_DIR/splitf.mp4"
do_test "$MP4BOX -splitf 2.7:4.2 $mp4file -out $dst" "splitf"
do_hash_test $dst "splitf"


#result is 2.0->4.2
dst="$TEMP_DIR/splitx-flat.mp4"
do_test "$MP4BOX -splitx 2.7:4.2 $mp4file -out $dst -flat" "splitx-flat"
do_hash_test $dst "splitx-flat"

#result is 2.0->4.2
dst="$TEMP_DIR/splitx-frag.mp4"
do_test "$MP4BOX -splitx 2.7:4.2 $mp4file -out $dst -frag 500" "splitx-frag"
do_hash_test $dst "splitx-frag"

#result is 2.0->4.2
dst="$TEMP_DIR/splitx-fast.mp4"
do_test "$MP4BOX -splitx 2.7:4.2 $mp4file -out $dst -newfs" "splitx-fast"
do_hash_test $dst "splitx-fast"

test_end
}

test_split_av
