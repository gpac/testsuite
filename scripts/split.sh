#!/bin/sh

test_split()
{

test_begin "split-$1"

if [ $test_skip  = 1 ] ; then
return
fi

mydst=$TEMP_DIR/extract_\$num\$.$4

#do_test "$GPAC -i $2 reframer$3 @ inspect:deep:interleave=false:log=$myinspect @1 -o $mydst"  "split"
#do_hash_test "$myinspect" "split"
do_test "$GPAC -i $2 reframer$3 @ -o $mydst $5"  "split"

#multi output file cases
if [ $6 = 1 ] ; then
do_hash_test "$TEMP_DIR/extract_1.$4" "split1"
do_hash_test "$TEMP_DIR/extract_2.$4" "split2"

#mkv case, don't check hash
elif [ $6 = 2 ] ; then

if [ ! -f "$TEMP_DIR/extract_0.$4" ] ; then
result="MKV not present"
fi

#single output file cases
else
do_hash_test "$TEMP_DIR/extract_0.$4" "split"
fi

test_end

}

test_split "raw-single-range-to-mp4" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500:xe=T00:00:04.500" "mp4" "" 0
test_split "raw-single-range-to-fmp4" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500:xe=T00:00:04.500" "mp4" "--store=frag" 0
test_split "raw-single-range-to-ts" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500:xe=T00:00:04.500" "ts" "--pcr_init=10000" 0
test_split "raw-single-range-to-mkv" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500:xe=T00:00:04.500" "mkv" "" 2

test_split "raw-dual-range-to-mp4" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500" "mp4" "" 0

test_split "raw-dual-ranges-to-mp4" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "" 1
test_split "raw-dual-ranges-to-fmp4" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "--store=frag" 1
test_split "raw-dual-ranges-to-ts" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "ts" "--pcr_init=10000" 1

test_split "raw-frames" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=F100:xs=F200" "mp4" "" 0
test_split "raw-sap" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=SAP" "mp4" "" 1
test_split "raw-dur" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=D2" "mp4" "" 1
test_split "raw-size" $MEDIA_DIR/auxiliary_files/count_video.cmp ":xs=S100k" "mp4" "" 1

#create simple MP4 with both audio and video
src=$TEMP_DIR/src.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/count_video.cmp -add $MEDIA_DIR/auxiliary_files/count_english.mp3 -new $src 2>/dev/null

test_split "av-dual-ranges-to-mp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "" 1
test_split "av-dual-ranges-to-fmp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "--store=frag" 1
test_split "av-dur" $src ":xs=D2" "mp4" "" 1
test_split "av-size" $src ":xs=S100k" "mp4" "" 1

#create simple MP4 with audio, video and subs
src=$TEMP_DIR/src.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/count_video.cmp -add $MEDIA_DIR/auxiliary_files/count_english.mp3  -add $MEDIA_DIR/auxiliary_files/subtitle.srt -new $src 2>/dev/null

test_split "avt-dual-ranges-to-mp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "" 1
test_split "avt-dual-ranges-to-fmp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "--store=frag" 1
test_split "avt-dur" $src ":xs=D2" "mp4" "" 1
test_split "avt-size" $src ":xs=S100k" "mp4" "" 1

#create simple MP4 with video and BIIFS/OD
src=$TEMP_DIR/src.mp4
$MP4BOX -add $MEDIA_DIR/auxiliary_files/count_video.cmp -isma -new $src 2>/dev/null

test_split "bifs-dual-ranges-to-mp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "" 1
test_split "bifs-dual-ranges-to-fmp4" $src ":xs=T00:00:02.500,T00:00:08.100:xe=T00:00:04.500,T00:00:09.500:splitrange" "mp4" "--store=frag" 1
test_split "bifs-dur" $src ":xs=D2" "mp4" "" 1
test_split "bifs-size" $src ":xs=S100k" "mp4" "" 1

test_split "raw-startonly" $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264 ":xs=0,10.0,18.0:splitrange" "mp4" "" 1

#create simple MP4 with video and audio
src=$TEMP_DIR/src.mp4
$GPAC -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_1280x720_512kbps.264 -i $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:#Delay=-1024 -o $src 2>/dev/null
#test sample-accurate range extraction, this should give us exactly one second of audio and video in output
test_split "seek" $src ":xs=30/25:xe=55/25:xround=seek" "mp4" "" 0

#create simple MP4 with video, audio and timecode
src=$TEMP_DIR/src_tc.mp4
$MP4BOX -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_main_1280x720_512kbps.264:tc=25,1,20,0,0 -add $EXTERNAL_MEDIA_DIR/counter/counter_30s_audio.aac:tkidx=2:sopt:#Delay=-1024 -new $src 2>/dev/null
#test  range extraction with tmcd
test_split "tc" $src ":xs=30/25:xe=55/25" "mp4" "" 0
#test sample-accurate range extraction with tmcd, this should give us exactly one second of audio, video and tmcd in output
test_split "tc-seek" $src ":xs=30/25:xe=55/25:xround=seek" "mp4" "" 0



test_split_props()
{

test_begin "split-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dst=$TEMP_DIR/split.mpd

do_test "$GPAC -i $2 reframer$3 @ -o $dst"  "split"
do_hash_test $dst "split"

inspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $dst inspect:deep:interleave=false:log=$inspect" "inspect"
do_hash_test "$inspect" "split"


test_end
}


test_split_props "props" "$EXTERNAL_MEDIA_DIR/counter/counter_30s_I25_baseline_1280x720_512kbps.264" ":xs=0,10.0,25.0:xe=5.0,15.0:props=#Period=P1,#Period=P2,#Period=P3"
