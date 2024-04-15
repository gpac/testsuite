#!/bin/sh

#test src->fmp4(pipe) | fmp4(pipe)->encrypt->fmp4(pipe) | fmp4(pipe)->decrypt->fmp4(file)
test_pipe()
{

test_begin "pipe-crypt$1"

if [ $test_skip  = 1 ] ; then
return
fi

src_file="$TEMP_DIR/src.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264:dur=5  -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:dur=5 -new $src_file"  "import"

#create source pipe, fragmented mode
do_test "$GPAC -i $src_file reframer -o pipe://gpac_pipe_in:mkp:ext=mp4:frag:cdur=1$2 -graph -logs=mmio@info"  "source" &

sleep .1

#create encrypter, output fragmented
do_test "$GPAC -i pipe://gpac_pipe_in$2 cecrypt:cfile=$MEDIA_DIR/encryption/cbcs_const.xml -o pipe://gpac_pipe_out:mkp:ext=mp4:frag:cdur=1$2 -graph -logs=mmio@info"  "crypt" &

sleep .1

#create decrypter
dst_file="$TEMP_DIR/dump.mp4"
do_test "$GPAC -i pipe://gpac_pipe_out$2 cdcrypt -o $dst_file:frag -graph -logs=mmio@info"  "decrypt"

wait

do_hash_test "$dst_file" "decrypt"

test_end

}

#test without flush marker
test_pipe "" ""
#test with flush marker to force segments out
test_pipe "-marker" ":marker"


rm gpac_pipe_in 2> /dev/null
rm gpac_pipe_out 2> /dev/null



test_pipe_sigflush()
{

test_begin "pipe-sigflush"

if [ $test_skip  = 1 ] ; then
return
fi

src_file="$TEMP_DIR/src.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_320x180_128kbps.264:dur=5 -new $src_file"  "import"

#create sources, fragmented mode
mpd_file="$TEMP_DIR/src.mpd"
do_test "$GPAC -i $src_file -o $mpd_file"  "dash"

#create recorder
dst_file="$TEMP_DIR/dump.mp4"
do_test "$GPAC -i pipe://gpac_pipe_out:mkp:marker cdcrypt -o $dst_file:frag -graph -logs=mmio@info"  "decrypt" &

#create encrypter, output fragmented, leaving keealive after 3 broken pipes
do_test "$GPAC -i pipe://gpac_pipe_in:mkp:ka:sigflush:bpcnt=3 cecrypt:cfile=$MEDIA_DIR/encryption/cbcs_const.xml -o pipe://gpac_pipe_out:ext=mp4:frag:cdur=1:marker -graph -logs=mmio@info"  "crypt" &

sleep .5

## do not use cat on pipe for windows tests
#cat "$TEMP_DIR/src_dashinit.mp4" > gpac_pipe_in
gpac -i "$TEMP_DIR/src_dashinit.mp4" -o pipe://gpac_pipe_in:ext=mp4:nomux
sleep .1
#cat "$TEMP_DIR/src_dash1.m4s" > gpac_pipe_in
gpac -i "$TEMP_DIR/src_dash1.m4s" -o pipe://gpac_pipe_in:ext=m4s:nomux
sleep .1
#cat "$TEMP_DIR/src_dash2.m4s" > gpac_pipe_in
gpac -i "$TEMP_DIR/src_dash2.m4s" -o pipe://gpac_pipe_in:ext=m4s:nomux

wait

do_hash_test "$dst_file" "decrypt"

rm gpac_pipe_in 2> /dev/null
rm gpac_pipe_out 2> /dev/null

test_end

}

test_pipe_sigflush
