#!/bin/sh

test_reframer()
{

test_begin "reframer-$1"

if [ $test_skip  = 1 ] ; then
return
fi

if [ -n "$3" ] ; then
dst_file=$TEMP_DIR/$3
else
dst_file=$TEMP_DIR/$(basename $2)
fi

do_test "$GPAC -i $2 reframer @ -o $dst_file  -graph -stats"  "rewrite"
do_hash_test "$dst_file" "rewrite"


if [ "$3" == "test.latm" ] ; then

dst_file2=$TEMP_DIR/test.aac
do_test "$GPAC -i $dst_file reframer @ -o $dst_file2  -graph -stats"  "rewrite-latm"
do_hash_test "$dst_file2" "rewrite-latm"

fi

test_end

}

test_reframer "png" $MEDIA_DIR/auxiliary_files/logo.png

test_reframer "jpg" $MEDIA_DIR/auxiliary_files/logo.jpg

test_reframer "aac" $MEDIA_DIR/auxiliary_files/enst_audio.aac

test_reframer "latm" $MEDIA_DIR/auxiliary_files/enst_audio.aac "test.latm"

test_reframer "mp3" $MEDIA_DIR/auxiliary_files/count_english.mp3 "test.mp2"

test_reframer "avc" $MEDIA_DIR/auxiliary_files/enst_video.h264

test_reframer "hevc" $MEDIA_DIR/auxiliary_files/counter.hvc
test_reframer "hevc-novpsext" $MEDIA_DIR/auxiliary_files/counter.hvc:novpsext "test.hvc"

test_reframer "av1-av1" $MEDIA_DIR/auxiliary_files/video.av1

test_reframer "av1-obu" $MEDIA_DIR/auxiliary_files/video.av1 "video.obu"

test_reframer "av1-ivf" $MEDIA_DIR/auxiliary_files/video.av1 "video.ivf"

test_reframer "iamf" $MEDIA_DIR/auxiliary_files/audio_opus.iamf "audio.mp4"

test_reframer "amr" $EXTERNAL_MEDIA_DIR/import/bear_audio.amr

test_reframer "amrwb" $EXTERNAL_MEDIA_DIR/import/obrother_wideband.amr

test_reframer "h263" $EXTERNAL_MEDIA_DIR/import/bear_video.263

test_reframer "qcp" $EXTERNAL_MEDIA_DIR/import/counter_english.qcp

test_reframer "m1v" $EXTERNAL_MEDIA_DIR/import/dead.m1v

test_reframer "jp2" $EXTERNAL_MEDIA_DIR/import/logo.jp2

test_reframer "mj2" $EXTERNAL_MEDIA_DIR/import/speedway.mj2

test_reframer "ogg" $EXTERNAL_MEDIA_DIR/import/dead_ogg.ogg "dead.mp4"

test_reframer "m2ps" "$EXTERNAL_MEDIA_DIR/import/dead_mpg.mpg -blacklist=ffdmx" "dead.mp4"

test_reframer "flac" $EXTERNAL_MEDIA_DIR/import/enst_audio.flac

test_reframer "ac3" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.ac3 -blacklist=ffdmx" "dump.mp4"
test_reframer "eac3" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.eac3 -blacklist=ffdmx" "dump.mp4"


test_reframer "mhas-mha1" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas -logs=parser:media@debug --mpha" "dump.mp4"
test_reframer "mhas-mhm1" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas" "dump.mp4"
#test MHAS rewriter
test_reframer "mha1-to-mhm1" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.mhas --mpha" "dump.mhas"

test_reframer "mhas-reconf" "$EXTERNAL_MEDIA_DIR/misc/mpegh_reconf.mhas" "dump.mp4"


test_reframer "usac" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.usac" "dump.mp4"

test_reframer "aac71" "$EXTERNAL_MEDIA_DIR/mc_audio/aac_7.1.aac" "dump.aac"
test_reframer "aac71brd" "$EXTERNAL_MEDIA_DIR/mc_audio/aac_7.1_brd.aac" "dump.aac"

test_reframer "vvc" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_1280x720p_I25_closedGOP_512kpbs.vvc" "dump.mp4"

test_reframer "truehd" "$EXTERNAL_MEDIA_DIR/import/truehd_ac3h.mlp:auxac3" "dump.mp4"


#test bsdbg, for coverage
test_begin "reframer-bsdbg"
if [ $test_skip != 1 ] ; then
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 inspect:deep -logs=parser@debug --bsdbg=full"  "parse-avc"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/video.av1 inspect:deep -logs=parser@debug --bsdbg=full"  "parse-av1"
test_end
fi


#test raw PCM extraction for coverage
test_begin "reframer-rawpcm"
if [ $test_skip != 1 ] ; then
file=$TEMP_DIR/dump.pcm
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/raw/raw_3s_48k.pcm reframer:xs=1:xe=2 @ -o $file"  "reframe"
do_hash_test $file "reframe"
test_end
fi

