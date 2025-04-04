#test software stretcher

#we don't test the following formats not supported as output format by our 2D rasterizer: yuva rgbd rgbds rgbs rgbas
pfstr="yuv yuvl yuv2 yp2l yuv4 yp4l uyvy vyuy yuyv yvyu nv12 nv21 nv1l nv2l grey gral algr rgb4 rgb5 rgb6 rgba argb bgra rgb bgr xrgb rgbx xbgr bgrx"

yuv_dst_pfstr="yuv yuv2 yuv4"


softstretch_test ()
{

test_begin "softstretch-$1"
if [ $test_skip  = 1 ] ; then
return
fi


#test YUV -> desired format (for copy row)
rawfile=$TEMP_DIR/raw.$1
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.jpg compositor:opfmt=$1 @ -o $rawfile -blacklist=vtbdec,nvdec,ohevcdec" "dump-$1"
do_hash_test "$rawfile" "dump-$1"

#test RGBA -> desired format (for merge row)
rawout=$TEMP_DIR/dump_alpha.$1
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/logo.png compositor:opfmt=$1 @ -o $rawout" "blit-alpha-$1"
do_hash_test "$rawout" "dump-alpha-$1"

#check desired format -> rgb (for line loaders)
rawout=$TEMP_DIR/dump.rgb
do_test "$GPAC -i $rawfile:size=128x128 compositor:opfmt=rgb @ -o $rawout" "blit-rgb"
do_hash_test "$rawout" "blit-$1-to-rgb"


#check if input is 10 bits, if so also test our 10->8 bit YUV conversions
is_10bits=0
is_yuv=0
check_32b=0

case "$1" in
"yuvl" )
	is_10bits=1 ;;
"yp2l" )
	is_10bits=1
	check_32b=1 ;;
"yp4l" )
	is_10bits=1
	check_32b=1 ;;
"nv1l" )
	is_10bits=1 ;;
"nv2l" )
	is_10bits=1 ;;
"yuv")
	is_yuv=1 ;;
"yuv2")
	is_yuv=1 ;;
"yuv4")
	is_yuv=1 ;;
"uyvy")
	is_yuv=1 ;;
"vyuy")
	is_yuv=1 ;;
"yuyv")
	is_yuv=1 ;;
"yvyu")
	is_yuv=1 ;;
"nv12")
	is_yuv=1 ;;
"nv21")
	is_yuv=1 ;;
"yuva")
	is_yuv=1 ;;
esac

if [ $is_yuv == 1 ] ; then
rawout=$TEMP_DIR/dump_yuv.yuv
do_test "$GPAC -i $rawfile:size=128x128 compositor:opfmt=yuv @ -o $rawout" "dump-$1-yuv"
do_hash_test "$rawout" "dump-$1-yuv"

fi

if [ $is_10bits == 1 ] ; then

#check 10->8 on yuv, yuv422 and yuv444 destinations
for pf in $yuv_dst_pfstr ; do

rawout=$TEMP_DIR/dump.$pf
do_test "$GPAC -i $rawfile:size=128x128 compositor:opfmt=$pf @ -o $rawout" "blit-$pf"

#yp4l->yuv without SSE does not give exactly the same results as with sse, disable hash test
check_hash=1
if [ $check_32b = 1 ] ; then
 if [ $GPAC_OSTYPE = "lin32" ] || [ $GPAC_OSTYPE = "win32" ] || [ $GPAC_CPU = "arm" ]  ; then
  check_hash=0
 fi
fi

if [ $check_hash = 1 ] ; then
 do_hash_test "$rawout" "blit-$1-to-$pf"
else
 if [ ! -f $rawout ] ; then
  result="output not present"
 fi
fi

done

fi


test_end
}

for i in $pfstr ; do
	softstretch_test $i
done

