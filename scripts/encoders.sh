#!/bin/sh

test_encoder()
{

test_begin "encoder-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dst_file=$TEMP_DIR/$3

do_test "$GPAC -i $2 $4 -o $dst_file$6 -graph -stats $5"  "encoder"

myinspect="inspect:test=encode:fmt=@pn@-@dts@-@cts@@lf@"

if [ ! -f $dst_file ] ; then
result="Encoded output not present"
else

#encoder outputs vary from platforms to platforms, we cannot do a hash on the result ...
#this will need further investigations
#do_hash_test "$dst_file" "encoder"

#do a hash on inspect
insfile=$TEMP_DIR/dump.txt
do_test "$GPAC -i $dst_file $myinspect:log=$insfile:test=encx" "inspect"
do_hash_test "$insfile" "inspect"

fi

mp4_file=$TEMP_DIR/in.mp4
#also do the test from MP4
$MP4BOX -add $2:dur=0.4 -new $mp4_file 2> /dev/null

dst_file=$TEMP_DIR/mp4-$3
do_test "$GPAC -i $mp4_file $4 -o $dst_file$6 -graph -stats $5"  "encoder-mp4"

if [ ! -f $dst_file ] ; then
result="Encoded output from MP4 not present"
else
#do_hash_test "$dst_file" "encoder-mp4"

#do a hash on inspect
insfile=$TEMP_DIR/dump2.txt
do_test "$GPAC -i $dst_file $myinspect:log=$insfile:test=encx" "inspect-mp4"
do_hash_test "$insfile" "inspect-mp4"

fi

test_end

}

jpeg=`$GPAC -h jpgenc 2>/dev/null | grep jpgenc`
png=`$GPAC -h pngenc 2>/dev/null | grep pngenc`

x264ff=`gpac -hh ffenc:* 2>&1 | grep ffenc:libx264`
j2kff=`gpac -hh ffenc:* 2>&1 | grep ffenc:jpeg2000`

mp3=`gpac -hh ffenc:* 2>&1 | grep ffenc:libmp3lame`

#video encoder tests

#test png encode
if [ -n "$png" ] ; then
test_encoder "png-pngenc" $MEDIA_DIR/auxiliary_files/sky.jpg "test.png" "" "-blacklist=ffenc" ""
fi
test_encoder "png-ffenc" $MEDIA_DIR/auxiliary_files/sky.jpg "test.png" "" "-blacklist=pngenc" ""

#test jpeg encode
if [ -n "$jpeg" ] ; then
test_encoder "jpeg-jpgenc" $MEDIA_DIR/auxiliary_files/logo.png "test.jpg" "" "-blacklist=ffenc" ""
fi
test_encoder "jpeg-ffenc" $MEDIA_DIR/auxiliary_files/logo.png "test.jpg" "" "-blacklist=jpgenc" ""

#test mpeg4 part2 encode
test_encoder "m4v-ffenc" $MEDIA_DIR/auxiliary_files/enst_video.h264 "test.cmp" "" "-blacklist=vtbdec,nvdec,ohevcdec" ""

#test h263 encode - insert a crop filter to produce a valid h263 frame size
#only do 1s, as ffenc gives garbage for this source video on arm after frame 70
test_encoder "h263-ffenc" $MEDIA_DIR/auxiliary_files/enst_video.h264 "test.263" "vcrop:wnd=0x0x128x96 @" "-blacklist=vtbdec,nvdec,ohevcdec" ":dur=1"

#test m1v encode
test_encoder "mpeg1-ffenc" $MEDIA_DIR/auxiliary_files/enst_video.h264 "test.m1v" "" "-blacklist=vtbdec,nvdec,ohevcdec" ""

#test m2v encode
test_encoder "mpeg2-ffenc" $MEDIA_DIR/auxiliary_files/enst_video.h264 "test.m2v" "" "-blacklist=vtbdec,nvdec,ohevcdec" ""


#test AVC encode
if [ -n "$x264ff" ] ; then
test_encoder "avc-ffenc" $MEDIA_DIR/auxiliary_files/count_video.cmp "test.264" "" "-blacklist=vtbdec,nvdec,ohevcdec --ffenc:profile=baseline" "::ls::x264-params=sync-lookahead=0"
fi

#test MJ2 encode - we need to explictly add the encoder, since the isom muxer can accept any input
if [ -n "$j2kff" ] ; then
test_encoder "j2k-ffenc" $MEDIA_DIR/auxiliary_files/count_video.cmp "test.mj2" "enc:c=j2k @" "-blacklist=vtbdec,nvdec,ohevcdec" ""
fi



#audio encoder tests
test_encoder "mp2-ffenc" $MEDIA_DIR/auxiliary_files/enst_audio.aac "test.mp2" "" "" ""
if [ -n "$mp3" ] ; then
test_encoder "mp3-ffenc" $MEDIA_DIR/auxiliary_files/enst_audio.aac "test.mp3" "" "" ""
fi

test_encoder "aac-ffenc" $MEDIA_DIR/auxiliary_files/count_french.mp3 "test.aac" "" "" ":c=aac"

#force 48k resample for ac3, ffmpeg versions behave differently on allowed sample rate
test_encoder "ac3-ffenc" $MEDIA_DIR/auxiliary_files/count_french.mp3 "test.ac3" "resample:osr=48k" "" ""



#explicit encoding load
test_begin "encoder-explicit"

if [ $test_skip != 1 ] ; then

dst=$TEMP_DIR/file.mp4
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/raw/raw.rgb:size=128x128 enc:c=png @ -o $dst" "encode"
do_hash_test "$dst" "encode"
fi
test_end


#audio encoding round-trip
test_encoder_art()
{

test_begin "encoder-art-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dst=$TEMP_DIR/enc.mp4
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/raw/raw_2s.pcm:ch=2:sr=44100 enc:c=$2 @ -o $dst" "encode"

#do hashes on decoded PCM inspect as decoders/encoders may give varying results
inspect=$TEMP_DIR/enc_inspect.txt
do_test "$GPAC -i $dst inspect:deep:fmt=%dts%-%cts%%lf%:test=encx:log=$inspect" "inspect-enc"
do_hash_test "$inspect" "encode"

dec=$TEMP_DIR/dec.pcm
do_test "$GPAC -i $dst -o $dec -blacklist=maddec,faad" "decode-ff"

inspect=$TEMP_DIR/dec_inspect.txt
do_test "$GPAC -i $dec:ch=2:sr=44100 inspect:deep:fmt=%dts%-%cts%-%size%%lf%:log=$inspect" "inspect-ff"
do_hash_test "$inspect" "decode-ff"

dec=$TEMP_DIR/dec_noff.pcm
do_test "$GPAC -i $dst -o $dec -blacklist=ffdec" "decode-noff"

inspect=$TEMP_DIR/dec_noff_inspect.txt
do_test "$GPAC -i $dec:ch=2:sr=44100 inspect:deep:fmt=%dts%-%cts%-%size%%lf%:log=$inspect" "inspect-ff"
do_hash_test "$inspect" "decode-noff"

test_end
}


test_encoder_art "aac" "aac"
test_encoder_art "mp3" "mp2"
