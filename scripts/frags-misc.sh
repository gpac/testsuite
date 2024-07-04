#!/bin/sh

test_begin "frags-no-align"
 if [ $test_skip != 1 ] ; then

#fragment a ttml as single doc and don't realign timeline
mydst=$TEMP_DIR/frag_no_align.m4s
do_test "$GPAC -i $MEDIA_DIR/ttml/ebu-ttd_prefix.ttml:ttml_split=0:ttml_cts=-2 -o $mydst:frag:tsalign=0" "frag"
do_hash_test $mydst "frag"

test_end
fi

test_begin "frags-tfdt"
 if [ $test_skip != 1 ] ; then

#fragment a ttml as multiple doc and set tfdt
mydst=$TEMP_DIR/frag_no_align.m4s
do_test "$GPAC -i $MEDIA_DIR/ttml/ebu-ttd_prefix.ttml -o $mydst:frag:tfdt=10" "frag"
do_hash_test $mydst "frag"

test_end
fi

test_begin "frags-straf"
 if [ $test_skip != 1 ] ; then

#fragment a ttml as single doc and don't realign timeline
mydst=$TEMP_DIR/frag_straf.mp4
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -i $MEDIA_DIR/auxiliary_files/counter.hvc -o $mydst:frag:straf:strun:fragdur::cmfc:cdur=1:" "frag"
do_hash_test $mydst "frag"

test_end
fi
