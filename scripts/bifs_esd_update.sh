#!/bin/sh

# Regression test for https://github.com/gpac/gpac/issues/3986
# A failed MuxInfo import inside an UPDATE ESD command must produce a
# clean error exit, not a heap-use-after-free during scene cleanup.
# The referenced media file does not exist, so the ESD update import
# fails and MP4Box reports the error (negative test, see rules file).

test_begin "bifs-esd-update-missing-muxinfo"
if [ $test_skip = 1 ] ; then
	return
fi

btfile="$MEDIA_DIR/bifs/bifs-esd-update-missing-muxinfo.bt"
outfile="$TEMP_DIR/bifs-esd-update-missing-muxinfo.mp4"

do_test "$MP4BOX -mp4 $btfile -out $outfile" "esd-update-import-fail"

test_end
