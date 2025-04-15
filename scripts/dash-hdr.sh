#!/bin/sh

rm -f "$TEMP_DIR/hdr"

do_dash_hdr_test(){
    test_begin "dash-hdr-$1"
        do_test "$GPAC -i $EXTERNAL_MEDIA_DIR/hdr/$1.hvc -o $TEMP_DIR/hdr/$1.mpd" "$1"
        do_hash_test $TEMP_DIR/hdr/$1.mpd "mpd"
        do_hash_test $TEMP_DIR/hdr/$1_dashinit.mp4 "init"
        do_hash_test $TEMP_DIR/hdr/$1_dash1.m4s "seg"
    test_end
}

do_dash_hdr_test hevc_bt2020ncl
do_dash_hdr_test hevc_hlg10
do_dash_hdr_test hevc_hlg10_atc
do_dash_hdr_test hevc_pq10
