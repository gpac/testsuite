import datetime
import libgpac as gpac
import sys

print("Welcome to GPAC Python !\nVersion: " + gpac.version + "\n" + gpac.copyright_cite)

if gpac.numpy_support:
	import numpy


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
		#indicate what we accept and produce - this can be done either in the constructor or after
		self.push_cap("StreamType", "Visual", gpac.GF_CAPS_INPUT_OUTPUT)
		self.nb_pck=0

	#callbacks bmust be defined before instantiating an object from this class

	#we accept input pids, we must configure them
	def configure_pid(self, pid, is_remove):
		if is_remove:
			return 0
		if pid in self.ipids:
			print('PID reconfigured')
		else:
			print('New PID !')
			opid = self.new_pid()
			opid.copy_props(pid)
			opid.set_prop('Bitrate', 500000)
			pid.opid = opid
			opid.pck_ref = None
		return 0

	#process
	def process(self):
		for pid in self.ipids:
			if pid.opid.pck_ref:
				continue

			pck = pid.get_packet()
			if pck==None:
				if pid.eos:
					pid.opid.eos = True
				break

			size = pck.size
			print('MyInspect Got Packet DTS ' + str(pck.dts) + ' CTS ' + str(pck.cts) + ' SAP ' + str(pck.sap) + ' dur ' + str(pck.dur) + ' size ' + str(size))
			data = pck.data
			if gpac.numpy_support:
				print("packet buffer class " + data.__class__.__name__ + " size " + str(len(data) ) )
			else:
				print("packet buffer class " + data.__class__.__name__ )

			#test forward
			self.nb_pck += 1

			self.nb_pck = 6

			if self.nb_pck==1:
				pid.opid.forward(pck)
			#test new ref
			elif self.nb_pck==2:
				opck = pid.opid.new_pck_ref(pck)
				opck.copy_props(pck)
				opck.send()
			#test new alloc
			elif self.nb_pck==3:
				opck = pid.opid.new_pck(size)
				opck.copy_props(pck)
				odata = opck.data
				#copy array
				if gpac.numpy_support:
					numpy.copyto(odata, data)
				opck.send()
			#test new data ref
			elif self.nb_pck==4:
				opck = pid.opid.new_pck_shared(data)
				opck.copy_props(pck)
				#keep reference
				pid.opid.pck_ref = pck
				pid.opid.pck_ref.ref()
				opck.send()
			#test packet copy
			elif self.nb_pck==5:
				opck = pid.opid.new_pck_copy(pck)
				opck.copy_props(pck)
				opck.send()
			#test packet clone
			elif self.nb_pck==6:
				opck = pid.opid.new_pck_clone(pck)
				opck.copy_props(pck)
				opck.send()
				self.nb_pck = 0

			pid.drop_packet()
		return 0

	def packet_release(self, opid, pck):
		if opid.pck_ref:
			opid.pck_ref.unref()
			opid.pck_ref = None

	def on_rmt_event(self, text):
		print('Remoter got message ' + text)

#load a custom filter
my_filter = MyFilter(fs)

#load a dest
ins = fs.load("inspect:deep")
ins.set_source(my_filter)


gpac.set_rmt_fun(my_filter)


#enable status messages reporting
fs.reporting(True)

#run the session in blocking mode
fs.run()

if print_stats:
	fs.print_stats()
if print_graph:
	fs.print_graph()

fs.delete()
gpac.close()
