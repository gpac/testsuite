import datetime
import libgpac as gpac
import sys

print("Welcome to GPAC Python !\nVersion: " + gpac.version + "\n" + gpac.copyright_cite)

#parse our args
mem_track=0
logs=None
print_graph=False
print_stats=False
for i, arg in enumerate(sys.argv):
	if arg=='-mem-track':
		mem_track=1
	elif arg=='-mem-track-stack':
		mem_track=2
	elif arg.startswith('-logs='):
		logs=arg[6:]
	elif arg == '-graph':
		print_graph=True
	elif arg == '-stats':
		print_stats=True

#init libgpac
gpac.init(mem_track)
#set logs
if logs:
	gpac.set_logs(logs)
#set global arguments, here inherited from command line
gpac.set_args(sys.argv)

#create a session, blacklisting vtbdec
fs = gpac.FilterSession(0, "vtbdec")

#load a source
fs.load_src("media/auxiliary_files/enst_video.h264")


#define a custom filter
class MyFilter(gpac.FilterCustom):
	def __init__(self, session):
		gpac.FilterCustom.__init__(self, session, "PYnspect")
		#indicate what we accept and produce - this can be done ether in the constructor or after
		self.push_cap("StreamType", "Visual", gpac.GF_CAPS_INPUT)
		#indicate we accept multiple PIDs
		self.set_max_pids(-1)

	#callbacks bmust be defined before instantiating an object from this class

	#we accept input pids, we must configure them
	def configure_pid(self, pid, is_remove):
		if is_remove:
			return 0
		if pid in self.ipids:
			print('PID reconfigured')
		else:
			print('PID configured - props:')
			pid.enum_props(self)
			evt = gpac.FilterEvent(gpac.GF_FEVT_PLAY)
			pid.send_event(evt)
		return 0

	#process
	def process(self):
		for pid in self.ipids:
			pck = pid.get_packet()
			if pck==None:
				#no packets, continue to process packets from other PIDs
				continue

			pck.ref()
			pid.drop_packet()
			print('Got Packet DTS ' + str(pck.dts) + ' CTS ' + str(pck.cts) + ' SAP ' + str(pck.sap) + ' dur ' + str(pck.dur) + ' size ' + str(pck.size))
			pck.unref()
		return 0

	def on_prop_enum(self, pname, pval):
		print('Property ' + pname + ' value: ' + str(pval))

#load a custom filter
my_filter = MyFilter(fs)



#enable status messages reporting
fs.reporting(True)

if print_stats:
	fs.print_stats()
if print_graph:
	fs.print_graph()

#run the session in blocking mode
fs.run()

fs.delete()
gpac.close()
