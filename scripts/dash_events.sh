#!/bin/sh

dash_event_test()
{
    test_begin $1
    if [ $test_skip  = 1 ] ; then
        return
    fi

    do_test "$GPAC -i $mp4file -o $TEMP_DIR/file.mpd::inband_event=https://aomedia.org/emsg/ID3@https://aomedia.org/emsg/ID3@audio,https://aomedia.org/emsg/ID3@www.nielsen.com:id3:v1@audio" "dash"
    do_hash_test $TEMP_DIR/file.mpd "$1-hash-mpd"

    test_end
}

mp4file=$TEMP_DIR/file.mp4
$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac -o $mp4file 2> /dev/null

dash_event_test "inband-events"
