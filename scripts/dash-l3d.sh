#!/bin/sh


rm -f "$TEMP_DIR/l3d"

do_low_delay() {
test_begin "dash-l3d-low_delay"
if [ $test_skip = 1 ] ; then
return
fi
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:FID=AV c=libx264:fintra=2:#ASID=1:SID=AV:FID=SM c=libx264:fintra=0.2:#SSR=1:#ASID=2:SID=AV:FID=STI -o $TEMP_DIR/low_delay.mpd:stl:segdur=2:cdur=0.2:cmf2:SID=SM,STI" "low_delay"
do_hash_test $TEMP_DIR/low_delay.mpd "mpd"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track2_0.m4s.0 "pseg"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track1_0.m4s "seg"

test_end
}

do_low_delay_with_audio() {
test_begin "dash-l3d-low_delay_with_audio"
if [ $test_skip = 1 ] ; then
return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264:FID=V -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:FID=A c=libx264:fintra=2:#ASID=1:SID=V:FID=SMV c=libx264:fintra=0.2:#SSR=1:#ASID=2:SID=V:FID=STV c=aac:#ASID=3:#SSR=-1:SID=A:FID=SMA -o $TEMP_DIR/low_delay.mpd:stl:segdur=2:cdur=0.2:cmf2:SID=SMV,STV,SMA" "low_delay_with_audio"
do_hash_test $TEMP_DIR/low_delay.mpd "mpd"
do_hash_test $TEMP_DIR/counter_30s_audio_dash0.m4s.1 "pseg_audio"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track3_0.m4s.0 "pseg_video"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash_track2_0.m4s "seg_video"

test_end
}

do_llhls_compat() {
test_begin "dash-l3d-llhls_compat"
if [ $test_skip = 1 ] ; then
return
fi

do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 c=libx264:fintra=0.2:#SSR=-1 -o $TEMP_DIR/llhls_compat.mpd:dmode=dynamic:stl:segdur=2:cdur=0.2:cmf2:dual" "llhls_compat"
#we cannot hash the MPD due to dynamic AST/publish time, so we just check for subpart present in the timeline
res=`grep '<S t="0" d="200" r="14" k="10"/>' $TEMP_DIR/llhls_compat.mpd`
if [ "res" = "" ] ; then
	result="MPD fail"
fi

do_hash_test $TEMP_DIR/llhls_compat_1.m3u8 "hls"
do_hash_test $TEMP_DIR/counter_30s_I25_baseline_1280x720_512kbps_dash0.m4s.1 "pseg"

test_end
}

do_low_delay
do_low_delay_with_audio
do_llhls_compat
