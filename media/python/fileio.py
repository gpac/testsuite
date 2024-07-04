import sys
import datetime
import types
import libgpac as gpac
import os

numpy_support=True
try:
    import numpy as np
except ImportError:
    print("\nnumpy not present, fileIO cannot be tested\n")
    sys.exit(0)


#init libgpac in mem-track mode
gpac.init(1, b"0")

#set global arguments for test
gpac.set_args( ["gpacpy", "-for-test", "-no-reassign"] )


class MyFileIO:
	def __init__(self):
		self.file = None
		self.is_eof=False

	def open(self, url, mode):
		if mode.find('r')>=0 and not os.path.isfile(url):
			return False
		self.file = open(url, mode)
		self.url = url
		return True

	def close(self):
		self.file.close()
		self.file=None

	def write(self, np_arr, _size):
		self.file.write(np_arr)
		return np.size(np_arr)

	def read(self, np_array, _size):
		tmp = np.fromfile(self.file, dtype=np.ubyte, count=np.size(np_array))
		size = np.size(tmp)
		np_array[:size] = tmp
		if size==0:
			self.is_eof=True
		return size

	def seek(self, pos, whence):
		self.file.seek(pos, whence)
		self.is_eof=False
		return 0

	def tell(self):
		return self.file.tell()

	def eof(self):
		return self.is_eof

	def exists(self, url):
		if not os.path.isfile(url):
			return False
		return True

if not os.path.exists("results/temp/py_fileio"):
	os.mkdir("results/temp/py_fileio")

if not os.path.exists("results/temp/py_fileio/dash"):
	os.mkdir("results/temp/py_fileio/dash")

def run_test(mode):
	#create a session, blacklisting vtbdec
	fs = gpac.FilterSession(0)

	fio = MyFileIO()

	name="unknown"
	#single file destination fileIO
	if mode==0:
		fio_root = gpac.FileIO("results/temp/py_fileio/record.mp4", fio)
		f1 = fs.load_src("media/auxiliary_files/counter.hvc")
		f2 = fs.load_dst(fio_root.url)
		name="output gfio"

	#single file source fileIO
	if mode==1:
		fio_root = gpac.FileIO("media/auxiliary_files/counter.hvc", fio)
		f1 = fs.load_src(fio_root.url)
		f2 = fs.load("inspect:deep:log=results/temp/py_fileio/inspect-sf.txt")
		name="input gfio"

	#multiple file destination fileIO (dash creation)
	if mode==2:
		fio_root = gpac.FileIO("results/temp/py_fileio/dash/live.mpd", fio)
		f1 = fs.load_src("media/auxiliary_files/counter.hvc")
		f2 = fs.load_dst(fio_root.url)
		name="output DASH gfio"

	#multiple file source fileIO (dash read)
	if mode==3:
		fio_root = gpac.FileIO("results/temp/py_fileio/dash/live.mpd", fio)
		f1 = fs.load_src(fio_root.url)
		f2 = fs.load("inspect:deep:log=results/temp/py_fileio/inspect-dash.txt")
		name="input DASH gfio"


	#run the session in blocking mode
	fs.run()
	fs.delete()
	print('test ' + name + ' done')



run_test(0)
run_test(1)
run_test(2)
run_test(3)


ret = gpac.close()
print('gpac closed with code ' + str(ret))
sys.exit(ret)
