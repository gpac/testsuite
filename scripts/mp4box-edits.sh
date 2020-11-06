


test_begin "mp4box-edits"
if [ "$test_skip" = 1 ] ; then
return
fi

mp4file="$TEMP_DIR/first.mp4"

#remove edits, add empty 5sec then 3 sec starting at 4 in media track
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_video.h264:edits=re0-5/1e5-3/1,4/1 -new $mp4file" "add"
do_hash_test $mp4file "add-edits"

mp4file2="$TEMP_DIR/second.mp4"
#remove edits, add single edit 4 sec starting at 0 in media track at speed x2
do_test "$MP4BOX -edits 1=re0-4/1,0/1,2/1 $mp4file -out $mp4file2" "set-edits"
do_hash_test $mp4file "set-edits"


test_end



