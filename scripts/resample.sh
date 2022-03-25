#!/bin/sh

#rewind video while dumping to yuv

pcmfile="$TEMP_DIR/file.pcm"

myinspect="inspect:test=encode:fmt=@pn@-@dts@-@cts@@lf@"

test_resample()
{
test_begin "resample-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dumpfile=$TEMP_DIR/dump.pcm
do_test "$GPAC -blacklist=ffdec -i $2:index=0 resample$3 @ -o $dumpfile:sstart=1:send=250"  "resample"

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $dumpfile$4 inspect:deep:allp:fmt=%pn%-%cts%-%size%%lf%:log=$myinspect"  "inspect"
do_hash_test "$myinspect" "inspect"

test_end

}

test_resample2()
{
test_begin "resample-$1"

if [ $test_skip  = 1 ] ; then
return
fi

dst=$TEMP_DIR/resamp.$3
do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/raw/raw_2s.pcm:ch=2:sr=44100 resample$2 @ -o $dst"  "resample"
do_hash_test $dst "resample"

test_end

}

test_resample "aac_vbr_51_128k" "$EXTERNAL_MEDIA_DIR/import/aac_vbr_51_128k.aac" ":och=2" ":ch=2:sr=22050"
test_resample "enst_audio" "$MEDIA_DIR/auxiliary_files/enst_audio.aac" ":osr=22050" ":ch=2:sr=22050"

test_resample2 "44k_48k" ":osr=48k" "mp4"
test_resample2 "44k_96k" ":osr=96k" "mp4"
test_resample2 "44k_24k" ":osr=24k" "mp4"
test_resample2 "44k_22k" ":osr=22050" "mp4"

test_resample2 "44k_48k_s32" ":osr=48k:osfmt=s32" "s32"
test_resample2 "44k_22k_s32" ":osr=22050:osfmt=s32" "s32"

test_resample2 "44k_96k_flt" ":osr=96k:osfmt=flt" "flt"
test_resample2 "44k_24k_flt" ":osr=24k:osfmt=flt" "flt"
