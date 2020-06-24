#!/bin/sh
 if [ $EXTERNAL_MEDIA_AVAILABLE = 0 ] ; then
  return
 fi


test_begin "3D-HEVC"

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/3D-HEVC/stream_bbb.bit:fmt=HEVC -new $TEMP_DIR/test.mp4" "import"

ohevcdec=`$GPAC -h ohevcdec 2>/dev/null | grep ohevc`

#test openhevc decoding of stereo
if [ -n "$ohevcdec" ] ; then
 do_test "$GPAC -blacklist=nvdec,vtbdec,ffdec -i $TEMP_DIR/test.mp4 -o $TEMP_DIR/dump.yuv:force_stereo:sstart=7:send=7" "decode"
 do_hash_test_bin $TEMP_DIR/dump.yuv "decode"

 do_play_test "play" "$TEMP_DIR/dump.yuv:size=1920x2160"
fi

test_end



test_begin "add-subsamples-HEVC"

do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/3D-HEVC/stream_bbb.bit:fmt=HEVC:subsamples -new $TEMP_DIR/test.mp4" "add-subsamples-HEVC"
do_hash_test $TEMP_DIR/test.mp4 "import"

do_test "$MP4BOX -dash 2000 $TEMP_DIR/test.mp4 -profile onDemand -out  $TEMP_DIR/test.mpd" "dash-subsamples"
do_hash_test $TEMP_DIR/test_dashinit.mp4 "dash-subsamples"

test_end
