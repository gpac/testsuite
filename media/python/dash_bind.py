import datetime
import types
import sys

import libgpac as gpac

print("Welcome to GPAC Python !\nVersion: " + gpac.version + "\n" + gpac.copyright_cite)

#parse our args
mem_track=0
logs=None
for i, arg in enumerate(sys.argv):
	if arg=='-mem-track':
		mem_track=1
	elif arg=='-mem-track-stack':
		mem_track=2
	elif arg.startswith('-logs='):
		logs=arg[6:]

#init libgpac
gpac.init(mem_track)
#set logs
if logs:
	gpac.set_logs(logs)
#set global arguments, here inherited from command line
#gpac.set_args(sys.argv)

class MyCustomDASHAlgo:
	def on_period_reset(self, type):
		print('period reset type ' + str(type))

	def on_new_group(self, group):
		print('new group ' + str(group.idx) + ' qualities ' + str(len(group.qualities)) + ' codec ' + group.qualities[0].codec);

	def on_rate_adaptation(self, group, base_group, force_low_complexity, stats):
		print('We are adapting on group ' + str(group.idx) )
		print('' + str(stats))
		return 0

	def on_download_monitor(self, group, stats):
		print('download monitor group ' + str(group.idx) + ' stats ' + str(stats) );
		return -1


mydash = MyCustomDASHAlgo()

#define a custom filter session
class MyFilterSession(gpac.FilterSession):
	def __init__(self, flags=0, blacklist=None, nb_threads=0, sched_type=0):
		gpac.FilterSession.__init__(self, flags, blacklist, nb_threads, sched_type)

	def on_filter_new(self, f):
		print("new filter " + f.name);
		if f.name == "dashin":
			f.bind(mydash);

	def on_filter_del(self, f):
		print("del filter " + f.name);

#create a session
fs = MyFilterSession(0)

#load a source
f1 = fs.load_src("https://download.tsi.telecom-paristech.fr/gpac/DASH_CONFORMANCE/TelecomParisTech/mp4-live-1s/mp4-live-1s-mpd-AV-BS.mpd")
if not f1:
    raise Exception('Failed to load source')

#load a sink
f2 = fs.load("inspect:interleave:false:deep:dur=10")
if not f2:
    raise Exception('Failed to load sink')

#run the session in blocking mode
fs.run()

print('done')

fs.delete()
gpac.close()
