#this tests a web radio, exercising icy meta skip and chunk transfer

test_begin "uncv"
if [ $test_skip  = 1 ] ; then
return
fi

mp4file=$TEMP_DIR/file.heif
do_test "$GPAC uncvg:c=R,G,B:dur=0 -o $mp4file" "heif"
do_hash_test $mp4file "heif"
do_test "$GPAC -i $mp4file inspect" "heif-inspect"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_heif.rgb --force_pf" "dec-heif"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-heif"

#test uncv profile: we use the previous rgb dump as source and mux as track using tiny uncv embedding
mp4file=$TEMP_DIR/file.mp4
do_test "$GPAC -i $TEMP_DIR/dump_heif.rgb:size=128x128 -o $mp4file:uncv=tiny" "simple"
do_hash_test $mp4file "simple"
do_test "$GPAC -i $mp4file inspect" "simple-inspect"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_mp4.rgb --force_pf" "dec-mp4"
do_hash_test $TEMP_DIR/dump_mp4.rgb "dec-mp4"

suf="pix"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:pixel_size=4 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="blk"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:block_size=4 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="blkpix"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R,G,B:dur=1/25:block_size=4:pixel_size=6 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="pixa"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=R9,G10+2,B9:dur=1/25 -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="yuv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,V:dur=1/25:sampling=420:interleave=comp -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="yv12"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,V:dur=1/25:sampling=420:interleave=mix -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="yuyv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,Y,V:dur=1/25:sampling=422:interleave=multi -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="422"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,Y,V:dur=1/25:sampling=422:interleave=multi -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="yyuyyv"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,Y,U,Y,Y,V:dur=1/25:sampling=411:interleave=multi -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"

suf="422p"
mp4file=$TEMP_DIR/file_$suf.mp4
do_test "$GPAC uncvg:c=Y,U,V:dur=1/25:sampling=422:interleave=comp -o $mp4file" "$suf"
do_hash_test $mp4file "$suf"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_$suf.rgb --force_pf" "dec-$suf"
do_hash_test $TEMP_DIR/dump_$suf.rgb "dec-$suf"


mp4file=$TEMP_DIR/file_pal.mp4
do_test "$GPAC uncvg:c=p:dur=0 -o $mp4file" "palette"
do_hash_test $mp4file "palette"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_palette.rgb --force_pf" "dec-palette"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-palette"

mp4file=$TEMP_DIR/file_fa.mp4
do_test "$GPAC uncvg:c=f:dur=0 -o $mp4file" "fa"
do_hash_test $mp4file "fa"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_palette.rgb --force_pf" "dec-fa"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-fa"

mp4file=$TEMP_DIR/file_planar.mp4
do_test "$GPAC uncvg:c=R,G,B:comp:dur=0 -o $mp4file" "planar"
do_hash_test $mp4file "planar"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_palette.rgb --force_pf" "dec-planar"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-planar"

mp4file=$TEMP_DIR/file_tiles.mp4
do_test "$GPAC uncvg:c=R,G,B:tiles=2x2:dur=0 -o $mp4file" "tiles"
do_hash_test $mp4file "tiles"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_palette.rgb --force_pf" "dec-tiles"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-tiles"

mp4file=$TEMP_DIR/file_tiles_planar.mp4
do_test "$GPAC uncvg:c=R,G,B:tiles=2x2:comp:dur=0 -o $mp4file" "tiles-planar"
do_hash_test $mp4file "tiles-planar"
do_test "$GPAC -i $mp4file -o $TEMP_DIR/dump_palette.rgb --force_pf" "dec-tiles-planar"
do_hash_test $TEMP_DIR/dump_heif.rgb "dec-tiles-planar"


test_end

