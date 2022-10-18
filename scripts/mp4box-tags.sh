

test_begin "mp4box-tags"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file -itags cover=$MEDIA_DIR/auxiliary_files/logo.png:genre=Game" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -info $mp4file" "info"

covfile="$TEMP_DIR/test.png"
do_test "$MP4BOX -dump-cover $mp4file -out $covfile" "dumpcover"
do_hash_test $covfile "dumpcover"

fi
test_end


test_begin "mp4box-tags-file"
if [ "$test_skip" != 1 ] ; then

tagfile="tags.txt"
echo "title=A9nam-TEST-name
artist=A9ART-TEST
album_artist=aART-TEST-albumArtist
album=A9alb-TEST
group=A9grp-TEST-grouping
composer=A9com-TEST
writer=A9wrt-TEST
conductor=A9con-TEST
comment=A9cmt-TEST-comments
genre=gnre-TEST-ID3 genre tag
created=A9day-TEST-releaseDate
track=A9trk-TEST
tracknum=55
disk=33
tempo=tmpo- integer
compilation=no
show=tvsh-TEST-tvShow
episode_id=tven-TEST-tvEpisodeID
season=33
episode=44
network=tvnn-TEST-tvNetwork
sdesc=desc-TEST-description
ldesc=ldes-TEST-longDescription
lyrics=A9lyr-TEST
sort_name=sonm-TEST-sortName
sort_artist=soar-TEST-sortArtist
sort_album_artist=soaa-TEST-sortAlbumArtist
sort_album=soal-TEST-sortAlbum
sort_composer=soco-TEST-sortComposer
sort_show=sosn-TEST-sortShow
copyright=cprt-TEST
tool=A9too-TEST-encodingTool
encoder=A9enc-TEST-encodedBy
pdate=purd-TEST-purchaseDate
podcast=no
url=purl-TEST-podcastURL
keywords=kyyw-TEST
category=catg-TEST
hdvideo=hdvd- integer
media=1
rating=1
gapless=yes
art_director=A9ard-TEST
arranger=A9arg-TEST
lyricist=A9aut-TEST
acknowledgement=A9cak-TEST
song_description=A9des-TEST
director=A9dir-TEST
equalizer=A9equ-TEST
liner=A9lnt-TEST
record_company=A9mak-TEST
original_artist=A9ope-TEST
phono_rights=A9phg-TEST
producer=A9prd-TEST
performer=A9prf-TEST
publisher=A9pub-TEST
sound_engineer=A9sne-TEST
soloist=A9sol-TEST
credits=A9src-TEST
thanks=A9thx-TEST
online_info=A9url-TEST
exec_producer=A9xpd-TEST
cover=$MEDIA_DIR/auxiliary_files/logo.jpg" > $tagfile


mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac:dur=1 -new $mp4file -itags $tagfile" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -disox $mp4file" "diso"
do_hash_test $TEMP_DIR/test_info.xml "diso"

mv $tagfile $TEMP_DIR

clean="$TEMP_DIR/clean.mp4"
do_test "$MP4BOX -itags clear $mp4file -out $clean" "clean"
do_hash_test $clean "clean"

fi
test_end

test_begin "mp4box-xtra-tags"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file -itags WM/Producer=GPAC" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -info $mp4file" "info"
fi
test_end



test_begin "mp4box-opus-tags"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $EXTERNAL_MEDIA_DIR/misc/36-11-pictures.opus -new $mp4file" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -info $mp4file" "info"
fi
test_end


test_begin "mp4box-qt-tags"
if [ "$test_skip" != 1 ] ; then

mp4file="$TEMP_DIR/test.mp4"
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/enst_audio.aac -new $mp4file" "create"
do_hash_test $mp4file "create"

do_test "$MP4BOX -tags io.gpac.test=SomeString $mp4file" "str"
do_hash_test $mp4file "str"

do_test "$MP4BOX -tags io.gpac.test2=32x32 $mp4file" "pt"
do_hash_test $mp4file "pt"

do_test "$MP4BOX -tags io.gpac.test3=32@32 $mp4file" "sz"
do_hash_test $mp4file "sz"

do_test "$MP4BOX -tags io.gpac.test4=32x32@32x32 $mp4file" "rect"
do_hash_test $mp4file "rect"

do_test "$MP4BOX -tags io.gpac.test5=s+32 $mp4file" "s32"
do_hash_test $mp4file "s32"

do_test "$MP4BOX -tags io.gpac.test6=1,1,1,1,1,1,1,1,1 $mp4file" "mx"
do_hash_test $mp4file "s32"

do_test "$MP4BOX -tags io.gpac.test7=$MEDIA_DIR/auxiliary_files/logo.png $mp4file" "img"
do_hash_test $mp4file "img"


do_test "$MP4BOX -tags io.gpac.test3= $mp4file" "rm"
do_hash_test $mp4file "rm"

#test with gpac
mp4file="$TEMP_DIR/test-gpac.mp4"
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_audio.aac:#qtt_io.gpac.test=10.0 -o $mp4file" "gpac"
do_hash_test $mp4file "gpac"

fi
test_end


