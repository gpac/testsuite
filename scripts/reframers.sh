#!/bin/sh

test_reframer()
{

test_begin "reframer-$1"

if [ $test_skip  = 1 ] ; then
return
fi

mp4_file=$TEMP_DIR/in.mp4
src_file=$2
if [ -n "$3" ] ; then
dst_file=$TEMP_DIR/$3
else
dst_file=$TEMP_DIR/$(basename $2)
fi

do_test "$GPAC -i $src_file reframer @ -o $dst_file  -graph -stats"  "rewrite"
do_hash_test "$dst_file" "rewrite"

test_end

}

test_reframer "png" $MEDIA_DIR/auxiliary_files/logo.png

test_reframer "jpg" $MEDIA_DIR/auxiliary_files/logo.jpg

test_reframer "aac" $MEDIA_DIR/auxiliary_files/enst_audio.aac

test_reframer "mp3" $MEDIA_DIR/auxiliary_files/count_english.mp3

test_reframer "avc" $MEDIA_DIR/auxiliary_files/enst_video.h264

test_reframer "hevc" $MEDIA_DIR/auxiliary_files/counter.hvc

test_reframer "av1-av1" $MEDIA_DIR/auxiliary_files/video.av1

test_reframer "av1-obu" $MEDIA_DIR/auxiliary_files/video.av1 "video.obu"

test_reframer "av1-ivf" $MEDIA_DIR/auxiliary_files/video.av1 "video.ivf"

test_reframer "amr" $EXTERNAL_MEDIA_DIR/import/bear_audio.amr

test_reframer "amrwb" $EXTERNAL_MEDIA_DIR/import/obrother_wideband.amr

test_reframer "h263" $EXTERNAL_MEDIA_DIR/import/bear_video.263

test_reframer "qcp" $EXTERNAL_MEDIA_DIR/import/count_english.qcp

test_reframer "m1v" $EXTERNAL_MEDIA_DIR/import/dead.m1v

test_reframer "jp2" $EXTERNAL_MEDIA_DIR/import/logo.jp2

test_reframer "mj2" $EXTERNAL_MEDIA_DIR/import/speedway.mj2
