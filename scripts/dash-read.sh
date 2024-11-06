
#!/bin/sh
inspectfilter="inspect:allp:deep:interleave=false:test=noprop:fmt=%dts%-%cts%-%sap%%lf%"
dur=10
start=0

source=http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-AV-BS.mpd

dash_test ()
{

test_begin "dash-read-$1"

if [ $test_skip = 1 ] ; then
return
fi

#server is really not fast from time to time, we increase the timeout to 40s...
if [ $1 == "hls" ] ; then
test_timeout=40
fi

myinspect=$TEMP_DIR/inspect.txt
do_test "$GPAC -i $2 $inspectfilter:dur=$dur:start=$start:buffer=10000:log=$myinspect" "read"

if [ $3 != 0 ] ; then
do_hash_test $myinspect "read"
fi

test_end
}


dash_test "no-adapt" "$source:gpac:algo=none:start_with=max_bw" 1

algos="gbuf grate bba0 bolaf bolab bolau bolao"
for algo in $algos ; do
dash_test "$algo" "$source --algo=$algo"  1
done

dash_test "abort" "$source:gpac:abort"  1
dash_test "auto" "$source:gpac:auto_switch=1"  1
dash_test "bmin" "$source:gpac:use_bmin=mpd"  1
dash_test "xlink" "http://dash.akamaized.net/dash264/TestCases/5b/nomor/6.mpd" 1

start=255
dash_test "seek" "http://dash.akamaized.net/dash264/TestCases/5b/nomor/6.mpd" 1
start=100
dash_test "seek2" "http://dash.akamaized.net/dash264/TestCases/5b/nomor/6.mpd" 1
start=0

dash_test "ondemand" "http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-onDemand/mp4-onDemand-mpd-V.mpd" 1

dur=4

#this test is commented due to clock drift in livesim to be further investigated - we test live dash through our httpout tests
#dash_test "live" "https://livesim.dashif.org/livesim/mup_30/testpic_2s/Manifest.mpd" 0

dash_test "live-timeline" "https://livesim.dashif.org/livesim/segtimeline_1/testpic_2s/Manifest.mpd" 0

#HLS/smooth: certificate names mismatch (so use -broken-cert) and use low quality (highest is 8Mbps, may timeout)
h2_opts="-broken-cert"
has_h2=`$GPAC -hx core 2>/dev/null | grep no-h2`
if [ -n "$has_h2" ] ; then
h2_opts="$h2_opts -no-h2"
fi

dash_test "hls" "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8 --start_with=min_bw --algo=none $h2_opts" 1

#DEAD LINK - dash_test "smooth" "http://amssamples.streaming.mediaservices.windows.net/69fbaeba-8e92-4740-aedc-ce09ae945073/AzurePromo.ism/manifest $h2_opts" 1
#live stream, do not hash
dash_test "smooth" "https://demo.unified-streaming.com/k8s/live/stable/live.isml/Manifest?time_shift=300 $h2_opts" 0

#VOD test seq without tfxd
#DEAD LINK - dash_test "smooth-no-tfxd" "https://test.playready.microsoft.com/smoothstreaming/SSWSS720H264/SuperSpeedway_720.ism/manifest $h2_opts" 1
#DEAD LINK - dash_test "smooth-no-tfxd" "http://profficialsite.origin.mediaservices.windows.net/c51358ea-9a5e-4322-8951-897d640fdfd7/tearsofsteel_4k.ism/manifest $h2_opts" 1
dash_test "smooth-no-tfxd" "https://demo.unified-streaming.com/k8s/features/stable/usp-s3-storage/tears-of-steel/tears-of-steel.ism/Manifest $h2_opts" 1

#test no bitstream switching mode (reload of init segment at switch), forcing quality switch at each seg
dash_test "NBS" "http://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-V-NBS.mpd:gpac:auto_switch=1" 1
