#!/bin/sh
test_begin "iff-grid"

 if [ $test_skip = 1 ] ; then
  return
 fi

#create single-frame AV1
src=$TEMP_DIR/img.av1
do_test "$MP4BOX -add $MEDIA_DIR/auxiliary_files/video.av1:dur=-1 -new $TEMP_DIR/temp.mp4" "import-av1"
do_test "$MP4BOX -raw 1 -out $src $TEMP_DIR/temp.mp4" "export-av1"
do_hash_test $src "src-av1"


# mirroring
dst=$TEMP_DIR/mirror-vert-axis.avif
do_test "$MP4BOX -add-image $src:mirror-axis=vertical:primary -ab avif -ab miaf -new $dst" "mirror-vert"
do_hash_test $dst "mirror-vert"

dst=$TEMP_DIR/mirror-horiz-axis.avif
do_test "$MP4BOX -add-image $src:mirror-axis=horizontal:primary -ab avif -ab miaf -new $dst" "mirror-horiz"
do_hash_test $dst "mirror-horiz"

# cropping
dst=$TEMP_DIR/clap-center-50percent.avif
do_test "$MP4BOX -add-image $src:clap=1024,1,429,1,0,1,0,1:primary -ab avif -ab miaf -new $dst" "clap-center"
do_hash_test $dst "clap-center"

dst=$TEMP_DIR/clap-topleft-50percent.avif
do_test "$MP4BOX -add-image $src:clap=1024,1,429,1,-512,1,-214,1:primary -ab avif -ab miaf -new $dst" "clap-topleft"
do_hash_test $dst "clap-topleft"

dst=$TEMP_DIR/clap-left-50percent.avif
do_test "$MP4BOX -add-image $src:clap=1024,1,429,1,-512,1,0,1:primary -ab avif -ab miaf -new $dst" "clap-left"
do_hash_test $dst "clap-left"

# rotate
dst=$TEMP_DIR/rotate90.avif
do_test "$MP4BOX -add-image $src:rotation=90:primary -ab avif -ab miaf -new $dst" "rot90"
do_hash_test $dst "rot90"

dst=$TEMP_DIR/rotate180.avif
do_test "$MP4BOX -add-image $src:rotation=180:primary -ab avif -ab miaf -new $dst" "rot180"
do_hash_test $dst "rot180"

dst=$TEMP_DIR/rotate270.avif
do_test "$MP4BOX -add-image $src:rotation=270:primary -ab avif -ab miaf -new $dst" "rot270"
do_hash_test $dst "rot270"

# combined transforms
dst=$TEMP_DIR/mirror-clap.avif
do_test "$MP4BOX -add-image $src:mirror-axis=vertical:clap=1024,1,429,1,-512,1,0,1:primary -ab avif -ab miaf -new $dst" "mirror-clap"
do_hash_test $dst "mirror-clap"

dst=$TEMP_DIR/clap-mirror.avif
do_test "$MP4BOX -add-image $src:clap=1024,1,429,1,-512,1,0,1:mirror-axis=vertical:primary -ab avif -ab miaf -new $dst" "clap-mirror"
do_hash_test $dst "clap-mirror"

dst=$TEMP_DIR/mirror-rotate.avif
do_test "$MP4BOX -add-image $src:mirror-axis=vertical:rotation=90:primary -ab avif -ab miaf -new $dst" "mirror-rotate"
do_hash_test $dst "mirror-rotate"

dst=$TEMP_DIR/rotate-mirror.avif
do_test "$MP4BOX -add-image $src:rotation=90:mirror-axis=vertical:primary -ab avif -ab miaf -new $dst" "rotate-mirror"
do_hash_test $dst "rotate-mirror"

dst=$TEMP_DIR/clap-rotate.avif
do_test "$MP4BOX -add-image $src:clap=1024,1,429,1,-512,1,0,1:rotation=90:primary -ab avif -ab miaf -new $dst" "clap-rotate"
do_hash_test $dst "clap-rotate"

dst=$TEMP_DIR/rotate-clap.avif
do_test "$MP4BOX -add-image $src:rotation=90:clap=1024,1,429,1,-512,1,0,1:primary -ab avif -ab miaf -new $dst" "rotate-clap"
do_hash_test $dst "rotate-clap"

dst=$TEMP_DIR/rotate-clap-mirror.avif
do_test "$MP4BOX -add-image $src:rotation=90:clap=1024,1,429,1,-512,1,0,1:mirror-axis=vertical:primary -ab avif -ab miaf -new $dst" "rotate-clap-mirror"
do_hash_test $dst "rotate-clap-mirror"

# grids
dst=$TEMP_DIR/grid_2x1.avif
do_test "$MP4BOX -add-image-grid grid:id=1:image-size=4096x858:image-grid-size=1x2:ref=dimg,2:ref=dimg,3:primary -add-image $src:id=2 -add-image $src:id=3 -ab avif -new $dst" "grid_2x1"
do_hash_test $dst "grid_2x1"

dst=$TEMP_DIR/grid_2x2.avif
do_test "$MP4BOX -add-image-grid grid:id=1:image-size=4096x1716:image-grid-size=2x2:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -ab avif -ab miaf -new $dst" "grid_2x2"
do_hash_test $dst "grid_2x2"

dst=$TEMP_DIR/grid_2x3_192x128.avif
do_test "$MP4BOX -add-image-grid grid:id=1:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128"
do_hash_test $dst "grid_2x3_192x128"

# grid transforms
dst=$TEMP_DIR/grid_2x3_192x128_rotate.avif
do_test "$MP4BOX -add-image-grid grid:id=1:rotation=90:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_rotate"
do_hash_test $dst "grid_2x3_192x128_rotate"

dst=$TEMP_DIR/grid_2x3_192x128_mirror.avif
do_test "$MP4BOX -add-image-grid grid:id=1:mirror-axis=vertical:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_mirror"
do_hash_test $dst "grid_2x3_192x128_mirror"

dst=$TEMP_DIR/grid_2x3_192x128_clap.avif
do_test "$MP4BOX -add-image-grid grid:id=1:clap=128,1,32,1,0,1,0,1:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst " "grid_2x3_192x128_clap"
do_hash_test $dst "grid_2x3_192x128_clap"

dst=$TEMP_DIR/grid_2x3_192x128_clap_rotate_mirror.avif
do_test "$MP4BOX -add-image-grid grid:id=1:rotation=90:mirror-axis=vertical:clap=128,1,32,1,0,1,0,1:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_clap_rotate_mirror"
do_hash_test $dst "grid_2x3_192x128_clap_rotate_mirror"


test_end
