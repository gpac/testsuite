#test software stretcher


pfstr="yuv yuvl yuv2 yp2l yuv4 yp4l uyvy vyuy yuyv yvyu nv12 nv21 nv1l nv2l yuva grey gral algr rgb4 rgb5 rgb6 rgba argb bgra rgb bgr xrgb rgbx xbgr bgrx rgbd rgbds rgbs rgbas"

yuv_dst_pfstr="yuv yuv2 yuv4"


softstretch_test ()
{

test_begin "softstretch-$1"
if [ $test_skip  = 1 ] ; then
return
fi

skip_dump=0;

case "$1" in
"rgbd" )
	skip_dump=1 ;;
"rgbds" )
	skip_dump=1 ;;
"rgbs" )
	skip_dump=1 ;;
"rgbas" )
	skip_dump=1 ;;
esac

if [ $skip_dump = 0 ] ; then

#test YUV -> desired format (for copy row)
rawfile=$TEMP_DIR/raw.$1
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.jpg compositor:opfmt=$1 @ -o $rawfile -blacklist=vtbdec,nvdec,ohevcdec" "dump-$1"
do_hash_test "$rawfile" "dump-$1"

#test RGBA -> desired format (for merge row)
rawout=$TEMP_DIR/dump_alpha.$1
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.png compositor:opfmt=$1 @ -o $rawout -stats" "blit-alpha-$1"
do_hash_test "$rawout" "dump-alpha-$1"

fi

#check desired format -> rgb (for line loaders)
rawout=$TEMP_DIR/dump.rgb
do_test "$GPAC -i $rawfile:size=128x128 compositor:opfmt=rgb @ -o $rawout -stats" "blit-rgb"
do_hash_test "$rawout" "blit-$pf-to-rgb"

#check if input is 10 bits, if so also test our 10->8 bit YUV conversions
is_10bits=0

case "$1" in
"yuvl" )
	is_10bits=1 ;;
"yp2l" )
	is_10bits=1 ;;
"yp4l" )
	is_10bits=1 ;;
"nv1l" )
	is_10bits=1 ;;
"nv2l" )
	is_10bits=1 ;;
esac

if [ $is_10bits == 1 ] ; then

#check 10->8 on yuv, yuv422 and yuv444 destinations
for pf in $yuv_dst_pfstr ; do

rawout=$TEMP_DIR/dump.$pf
do_test "$GPAC -i $rawfile:size=128x128 compositor:opfmt=$pf @ -o $rawout -stats" "blit-$pf"
do_hash_test "$rawout" "blit-$1-to-$pf"

done

fi
test_end
}

for i in $pfstr ; do
	softstretch_test $i
done

