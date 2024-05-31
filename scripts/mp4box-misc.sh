


test_mp4box_misc()
{
test_begin "mp4box-misc"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/test.mp4"
mp4file2="$TEMP_DIR/test2.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264+$MEDIA_DIR/auxiliary_files/enst_audio.aac -isma -new $mp4file" "add-plus"
do_hash_test $mp4file "add-plus"

do_test "$MP4BOX -time 2018/07/15-20:30:00 $mp4file" "time"
do_hash_test $mp4file "time"

do_test "$MP4BOX -diod $mp4file" "diod"
do_hash_test $mp4file "diod"
do_test "$MP4BOX -nosys $mp4file" "nosys"
do_hash_test $mp4file "nosys"
do_test "$MP4BOX -dchunk $mp4file -out $TEMP_DIR/chunks.txt" "dchunk"
do_hash_test $TEMP_DIR/chunks.txt "dchunk"
do_test "$MP4BOX -timescale 1000 $mp4file" "settimescale"
do_hash_test $mp4file "settimescale"
do_test "$MP4BOX -delay 101=1000 $mp4file" "delay"
do_hash_test $mp4file "delay"
do_test "$MP4BOX -swap-track-id 101:201 $mp4file" "swaptrackid"
do_hash_test $mp4file "swaptrackid"
do_test "$MP4BOX -set-track-id 101:10 $mp4file" "settrackid"
do_hash_test $mp4file "settrackid"
do_test "$MP4BOX -name 10=test $mp4file" "sethandler"
do_hash_test $mp4file "sethandler"
do_test "$MP4BOX -disable 10 $mp4file" "disable-track"
do_hash_test $mp4file "disable-track"
do_test "$MP4BOX -enable 10 $mp4file" "enable-track"
do_hash_test $mp4file "enable-track"
do_test "$MP4BOX -ref 10:GPAC:1 $mp4file" "set-ref"
do_hash_test $mp4file "set-ref"
do_test "$MP4BOX -rap 10 $mp4file -out $mp4file2" "raponly"
do_hash_test $mp4file2 "raponly"
do_test "$MP4BOX -refonly 10 $mp4file -out $mp4file2" "refonly"
do_hash_test $mp4file2 "refonly"
do_test "$MP4BOX -clap 10=96,1,96,1,20,1,20,1 $mp4file -out $mp4file2" "clap"
do_hash_test $mp4file2 "clap"

do_test "$MP4BOX -clap 10=0,0,0,0,0,0,0,0,0 $mp4file -out $mp4file2" "mx"
do_hash_test $mp4file2 "mx"

do_test "$MP4BOX -cprt supercopyright $mp4file" "cprt"
do_hash_test $mp4file "cprt"
do_test "$MP4BOX -info $mp4file" "cprt-info"

do_test "$MP4BOX -info video $mp4file" "info-name"
do_test "$MP4BOX -info n1 $mp4file" "info-num"

mp4file="$TEMP_DIR/testco64.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -co64 -new $mp4file" "add-co64"
do_hash_test $mp4file "add-co64"

mp4file="$TEMP_DIR/teststz2.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/subtitle.srt:stz2:stype=gsrt:group=2:txtflags=00010101 -new $mp4file" "add-stz2"
do_hash_test $mp4file "add-stz2"

mp4file="$TEMP_DIR/testrvc.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:rvc=$MEDIA_DIR/auxiliary_files/logo.jpg -new $mp4file" "add-rvc"
#zip might produce different binary result, hash the -diso for the file
do_test "$MP4BOX -diso $mp4file" "dump-rvc"
do_hash_test "$TEMP_DIR/testrvc_info.xml" "add-rvc"

mp4file="$TEMP_DIR/hdr.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264 -hdr $MEDIA_DIR/auxiliary_files/hdr.xml -new $mp4file" "hdr"
do_hash_test "$mp4file" "hdr"
insp=$TEMP_DIR/insp.xml
do_test "$GPAC -i $mp4file inspect:deep:analyze=bs:log=$insp" "hdr-insp"
do_hash_test "$insp" "hdr-insp"

cp $MEDIA_DIR/auxiliary_files/enst_video.h264 $TEMP_DIR/test.h264
do_test "$MP4BOX -raw-cat $MEDIA_DIR/auxiliary_files/enst_video.h264 $TEMP_DIR/test.h264" "rawcat"
do_hash_test "$TEMP_DIR/test.h264" "rawcat"

do_test "$MP4BOX -udp-write 127.0.0.1:1234 string_to_write" "udpwrite"

mp4file="$TEMP_DIR/tkgp.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:tkgp=gpac,2 -new $mp4file" "tkgp"
do_hash_test "$mp4file" "tkgp"

test_end
}

test_mp4box_misc


test_mp4box_hdr_av1() {

test_begin "mp4box-hdr-av1"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/hdr.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/hdr/av1_hdr.obu -new $mp4file" "hdr-av1"
do_hash_test "$mp4file" "hdr-av1"
insp=$TEMP_DIR/insp.xml
do_test "$GPAC -i $mp4file inspect:deep:analyze=bs:log=$insp" "hdr-insp-av1"
do_hash_test "$insp" "hdr-insp-av1"


test_end

}
test_mp4box_hdr_av1

