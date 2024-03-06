#!/bin/sh


test_begin "hls"
if [ $test_skip != 1 ] ; then

m3u8file=$EXTERNAL_MEDIA_DIR/hls/index.m3u8
mpdfile=$EXTERNAL_MEDIA_DIR/hls/file1.mpd

do_test "$MP4BOX -mpd $m3u8file -out $mpdfile" "convert"
do_hash_test "$mpdfile" "convert"

mpdfile=$TEMP_DIR/file2.mpd
do_test "$MP4BOX -mpd $m3u8file -out $mpdfile" "convert-baseurl"
if [ $keep_temp_dir != 1 ] ; then
 do_hash_test "$mpdfile" "convert-baseurl"
else
echo "skipping hash, invalid when per-test temp dir is used"
fi

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $mpdfile inspect:allp:deep:interleave=false:log=$myinspect -stats -graph" "inspect"
do_hash_test $myinspect "inspect"

fi
test_end


test_hls_crypt()
{
test_begin "hls-crypt-$1"
if [ $test_skip != 1 ] ; then

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:#ClampDur=6:#Bitrate=200k cecrypt:cfile=$MEDIA_DIR/encryption/$2 @ -o $TEMP_DIR/live.m3u8" "crypt"

do_hash_test $TEMP_DIR/live_1.m3u8 "playlist"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dashinit.mp4 "init"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dash1.m4s "seg1"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_640x360_192kbps_dash3.m4s "seg3"

fi
test_end
}

test_hls_crypt "cbcs" "cbcs_const.xml"
test_hls_crypt "cbcs-roll" "cbcs_const_roll.xml"

test_hls_crypt_seg()
{

test_begin "hls-cryp-seg-$1"
if [ $test_skip != 1 ] ; then

my_inspect=$TEMP_DIR/inspect_mp4.txt
do_test "$GPAC $2 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -o $TEMP_DIR/file.m3u8:hlsdrm=$MEDIA_DIR/encryption/cbcs_const_roll2.xml" "cryp-mp4"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master-mp4"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-child-mp4"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dashinit.mp4" "init-seg-mp4"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash1.m4s" "first-seg-mp4"

do_test "$GPAC $2 -i $TEMP_DIR/file.m3u8 inspect:deep:log=$my_inspect" "inspect-mp4"
do_hash_test $my_inspect "inspect-mp4"


my_inspect=$TEMP_DIR/inspect_ts.txt
do_test "$GPAC $2 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 -o $TEMP_DIR/file_ts.m3u8:hlsdrm=$MEDIA_DIR/encryption/cbcs_const_roll2.xml:muxtype=ts" "cryp-ts"
do_hash_test "$TEMP_DIR/file_ts.m3u8" "hls-master-ts"
do_hash_test "$TEMP_DIR/file_ts_1.m3u8" "hls-child-ts"
do_hash_test "$TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash1.ts" "first-seg-ts"

do_test "$GPAC $2 -i $TEMP_DIR/file_ts.m3u8 inspect:deep:log=$my_inspect" "inspect-ts"
do_hash_test $my_inspect "inspect-ts"


fi
test_end

}

test_hls_crypt_seg "block" ""
test_hls_crypt_seg "fullfile" "--fullfile"


test_hls_ext()
{

test_begin "hls-extensions"
if [ $test_skip != 1 ] ; then

manifest=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc::#HLSMExt=vfoo,vbar=video::#HLSVExt=#fooVideo,#bar1=optVideo -i $MEDIA_DIR/auxiliary_files/count_english.mp3::#HLSMExt=afoo,abar=audio-en::#HLSVExt=#fooAudio,#bar1=optAudio  -o $manifest::hlsx=#SomeExt,#SomeOtherExt=true" "hls-ext"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-child1"
do_hash_test "$TEMP_DIR/file_2.m3u8" "hls-child2"

fi
test_end

}

test_hls_ext

test_hls_absu()
{

test_begin "hls-abs-url"
if [ $test_skip != 1 ] ; then

manifest=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/count_english.mp3 -o $manifest:hls_absu=both:base=http://foo.com/bar/" "hls-ext"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/file_1.m3u8" "hls-child1"
do_hash_test "$TEMP_DIR/file_2.m3u8" "hls-child2"

fi
test_end

}

test_hls_absu


test_hls_mvar_aud()
{

test_begin "hls-mvar-audio"
if [ $test_skip != 1 ] ; then

manifest=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/count_english.mp3:#Representation=AudioOne:#HLSGroup=audio1::#HLSMExt=DEFAULT=YES -i $MEDIA_DIR/auxiliary_files/count_english.mp3:#Representation=AudioAlt:#HLSGroup=audio1::#HLSMExt=DEFAULT=NO -o $manifest" "hls-ext"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"

fi
test_end

}

test_hls_mvar_aud

test_hls_mvar_vid()
{

test_begin "hls-mvar-video"
if [ $test_skip != 1 ] ; then

manifest=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_english.mp3 -i $MEDIA_DIR/auxiliary_files/counter.hvc:#Representation=VideoOne:#HLSGroup=video1::#HLSMExt=DEFAULT=YES -i $MEDIA_DIR/auxiliary_files/counter.hvc:#Representation=VideoAlt:#HLSGroup=video1::#HLSMExt=DEFAULT=NO -o $manifest:hls_ap" "hls-ext"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"

fi
test_end

}

test_hls_mvar_vid



test_hls_pl_tpl()
{

test_begin "hls-pl-tpl-$1"
if [ $test_skip != 1 ] ; then

manifest=$TEMP_DIR/file.m3u8
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_english.mp3:#HLSPL=audio/index.m3u8 -i $MEDIA_DIR/auxiliary_files/counter.hvc reframer:#HLSPL="'$Type$'"/index.m3u8 -o $manifest:dual:$2:template="'$Number$' "hls-pl-tpl"
do_hash_test "$TEMP_DIR/file.mpd" "mpd"
do_hash_test "$TEMP_DIR/file.m3u8" "hls-master"
do_hash_test "$TEMP_DIR/audio/index.m3u8" "hls-audio"
do_hash_test "$TEMP_DIR/video/index.m3u8" "hls-video"

fi
test_end

}

test_hls_pl_tpl "live" "profile=live"
test_hls_pl_tpl "vod" "profile=onDemand"
test_hls_pl_tpl "main" "profile=main"
test_hls_pl_tpl "main-sfile" "profile=main:sfile"
