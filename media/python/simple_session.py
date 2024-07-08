import datetime
import types
import libgpac as gpac
import sys

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
gpac.init(mem_track, b"0")
#set logs
if logs:
	gpac.set_logs(logs)
#set global arguments, here inherited from command line
#gpac.set_args(sys.argv)

#create a session, blacklisting vtbdec
fs = gpac.FilterSession(0)

#load a source
f1 = fs.load_src("media/auxiliary_files/enst_video.h264")
#f1 = fs.load("avgen")
#print("src name " + f1.name)
#load a sink
f2 = fs.load("inspect:deep")
#print("sink name " + f2.name)
#enable status messages reporting
fs.reporting(True);

#coverage
fs.http_max_bitrate = fs.http_max_bitrate;
rate = fs.http_bitrate;
fs.is_supported_source('not a valid url');

#custom task callback for inspection of filters
def my_exec(self):
	if (self.session.last_task):
		return -1
	if (self.session.nb_filters<3):
		return 500
	print("In callback, nb filters: " + str(self.session.nb_filters))
	for i in range(self.session.nb_filters):
		f = self.session.get_filter(i)
		stats = f.get_statistics()
		print('#'+str(i+1)+ ': ' + f.name + ' nb_ipid: ' + str(f.nb_ipid) + ' nb_opid: ' + str(f.nb_opid) + ' nb tasks: ' + str(stats.nb_tasks_done) );
		if (stats.status != None):
			print('  status: ' + stats.status.decode('utf-8') )
		if (f.nb_ipid):
			print('Enumerating input pid props: ')
			f.ipid_enum_props(0, self)
			print('Source for pid is ' + f.ipid_source(0).name)

		if (f.nb_opid):
			print('Enumerating output pid props: ')
			f.opid_enum_props(0, self)
			print('Outputs for pid: ' + str(f.opid_sinks(0) ) )
		args = f.all_args()
		if args:
			print('All args:\n' + '\n'.join([str(elem) for elem in args])   )
	return None

def my_props(self, pname, pval):
	print('Property ' + pname + ' value: ' + str(pval))


#create the custom task
task = gpac.FilterTask('testtask')
task.execute = types.MethodType(my_exec, task)
task.on_prop_enum = types.MethodType(my_props, task)
task.count=0
fs.post(task)

#run the session in blocking mode
fs.run()

print('done')

fs.delete()
gpac.close()
