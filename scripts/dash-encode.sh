#!/bin/sh

#these tests demonstrate how to use gpac to produce a DASH session with encoding / rescaling
#note that in the video encoding tests, we force intra refresh every second, this matches the default dash duration
#x264 encoder might take different decisions on different platforms/runs so CTS might change and SAPs might be injected, only inspect dts

test_begin "dash-encode-single-v"
if [ $test_skip = 0 ] ; then

#load a video source, decode + resize it , encode it and and dash the result
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:FID=1 ffsws:osize=512x512:SID=1 @ enc:c=avc:fintra=1 @ -o $TEMP_DIR/file.mpd:profile=live" "dash"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/enst_video_dashinit.mp4 "init-v"

#we don't want to test encoder result so hash the inspect timing, dts only: CTS and SAP might change due to reference frame selection by encoder
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:interleave=false:fmt=%pn%-%dts%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi

test_end

test_begin "dash-encode-single-a"
if [ $test_skip = 0 ] ; then

#load an audio source, decode it , encode it and dash the result
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_english.mp3 @ enc:c=aac @ -o $TEMP_DIR/file.mpd:profile=live" "dash"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/count_english_dashinit.mp4 "init-a"

#we don't want to test encoder result so hash the inspect timing and sap
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:interleave=false:fmt=%pn%-%dts%-%cts%-%sap%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi

test_end

test_begin "dash-encode-vv"
if [ $test_skip = 0 ] ; then

#load a source, decode it , resize+encode in two resolutions and dash the result
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264:FID=1 ffsws:osize=512x512:SID=1 @ enc:c=avc:fintra=1:FID=EV1 ffsws:osize=256x256:SID=1 @ enc:c=avc:fintra=1:FID=EV2 -o $TEMP_DIR/file.mpd:profile=live:SID=EV1,EV2 -graph" "dash"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/enst_video_dashinit_rep1.mp4 "init-v1"
do_hash_test $TEMP_DIR/enst_video_dashinit_rep2.mp4 "init-v2"

#we don't want to test encoder result so hash the inspect timing, dts only: CTS and SAP might change due to reference frame selection by encoder
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd  --auto_switch=1 inspect:allp:interleave=false:fmt=%pn%-%dts%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi

test_end


test_begin "dash-encode-avv"
if [ $test_skip = 0 ] ; then

#load a video MP3G-4part2 source, decode it , resize+encode in AVC in two resolutions
#load a an audio MP3 source, decode + encode in AAC
#dash the result
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/count_video.cmp:FID=1 ffsws:osize=512x512:SID=1 @ enc:c=avc:fintra=1:FID=EV1 ffsws:osize=256x256:SID=1 @ enc:c=avc:fintra=1:FID=EV2 -i $MEDIA_DIR/auxiliary_files/count_english.mp3:FID=2  @ enc:c=aac:FID=EA -o $TEMP_DIR/file.mpd:profile=live:SID=EV1,EV2,EA -graph -blacklist=vtbdec" "dash"

do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/count_video_dashinit_rep1.mp4 "init-v1"
do_hash_test $TEMP_DIR/count_video_dashinit_rep2.mp4 "init-v2"
do_hash_test $TEMP_DIR/count_english_dashinit.mp4 "init-a"

#we don't want to test encoder result so hash the inspect timing, dts only: CTS and SAP might change due to reference frame selection by encoder
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd --auto_switch=1 inspect:allp:interleave=false:fmt=%pn%-%dts%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi

test_end

test_begin "dash-encode-mp4box"
if [ $test_skip = 0 ] ; then
mp4file=$TEMP_DIR/source.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -new $mp4file 2> /dev/null

do_test "$MP4BOX -dash 1000 -profile live -out $TEMP_DIR/file.mpd $mp4file:@enc:c=avc:fintra=1" "dash"
do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/source_dashinit.mp4 "init-seg"

#we don't want to test encoder result so hash the inspect timing, dts only: CTS and SAP might change due to reference frame selection by encoder
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:interleave=false:fmt=%pn%-%dts%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi
test_end


test_begin "dash-encode-mp4box-multi"
if [ $test_skip = 0 ] ; then
mp4file=$TEMP_DIR/source.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264  -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file 2> /dev/null

do_test "$MP4BOX -dash 1000 -profile live -out $TEMP_DIR/file.mpd $mp4file#video:@ffsws:osize=64x64@enc:c=avc:fintra=1:b=100k@@ffsws:osize=128x128@enc:c=avc:fintra=1:b=200k $mp4file#audio -graph" "dash"
do_hash_test $TEMP_DIR/file.mpd "mpd"
do_hash_test $TEMP_DIR/source_dash_track1_init_rep1.mp4 "init-seg-vid-rep1"
do_hash_test $TEMP_DIR/source_dash_track1_init_rep2.mp4 "init-seg-vid-rep2"
do_hash_test $TEMP_DIR/source_dash_track2_init.mp4 "init-seg-aud"

#we don't want to test encoder result so hash the inspect timing, dts only: CTS and SAP might change due to reference frame selection by encoder
myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/file.mpd inspect:allp:interleave=false:fmt=%pn%-%dts%%lf%:log=$myinspect" "inspect"
do_hash_test $myinspect "inspect"

fi
test_end


test_begin "dash-encode-aac-mperiod"
if [ $test_skip = 0 ] ; then

src=$TEMP_DIR/source.pcm
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac resample:osr=48k:och=1 @ -o $src" "mkpcm"
src=$TEMP_DIR/source.pcm:sr=48k:ch=1

#do not hash directly, decode diff may happen - hash inspect with no CRC
insp=$TEMP_DIR/sr_inspect.txt
do_test "$GPAC -i $src inspect:deep:test=nocrc:log=$insp" "mkpcm-inspect"
do_hash_test $insp "mkpcm-inspect"


dst=$TEMP_DIR/pcont/manifest.mpd

#also test mpd timescale for segment list and pto
do_test "$GPAC -i $src:FID=GEN:#ClampDur=9.6:#m=m1 reframer:SID=GEN:xs=0,9.6,19.2::props=#PStart=0,#PStart=9.6:#m=m2,#PStart=19.2:#m=m3 @ enc:c=aac:b=69k @ -o $dst:stl:segdur=1.920:timescale=1000:template=\$m\$_\$Type\$_\$Number\$" "dash-pcont"
do_hash_test $dst "mpd-pcont"


dst=$TEMP_DIR/reprime/manifest.mpd

do_test "$GPAC -i $src:FID=GEN:#ClampDur=9.6 reframer:SID=GEN:xs=0:props=#PStart=0:#m=m1 @ enc:c=aac:b=69k:FID=A1 reframer:SID=GEN:xs=9.6:props=#PStart=9.6:#m=m2 @ enc:c=aac:b=69k:FID=A2 reframer:SID=GEN:xs=19.2:props=#PStart=19.2:#m=m3 @ enc:c=aac:b=69k:FID=A3 -o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$:SID=A1,A2,A3" "dash-reprime"
do_hash_test $dst "mpd-reprime"


fi
test_end


test_begin "dash-encode-avc-mperiod"
if [ $test_skip = 0 ] ; then

src=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264

dst=$TEMP_DIR/manifest.mpd
do_test "$GPAC -i $src @ enc:c=avc:fintra=1.920:FID=GEN:#ClampDur=9.6:#m=m1 reframer:SID=GEN:xs=0,9.6,19.2::props=#PStart=0,#PStart=9.6:#m=m2,#PStart=19.2:#m=m3 @ -o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$" "dash"
do_hash_test $dst "mpd-pcont"

fi
test_end


test_begin "dash-encode-aac-avc-mperiod"
if [ $test_skip = 0 ] ; then

srca=$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:gfloc:#Delay=-1024
srcv=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264

#test splicing input in 3 periods, all should have period-continuity
dst=$TEMP_DIR/pcont/manifest.mpd
do_test "$GPAC -i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV reframer:#ClampDur=9.6:SID=GENA,GENV:xs=0,9.6,19.2::props=#PStart=0:#m=m1,#PStart=9.6:#m=m2,#PStart=19.2:#m=m3 @ -o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$" "dash-pcont"
do_hash_test $dst "mpd-pcont"


#test splicing input in 2 periods, the second period shall not have period-continuity
dst=$TEMP_DIR/pdisc/manifest.mpd
do_test "$GPAC -i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV reframer:#ClampDur=9.6:SID=GENA,GENV:xs=0,19.2::props=#PStart=0:#m=m1,#PStart=9.6:#m=m2 @ -o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$" "dash-pdisc"
do_hash_test $dst "mpd-pdisc"

fi
test_end



test_begin "dash-encode-aac-avc-mperiod-splice"
if [ $test_skip = 0 ] ; then

srca=$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:gfloc:#Delay=-1024
srcv=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264

#test splicing input in 2 periods, inserting a third independent content in the middle, there should be period-continuity between first and third
dst=$TEMP_DIR/pcont/manifest.mpd
do_test "$GPAC -i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA1 -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV1 reframer:#ClampDur=9.6:FID=RF1:SID=GENA1,GENV1:xs=0,9.6::props=#PStart=0:#m=m1,#PStart=19.2:#m=m3 \
-i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA2 -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV2 reframer:#ClampDur=9.6:FID=RF2:SID=GENA2,GENV2:xs=9.6:#PStart=9.6:#m=m2:#BUrl=http://ROMAIN \
-o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$:SID=RF1,RF2" "dash-pcont"
do_hash_test $dst "mpd-pcont"


#test splicing input in 2 periods, inserting a third independent content in the middle, there should NOT be period-continuity between first and third
dst=$TEMP_DIR/pdisc/manifest.mpd
do_test "$GPAC -i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA1 -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV1 reframer:#ClampDur=9.6:FID=RF1:SID=GENA1,GENV1:xs=0,19.2::props=#PStart=0:#m=m1,#PStart=19.2:#m=m3 \
-i $srca @ resample:osr=48k:och=1 @ enc:c=aac:FID=GENA2 -i $srcv @ enc:c=avc:fintra=1.920:FID=GENV2 reframer:#ClampDur=9.6:FID=RF2:SID=GENA2,GENV2:xs=9.6:#PStart=9.6:#m=m2:#BUrl=http://ROMAIN \
-o $dst:stl:segdur=1.920:template=\$m\$_\$Type\$_\$Number\$:SID=RF1,RF2" "dash-pdisc"
do_hash_test $dst "mpd-pdisc"

fi
test_end









