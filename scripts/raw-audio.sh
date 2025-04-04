#test raw video

raw_audio_test ()
{

test_begin "raw-aud-$1"
if [ $test_skip  = 1 ] ; then
return
fi

rawfile=$TEMP_DIR/raw.$1
#test dumping to the given format - use faad
do_test "$GPAC -blacklist=ffdec -i $mp4file -o $rawfile" "dump-$1"

#on linux 32 bit and arm we for now disable the hashes, they all differ due to different float/double precision
do_hash=1
if [ $GPAC_OSTYPE = "lin32" ] ; then
do_hash=0
elif [ $GPAC_CPU = "arm" ] ; then
do_hash=0
fi

if [ $do_hash = 1 ] ; then
do_hash_test_bin "$rawfile" "dump-$1"
fi

myinspect="inspect:fmt=@pn@-@cts@-@bo@@lf@"
insfile=$TEMP_DIR/dump.txt
do_test "$GPAC -i $rawfile:sr=48000:ch=2 $myinspect:log=$insfile" "inspect"
do_hash_test "$insfile" "inspect"

#test reading from the given format into pcm
rawfile2=$TEMP_DIR/raw2.pcm
do_test "$GPAC -i $rawfile -o $rawfile2" "dump-pcm"
if [ $do_hash = 1 ] ; then
do_hash_test_bin "$rawfile2" "dump-pcm"
fi

#only do the reverse tests for pcm (same for the other formats)
if [ $1  = "pcm" ] ; then

#playback test at 10x speed - this exercices audio output
do_test "$GPAC -i $rawfile:sr=48000:ch=2 aout:speed=10:vol=0 -graph" "play"

myinspect="inspect:speed=-1:fmt=@pn@-@cts@-@bo@@lf@"
insfile=$TEMP_DIR/dumpns.txt
do_test "$GPAC -i $rawfile:sr=48000:ch=2 $myinspect:log=$insfile" "inspect_reverseplay"
do_hash_test "$insfile" "inspect_reverseplay"


#playback test at -10x speed - this exercices audio output
do_test "$GPAC -i $rawfile:sr=48000:ch=2 aout:speed=-10:vol=0" "reverse_play"

fi

case $1 in
"pcm" | "pcmb" | "s24" | "s24b" | "s32" | "s32b" | "flt" | "fltb" | "dbl" | "dblb")
#test isobmff pcm encapsulation
do_test "$GPAC -i $rawfile:sr=48000:ch=2 -o $TEMP_DIR/pcm.mp4:ase=v1" "isobmff-write"
do_test "$GPAC -i $rawfile:sr=48000:ch=2 -o $TEMP_DIR/pcm.mov" "qtff-write"
do_test "$GPAC -i $rawfile:sr=48000:ch=2 -o $TEMP_DIR/pcm2.mov:ase=v2qt" "qtff2-write"
if [ $do_hash = 1 ] ; then
do_hash_test "$TEMP_DIR/pcm.mp4" "isobmff-write"
do_hash_test "$TEMP_DIR/pcm.mov" "qtff-write"
do_hash_test "$TEMP_DIR/pcm2.mov" "qtff2-write"
fi
#disable crc test, only check isom structure
insfile=$TEMP_DIR/dump_isopcm.txt
do_test "$GPAC -i $TEMP_DIR/pcm.mp4 inspect:deep:log=$insfile:test=nocrc" "isobmff-read"
do_hash_test "$insfile" "isobmff-read"
insfile=$TEMP_DIR/dump_qtpcm.txt
do_test "$GPAC -i $TEMP_DIR/pcm.mov inspect:log=$insfile:test=nocrc" "qtff-read"
do_hash_test "$insfile" "qtff-read"
insfile=$TEMP_DIR/dump_qtpcm2.txt
do_test "$GPAC -i $TEMP_DIR/pcm2.mov inspect:log=$insfile:test=nocrc" "qtff2-read"
do_hash_test "$insfile" "qtff2-read"
;;
esac



test_end
}

#we do a test with 0.4 seconds. using more results in higher dynamics in the signal which are not rounded the same way on all platforms
mp4file="$TEMP_DIR/aud.mp4"
$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=0.4 -new $mp4file 2> /dev/null

#complete lists of audio formats extensions in gpac
afstr="pc8 pcm pcmb s24 s24b s32 s32b flt fltb dbl dblb pc8p pcmp s24p s32p fltp dblp"

for i in $afstr ; do
	raw_audio_test $i
done

