#!/bin/sh
test_iff_grid()
{
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
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:image-size=4096x858:image-grid-size=1x2:ref=dimg,2:ref=dimg,3:primary -add-image $src:id=2 -add-image $src:id=3 -ab avif -new $dst" "grid_2x1"
do_hash_test $dst "grid_2x1"

dst=$TEMP_DIR/grid_2x2.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:image-size=4096x1716:image-grid-size=2x2:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -ab avif -ab miaf -new $dst" "grid_2x2"
do_hash_test $dst "grid_2x2"

dst=$TEMP_DIR/grid_2x3_192x128.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128"
do_hash_test $dst "grid_2x3_192x128"

# grid transforms
dst=$TEMP_DIR/grid_2x3_192x128_rotate.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:rotation=90:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_rotate"
do_hash_test $dst "grid_2x3_192x128_rotate"

dst=$TEMP_DIR/grid_2x3_192x128_mirror.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:mirror-axis=vertical:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_mirror"
do_hash_test $dst "grid_2x3_192x128_mirror"

dst=$TEMP_DIR/grid_2x3_192x128_clap.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:clap=128,1,32,1,0,1,0,1:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst " "grid_2x3_192x128_clap"
do_hash_test $dst "grid_2x3_192x128_clap"

dst=$TEMP_DIR/grid_2x3_192x128_clap_rotate_mirror.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:rotation=90:mirror-axis=vertical:clap=128,1,32,1,0,1,0,1:image-size=192x128:image-grid-size=2x3:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:ref=dimg,6:ref=dimg,7:primary -add-image $src:id=2 -add-image $src:id=3 -add-image $src:id=4 -add-image $src:id=5 -add-image $src:id=6 -add-image $src:id=7 -ab avif -ab miaf -new $dst" "grid_2x3_192x128_clap_rotate_mirror"
do_hash_test $dst "grid_2x3_192x128_clap_rotate_mirror"

dst=$TEMP_DIR/clap_grid_2x2_2048x858.avif
do_test "$MP4BOX -add-derived-image :type=grid:id=1:image-pixi=8,8,8:image-size=2048x858:image-grid-size=2x2:ref=dimg,2:ref=dimg,3:ref=dimg,4:ref=dimg,5:primary  -add-image $src:clap=1024,1,429,1,0,1,0,1:id=2 -add-image $src:clap=1024,1,429,1,0,1,0,1:id=3 -add-image $src:clap=1024,1,429,1,0,1,0,1:id=4 -add-image $src:clap=1024,1,429,1,0,1,0,1:id=5 -ab avif -ab miaf -new $dst" "clap_grid_2x2_2048x858"
do_hash_test $dst "clap_grid_2x2_2048x858"


# iden derived items
dst=$TEMP_DIR/iden_no_transform.avif
do_test "$MP4BOX -add-derived-image :type=iden:id=1:image-pixi=8,8,8:image-size=2048x858:ref=dimg,2:primary -add-image $src:hidden:id=2 -ab avif -ab miaf -new $dst" "iden_no_transform"
do_hash_test $dst "iden_no_transform"

dst=$TEMP_DIR/iden_no_transform_no_hidden.avif
do_test "$MP4BOX -add-derived-image :type=iden:id=1:image-pixi=8,8,8:image-size=2048x858:ref=dimg,2:primary -add-image $src:id=2 -ab avif -ab miaf -new $dst" "iden_no_transform_no_hidden"
do_hash_test $dst "iden_no_transform_no_hidden"

dst=$TEMP_DIR/iden_rotate.avif
do_test "$MP4BOX -add-derived-image :type=iden:id=1:image-pixi=8,8,8:image-size=858x2048:ref=dimg,2:rotation=90:primary -add-image $src:hidden:id=2 -ab avif -ab miaf -new $dst" "iden_rotate"
do_hash_test $dst "iden_rotate"

dst=$TEMP_DIR/iden_mirror.avif
do_test "$MP4BOX -add-derived-image :type=iden:id=1:image-pixi=8,8,8:image-size=2048x858:ref=dimg,2:mirror-axis=horizontal:primary -add-image $src:hidden:id=2 -ab avif -ab miaf -new $dst" "iden_mirror"
do_hash_test $dst "iden_mirror"

dst=$TEMP_DIR/iden_clap.avif
do_test "$MP4BOX -add-derived-image :type=iden:id=1:image-pixi=8,8,8:image-size=1024x429:ref=dimg,2:clap=1024,1,429,1,0,1,0,1:primary -add-image $src:hidden:id=2 -ab avif -ab miaf -new $dst" "iden_clap"
do_hash_test $dst "iden_clap"

#overlay
dst=$TEMP_DIR/img_overlay.avif
do_test "$MP4BOX -add-image $src:id=1 -add-image $src:id=2 -add-derived-image :type=iovl:id=3:primary:image-pixi=8,8,8:image-size=2000x2000:image-overlay-offsets=100,100,50,500:image-overlay-color=65535,0,0,32125:ref=dimg,1:ref=dimg,2 -ab avif -ab miaf -new $dst" "img_overlay"
do_hash_test $dst "img_overlay"

#overlay transform
dst=$TEMP_DIR/img_overlay_mirror.avif
do_test "$MP4BOX -add-image $src:id=1 -add-image $src:id=2 -add-derived-image :type=iovl:id=3:primary:image-pixi=8,8,8:image-size=2000x2000:image-overlay-offsets=100,100,50,500:image-overlay-color=65535,0,0,32125:ref=dimg,1:ref=dimg,2:mirror-axis=horizontal -ab avif -ab miaf -new $dst" "img_overlay_mirror"
do_hash_test $dst "img_overlay_mirror"

#overlay large values
dst=$TEMP_DIR/overlay_large.avif
do_test "$MP4BOX -add-image $src:id=1 -add-derived-image :type=iovl:id=2:primary:image-pixi=8,8,8:image-size=120000x120000:image-overlay-offsets=100000,50000:image-overlay-color=65535,655535,0,32125:ref=dimg,1 -ab avif -ab miaf -new $dst" "overlay_large"
do_hash_test $dst "overlay_large"

test_end
}

test_iff_grid


test_iff_autogrid()
{
test_begin "iff-autogrid"

 if [ $test_skip = 1 ] ; then
  return
 fi

img=$TEMP_DIR/res.heif
do_test "$MP4BOX -add-image $MEDIA_DIR/auxiliary_files/counter.hvc:time=0-5 -add-image agrid -new $img" "auto_grid"
do_hash_test $img "auto_grid"

img=$TEMP_DIR/res_ar.heif
do_test "$MP4BOX -add-image $MEDIA_DIR/auxiliary_files/counter.hvc:time=0-5 -add-image agrid=1.0 -new $img" "auto_grid_ar"
do_hash_test $img "auto_grid_ar"


test_end
}

test_iff_autogrid
