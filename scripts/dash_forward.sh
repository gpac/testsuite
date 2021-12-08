#!/bin/sh

src_audio=$EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:bandwidth=64000:dur=4

dash_forward_mpd()
{

test_begin "dash_fwd_mpd_$1"

if [ $test_skip  = 1 ] ; then
 return
fi

if [ $1 == "twores" ] ; then
	hash_seg="counter_30s_I25_baseline_320x180_128kbps_dash2.m4s"
else
	hash_seg="counter_30s_I25_baseline_320x180_128kbps_dash2_rep1.m4s"
fi

do_test "$MP4BOX -dash 2000 -frag 1000 -profile live -out $TEMP_DIR/orig/file.mpd $src1:dur=4 $src2:dur=4:desc_p=<somedesc/> $src_audio" "dash"
do_hash_test $TEMP_DIR/orig/file.mpd "mpd-orig"

do_test "$GPAC -i $TEMP_DIR/orig/file.mpd:forward=mani cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/mani/live.mpd" "encrypt_mani"
do_hash_test $TEMP_DIR/mani/live.mpd "encrypt_mani"
do_hash_test $TEMP_DIR/mani/$hash_seg "encrypt_mani_seg2"

myinspect=$TEMP_DIR/mani/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/mani/live.mpd inspect:deep:interleave=false:log=$myinspect" "inspect_mani"
do_hash_test $myinspect "inspect_mani"

do_test "$GPAC -i $TEMP_DIR/orig/file.mpd:forward=segb cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/segb_mpd/live.mpd" "encrypt_segb_mpd"
do_hash_test $TEMP_DIR/segb_mpd/live.mpd "encrypt_segb_mpd"
do_hash_test $TEMP_DIR/segb_mpd/$hash_seg "encrypt_segb_mpd_seg2"

myinspect=$TEMP_DIR/segb_mpd/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/segb_mpd/live.mpd inspect:deep:interleave=false:log=$myinspect" "inspect_segb_mpd"
do_hash_test $myinspect "inspect_segb_mpd"

do_test "$GPAC -i $TEMP_DIR/orig/file.mpd:forward=segb cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/segb_hls/live.m3u8" "encrypt_segb_hls"
do_hash_test $TEMP_DIR/segb_hls/live.m3u8 "encrypt_segb_hls"
do_hash_test $TEMP_DIR/segb_hls/live_1.m3u8 "encrypt_segb_hls_c1"
do_hash_test $TEMP_DIR/segb_hls/$hash_seg "encrypt_segb_hls_seg2"

myinspect=$TEMP_DIR/segb_hls/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/segb_hls/live.m3u8 inspect:deep:interleave=false:log=$myinspect" "inspect_segb_hls"
do_hash_test $myinspect "inspect_segb_hls"

test_end

}


src1=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:bandwidth=128000
src2=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:bandwidth=200000
dash_forward_mpd "twores"

src1=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:bandwidth=128000
src2=$src1
dash_forward_mpd "oneres"




dash_forward_hls()
{

test_begin "dash_fwd_hls_$1"

if [ $test_skip  = 1 ] ; then
 return
fi

hash_seg="counter_30s_I25_baseline_320x180_128kbps_dash2.m4s"

do_test "$MP4BOX -dash 2000 -frag 1000 -profile live -out $TEMP_DIR/orig/file.m3u8 $src1:dur=4 $src2:dur=4 $src_audio" "dash"
do_hash_test $TEMP_DIR/orig/file.m3u8 "hls-orig"


do_test "$GPAC -i $TEMP_DIR/orig/file.m3u8:forward=mani cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/mani/live.m3u8" "encrypt_mani"
do_hash_test $TEMP_DIR/mani/live.m3u8 "encrypt_mani"
do_hash_test $TEMP_DIR/mani/$hash_seg "encrypt_mani_seg2"

myinspect=$TEMP_DIR/mani/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/mani/live.m3u8 inspect:deep:interleave=false:log=$myinspect" "inspect_mani"
do_hash_test $myinspect "inspect_mani"


do_test "$GPAC -i $TEMP_DIR/orig/file.m3u8:forward=segb cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/segb_mpd/live.mpd" "encrypt_segb_mpd"
do_hash_test $TEMP_DIR/segb_mpd/live.mpd "encrypt_segb_mpd"
do_hash_test $TEMP_DIR/segb_mpd/$hash_seg "encrypt_segb_mpd_seg2"

myinspect=$TEMP_DIR/segb_mpd/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/segb_mpd/live.mpd inspect:deep:interleave=false:log=$myinspect" "inspect_segb_mpd"
do_hash_test $myinspect "inspect_segb_mpd"



do_test "$GPAC -i $TEMP_DIR/orig/file.m3u8:forward=segb cecrypt:cfile=$MEDIA_DIR/encryption/ctr.xml @ -o $TEMP_DIR/segb_hls/live.m3u8" "encrypt_segb_hls"
do_hash_test $TEMP_DIR/segb_hls/live.m3u8 "encrypt_segb_hls"
do_hash_test $TEMP_DIR/segb_hls/live_1.m3u8 "encrypt_segb_hls_c1"
do_hash_test $TEMP_DIR/segb_hls/$hash_seg "encrypt_segb_hls_seg2"

myinspect=$TEMP_DIR/segb_mpd/inspect.txt
do_test "$GPAC --auto_switch=1 -i $TEMP_DIR/segb_hls/live.m3u8 inspect:deep:interleave=false:log=$myinspect" "inspect_segb_hls"
do_hash_test $myinspect "inspect_segb_hls"

test_end

}


src1=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_320x180_128kbps.264:bandwidth=128000
src2=$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_640x360_192kbps.264:bandwidth=200000
dash_forward_hls "twores"





dash_merge_mperiod()
{

test_begin "dash_merge_mperiod"

if [ $test_skip  = 1 ] ; then
 return
fi

#first dash, segment templates with $Number
do_test "$MP4BOX -dash 1000 -profile live -out $TEMP_DIR/dash1/file.mpd $src1:dur=4 $src_audio" "dash1"
do_hash_test $TEMP_DIR/dash1/file.mpd "dash1"

#second dash, using segment timeline and segment templates with $Time
do_test "$MP4BOX -dash 1000 -profile live -out $TEMP_DIR/dash2/file.mpd $src2:dur=4 $src_audio --stl" "dash2"
do_hash_test $TEMP_DIR/dash2/file.mpd "dash2"

#merge manifests only: use sigfrag for manifest-only rewrite, and global --forward=segb so that all dashers forward segment boundaries and template info
do_test "$GPAC -i $TEMP_DIR/dash1/file.mpd:#Period=1 -i $TEMP_DIR/dash2/file.mpd:#Period=2 -o $TEMP_DIR/merge.mpd:sigfrag --forward=segb" "merge"
do_hash_test $TEMP_DIR/merge.mpd "merge"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $TEMP_DIR/merge.mpd inspect:deep:interleave=false:log=$myinspect" "inspect-merge"
do_hash_test $myinspect "inspect-merge"

#test we can merge a multi period and a single period - we can no longer use Period= since period IDs are already defined in merge.mpd
#so we use period start orders instead
do_test "$GPAC -i $TEMP_DIR/merge.mpd:#PStart=-1 -i $TEMP_DIR/dash1/file.mpd:#PStart=-2 -o $TEMP_DIR/remerge.mpd:sigfrag --forward=segb" "remerge"
do_hash_test $TEMP_DIR/remerge.mpd "remerge"

myinspect=$TEMP_DIR/inspect-merge.txt
do_test "$GPAC -i $TEMP_DIR/remerge.mpd inspect:deep:interleave=false:log=$myinspect" "inspect-remerge"
do_hash_test $myinspect "inspect-remerge"

test_end

}

dash_merge_mperiod
