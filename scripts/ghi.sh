#!/bin/sh

test_ghi()
{

test_begin "$1"

if [ $test_skip  = 1 ] ; then
return
fi

idx_file=$TEMP_DIR/idx.$2
src_file=$TEMP_DIR/src.$3

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/count_english.mp3 -o $src_file$4"  "gen-src"
do_hash_test "$src_file" "gen-src"

do_test "$GPAC -i $src_file$5 -o $idx_file:segdur=2"  "idx"
do_hash_test "$idx_file" "idx"

#generate manifest + init segments
dst_mpd=$TEMP_DIR/vod.mpd
do_test "$GPAC -i $idx_file:gm=all$6 -o $dst_mpd$7"  "mpd"
do_hash_test "$dst_mpd" "mpd"

if [ "$7" = "" ] ; then
do_hash_test "$TEMP_DIR/1-init.mp4" "init"
fi

#generate master manifest only
dst_hls=$TEMP_DIR/vod.m3u8
do_test "$GPAC -i $idx_file:gm=main$6 -o $dst_hls$7"  "hls"
do_hash_test "$dst_hls" "hls"

#generate child manifest only
child_hls=$TEMP_DIR/vod_r1.m3u8
do_test "$GPAC -i $idx_file:gm=child:rep=1$6:out=$child_hls -o $dst_hls$7"  "hls-child"
do_hash_test "$child_hls" "hls-child"

if [ "$7" = "" ] ; then
#generate rep1 init only
rep_init=$TEMP_DIR/vod_r1.mp4
do_test "$GPAC -i $idx_file:gm=init:rep=1$6:out=$rep_init -o $dst_hls$7"  "hls-init"
do_hash_test "$rep_init" "hls-init"
fi

#generate seg 4
rep_seg=$TEMP_DIR/vod_r1_4.m4s
do_test "$GPAC -i $idx_file:rep=1$6:sn=4:out=$rep_seg -o $dst_hls$7"  "seg-gen"
do_hash_test "$rep_seg" "seg-gen"

#do_test "$GPAC --initseg=$TEMP_DIR/vod_r1.mp4 -i $TEMP_DIR/vod_r1_4.m4s vout" "play"

test_end

}

test_ghi "ghi-mp4" "ghi" "mp4" "" ":nodata=yes" "" ""

test_ghi "ghix-fmp4" "ghix" "mp4" ":frag" ":sigfrag:nodata=yes" "" ""

test_ghi "ghi-ts-mux" "ghi" "ts" "" ":sigfrag" ":mux=2@1" ""

test_ghi "ghi-mux-ts" "ghi" "mp4" "" ":sigfrag" ":mux=2@1" ":muxtype=ts"


#test on the fly encryption
test_ghi_crypt()
{

test_begin "ghi-crypt"

if [ $test_skip  = 1 ] ; then
return
fi

idx_file=$TEMP_DIR/idx.ghix
src_file=$TEMP_DIR/src.mp4

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/count_english.mp3 -o $src_file"  "gen-src"
do_hash_test "$src_file" "gen-src"

do_test "$GPAC -i $src_file -o $idx_file:segdur=2"  "idx"
do_hash_test "$idx_file" "idx"

#generate manifest + init segments with encryption
dst_mpd=$TEMP_DIR/vod.mpd
cfile=$MEDIA_DIR/encryption/ctr.xml
do_test "$GPAC -i $idx_file:gm=all cecrypt:cfile=$cfile -o $dst_mpd"  "mpd"
do_hash_test "$dst_mpd" "mpd"
do_hash_test "$TEMP_DIR/1-init.mp4" "init"

#generate seg 4
rep_seg=$TEMP_DIR/vod_r1_4.m4s
do_test "$GPAC -i $idx_file:rep=1:sn=4:out=$rep_seg cecrypt:cfile=$cfile -o $dst_mpd"  "seg-gen"
do_hash_test "$rep_seg" "seg-gen"

#do_test "$GPAC --initseg=$TEMP_DIR/1-init.mp4 -i $rep_seg vout" "play"

test_end

}


#test on the fly encryption
test_ghi_transcode()
{

test_begin "ghi-transcode"

if [ $test_skip  = 1 ] ; then
return
fi

idx_file=$TEMP_DIR/idx.ghix
src_file=$TEMP_DIR/src.mp4

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/subtitle.srt -o $src_file"  "gen-src"
do_hash_test "$src_file" "gen-src"

do_test "$GPAC -i $src_file -o $idx_file:segdur=2"  "idx"
do_hash_test "$idx_file" "idx"

bl="-blacklist=vtbdec,ohevcdec,osvcdec,nvdec"
#generate manifest + init segments with video transcode hevc->avc and tx3g->ttml
dst_mpd=$TEMP_DIR/vod.mpd
do_test "$GPAC -i $idx_file:gm=all c=avc:b=1m tx3g2ttml -o $dst_mpd $bl"  "mpd"
do_hash_test "$dst_mpd" "mpd"
do_hash_test "$TEMP_DIR/1-init.mp4" "init"

#generate seg 4 of rep 1 (video)
rep_seg=$TEMP_DIR/vod_r1_4.m4s
do_test "$GPAC -i $idx_file:rep=1:sn=4:out=$rep_seg c=avc:b=1m -o $dst_mpd $bl"  "seg-vid"

#do a hash on inspect (encoder output will vary across platforms)
myinspect="inspect:test=encx:fmt=@pn@-@dts@-@cts@@lf@"
insfile=$TEMP_DIR/dump.txt
do_test "$GPAC --initseg=$TEMP_DIR/1-init.mp4 -i $rep_seg $myinspect:log=$insfile" "seg-vid-insp"
do_hash_test "$insfile" "seg-vid"


#do_test "$GPAC --initseg=$TEMP_DIR/1-init.mp4 -i $rep_seg vout" "play"

#generate seg 4 of rep 2 (subs)
rep_seg=$TEMP_DIR/vod_r2_4.m4s
do_test "$GPAC -i $idx_file:rep=2:sn=4:out=$rep_seg tx3g2ttml -o $dst_mpd $bl"  "seg-sub"
do_hash_test "$rep_seg" "seg-sub"

test_end

}

test_ghi_transcode


#test subs indexing
test_ghi_subs()
{

test_begin "ghi-subs"

if [ $test_skip  = 1 ] ; then
return
fi

idx_file=$TEMP_DIR/idx.ghix
src_file=$TEMP_DIR/subs.srt
#copy so that we have same hash with and without -tmp
cp $MEDIA_DIR/auxiliary_files/subtitle.srt $src_file

do_test "$GPAC -i $src_file -o $idx_file:segdur=2"  "idx"
do_hash_test "$idx_file" "idx"

#generate manifest + init segments with tx3g->ttml
dst_mpd=$TEMP_DIR/vod.mpd
do_test "$GPAC -i $idx_file:gm=all -o $dst_mpd"  "mpd"
do_hash_test "$dst_mpd" "mpd"
do_hash_test "$TEMP_DIR/1-init.mp4" "init"

#generate seg 4 of rep 1 (subs)
rep_seg=$TEMP_DIR/vod_r1_4.m4s
do_test "$GPAC -i $idx_file:rep=1:sn=4:out=$rep_seg -o $dst_mpd"  "seg-sub"
do_hash_test "$rep_seg" "seg-sub"

test_end

}

test_ghi_subs
