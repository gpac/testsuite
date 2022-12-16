
#test JSFilter as sink
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 $MEDIA_DIR/jsf/inspect.js" "jsf-inspect"

#test JSFilter links
single_test "$GPAC -h links $MEDIA_DIR/jsf/inspect.js" "jsf-inspect-links"


#test JSFilter as filter, forwarding to inspect, using threaded mode for coverage
test_begin "jsf-inspect-fwd"
insp=$TEMP_DIR/inspect.txt
if [ $test_skip != 1 ] ; then
do_test "$GPAC -threads=1 -i $MEDIA_DIR/auxiliary_files/enst_video.h264 $MEDIA_DIR/jsf/inspect.js:fwd=true @ inspect:deep:log=$insp" "jsf-inspect-fwd"
do_hash_test $insp  "jsf-inspect"
fi
test_end


#test JSFilter as source (mostly for packet generation function testing)
test_begin "jsf-generate"
insp=$TEMP_DIR/inspect.txt
if [ $test_skip != 1 ] ; then
do_test "$GPAC $MEDIA_DIR/jsf/generate.js @ inspect:deep:log=$insp" "jsf-generate"
do_hash_test $insp  "jsf-generate"
fi
test_end

#test JSFilter as source with boxpatch to insert a box, muxing the result
test_begin "jsf-generate-boxpatch"
dst=$TEMP_DIR/file.mp4
if [ $test_skip != 1 ] ; then
do_test "$GPAC $MEDIA_DIR/jsf/generate.js:patch @ -o $dst" "jsf-generate"
do_hash_test $dst  "jsf-generate"
fi
test_end


#test JSFilter as loader of filters, using a sink destination and a sink filter
test_begin "jsf-load-dest"
if [ $test_skip != 1 ] ; then
do_test "$GPAC $MEDIA_DIR/jsf/loader.js:in=$MEDIA_DIR/auxiliary_files/enst_video.h264:out=$TEMP_DIR/dump.264::f=inspect:allp" "jsf-load-dest"
do_hash_test $TEMP_DIR/dump.264 "jsf-load-dest"
fi
test_end

#test JSFilter as loader of filters, using a sink filter
single_test "$GPAC $MEDIA_DIR/jsf/loader.js:in=$MEDIA_DIR/auxiliary_files/enst_video.h264:f=inspect" "jsf-load-filter"


# XHR test
single_test "$GPAC $MEDIA_DIR/jsf/xhr.js" "jsf-xhr"

# XHR arraybuffer test
single_test "$GPAC $MEDIA_DIR/jsf/xhr.js:arb" "jsf-xhr-arb"

# XHR SAX local
test_begin "jsf-xhr-sax"
if [ $test_skip != 1 ] ; then
$MP4BOX -ttxt $MEDIA_DIR/auxiliary_files/subtitle.srt -out $TEMP_DIR/source.ttxt 2> /dev/null
do_test "$GPAC $MEDIA_DIR/jsf/xhr.js:url=$TEMP_DIR/source.ttxt:sax" "jsf-xhr-sax"

do_test "$GPAC $MEDIA_DIR/jsf/xhr.js:url=$TEMP_DIR/source.ttxt" "jsf-xhr-dom"
fi
test_end


# EVG generator
single_test "$GPAC $MEDIA_DIR/jsf/evg_src.js:cov inspect:deep" "jsf-evg-src"

# EVG overlay
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -blacklist=vtbdec,nvdec,ohevcdec $MEDIA_DIR/jsf/evg_overlay.js @ inspect:deep" "jsf-evg-overlay"

# WebGL generator
single_test "$GPAC $MEDIA_DIR/jsf/webgl.js inspect:deep" "jsf-webgl-src"

# WebGL using video input
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -blacklist=vtbdec,nvdec,ohevcdec $MEDIA_DIR/jsf/webgl_yuv.js @ inspect:deep" "jsf-webgl-video"

# WebGL using video input and outputing depth
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -blacklist=vtbdec,nvdec,ohevcdec $MEDIA_DIR/jsf/webgl_yuv.js:depth @ inspect:deep" "jsf-webgl-video-depth"

# EVG-3D generator
single_test "$GPAC $MEDIA_DIR/jsf/soft3d.js inspect:deep" "jsf-soft3d"

# EVG-3D overlay
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/counter.hvc -blacklist=vtbdec,nvdec,ohevcdec $MEDIA_DIR/jsf/soft3d_overlay.js @ inspect:deep" "jsf-soft3d-overlay"

# EVG-3D misc coverage
single_test "$GPAC $MEDIA_DIR/jsf/soft3d_cov.js inspect:deep" "jsf-soft3d-cov"

# EVG-3D RGB formats coverage
test_begin "jsf-soft3d-pfmt"
if [ $test_skip != 1 ] ; then

#only test RGB formats, for fill_single functions (not used in YUV)
pfstr="grey algr gral rgb4 rgb5 rgb6 rgba argb bgra abgr bgr xrgb rgbx xbgr bgrx"

for fmt in $pfstr ; do
do_test "$GPAC $MEDIA_DIR/jsf/soft3d_pfmt.js:pfmt=$fmt -o $TEMP_DIR/dump.$fmt" "$fmt"
do_hash_test "$TEMP_DIR/dump.$fmt" "$fmt"

done

fi
test_end


# Storage
single_test "$GPAC $MEDIA_DIR/jsf/storage.js" "jsf-storage"

# DOM APIs
single_test "$GPAC $MEDIA_DIR/jsf/dom_api.js" "jsf-DOMAPI"

# GPAC JS Core API
single_test "$GPAC -js=$MEDIA_DIR/jsf/core.js" "jsf-GPACCORE"

# GPAC JS controler API
single_test "$GPAC -js=$MEDIA_DIR/jsf/gpac.js -xopt -f=inspect -f=src=$MEDIA_DIR/auxiliary_files/logo.png" "jsf-GPACJS"

# GPAC JS controler API with custom filter
single_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 -js=$MEDIA_DIR/jsf/gpac_custom_filter.js" "jsf-GPACJS-Custom"

# GPAC JS controler API with custom DASH algo
single_test "$GPAC -js=$MEDIA_DIR/jsf/custom_dash_bind.js" "jsf-DASH-custom"

# GPAC JS process exec and worker (QJS libc module)
single_test "$GPAC -js=$MEDIA_DIR/jsf/worker_exec.js" "jsf-worker-exec"

# check loading DASH algo from JS (not running anything)
single_test "$GPAC dashin:algo=custom_dash" "jsf-dash"





#test JSFilter as loader of filters, using a sink destination and a sink filter
test_begin "jsf-fileio"
if [ $test_skip != 1 ] ; then
do_test "$GPAC $MEDIA_DIR/jsf/fileio_write.js" "write"

do_test "$GPAC $MEDIA_DIR/jsf/fileio_read.js -graph" "read"
do_hash_test $LOCAL_OUT_DIR/temp/jsf-fileio/inspect.txt "read"

fi
test_end

#test glpush filter for coverage of GPU access in JS
test_begin "jsf-glpush"
if [ $test_skip != 1 ] ; then
do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 glpush vout:vsync=0" "read"

do_test "$GPAC -i $MEDIA_DIR/auxiliary_files/enst_video.h264 glpush @ $MEDIA_DIR/jsf/inspect.js" "inspect"

fi
test_end
