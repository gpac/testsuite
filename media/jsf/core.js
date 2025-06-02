import * as evg from 'evg'
import { Sys as sys } from 'gpaccore'
import { Bitstream as BS } from 'gpaccore'
import { SHA1 as SHA1 } from 'gpaccore'
import { File as File } from 'gpaccore'

_gpac_log_name="";

function bufferToHex(buffer) {
    var s = '', h = '0123456789ABCDEF';
    (new Uint8Array(buffer)).forEach((v) => { s += h[v >> 4] + h[v & 15]; });
    return s;
}

function bufferToString(buffer) {
	return String.fromCharCode.apply(null, new Uint8Array(buffer));
}

print("Running, your are " + sys.getenv('USER') );

sys.enable_rmtws();
sys.prompt_input();
sys.prompt_string(1);
let wdir = sys.last_wdir;
sys.last_wdir = wdir;

sys.prompt_echo_off(true, true);
sys.prompt_echo_off(false, true);
sys.prompt_code(sys.GF_CONSOLE_RED);
let ts = sys.prompt_size();
if (ts) {
	print('window size is ' + ts.w + 'x' + ts.h);
}
sys.prompt_code(sys.GF_CONSOLE_RESET);

sys.error_string(-1);

sys.clock_ms();
sys.clock_us();
sys.rand_init(true);
sys.rand();
sys.rand64();
sys.get_utc();
sys.get_utc("Sun, 06 Nov 1994 08:49:37 GMT");
sys.get_utc(1994, 12, 3, 8, 49, 37);

sys.get_opt('core', 'version');
sys.set_opt('core', 'version', '100.0.0');
sys.discard_opts();

let files = sys.enum_directory('/');

files = sys.enum_directory('.');
files.forEach( (f) => {
	for(let propertyName in f) {
		print("f." + propertyName + " : " + f[propertyName]);
	}
});


let i=0;
for (i=0; i < sys.args.length; i++) {
	sys.set_arg_used(i, true);
	if (sys.args[i].startsWith("-f=") ) {
		continue;
	}
}

for(let propertyName in sys) {
	print("sys." + propertyName + " : " + sys[propertyName]);
}


print('file hash is ' + bufferToHex( sys.sha1('index.html') ) );
var ab = sys.load_file('index.html');
var comp_ab = sys.compress(ab);
ab = sys.decompress(comp_ab);
print('file payload after comp/decomp is ' + bufferToString( ab ) );

let buf = sys.base64enc(ab);
let res = sys.base64dec(buf);

buf = sys.base16enc(ab);
res = sys.base16dec(buf);

print('4CC test: ' + sys.fcc_to_str(0xAABBCCDD) );

sys.htonl(0xAABB);
sys.htons(0xAABB);
sys.ntohl(0xAABB);
sys.ntohs(0xAABB);

sys.gc();

//test file system opts
sys.mkdir('mytest');
sys.dir_exists('mytest');
sys.dir_clean('mytest');
sys.rmdir('mytest');

sys.pixfmt_depth('rgba');

let ar = new ArrayBuffer(8);
let view = new Int32Array(ar);
view[0] = 100;
view[1] = 200;

import('somemod.so').then(obj => { } ).catch(err => {  } );
sys.sleep(0);
sys.ntp_shift({'n': 1000000, 'd': 9000}, 120000);
sys.exit(0, 0);
sys.keyname(42);
sys.get_event_type('keydown');
sys.color_lerp(0.5, 'black', 'white');
sys.color_component('black', 0);
sys.color_component('black', 1);
sys.color_component('black', 2);
sys.color_component('black', 3);

sys.rect_intersect({x: 0, y: 0, w: 20, h: 20}, {x: 10, y: 10, w: 20, h: 20}  );

try {
	sys.load_script('__null_test.js');
} catch (e) {

}

test_bs();
test_file();


print('done');


function test_bs()
{
	let bs = new BS();
	bs.put_u8(1);
	bs.put_s8(2);
	bs.put_u16(3);
	bs.put_u16_le(4);
	bs.put_s16(5);
	bs.put_u24(6);
	bs.put_u32(7);
	bs.put_u32_le(8);
	bs.put_s32(9);
	bs.put_u64(10);
	bs.put_u64_le(11);
	bs.put_s64(12);
	bs.put_float(13.0);
	bs.put_double(14.0);
	bs.put_4cc("GPAC");
	bs.put_bits(15, 5);
	bs.put_bits(16, 40);
	bs.is_align();
	bs.bits_available;
	bs.align();
	bs.put_string('foo');
	bs.put_data(ar);
	bs.flush();

	let res = bs.get_content();
	sys.crc32(res);
	sys.sha1(res);

	let sha = new SHA1();
	sha.push(res);
	sha.get();

	bs = new BS(res);
	print(''+bs.size);
	print(''+bs.pos);
	print(''+bs.bit_offset);
	print(''+bs.bit_position);
	print(''+bs.refreshed_size);

	bs.get_u8();
	bs.get_s8();
	bs.get_u16();
	bs.get_u16_le();
	bs.get_s16();
	bs.get_u24();
	bs.get_u32();
	bs.get_u32_le();
	bs.get_s32();
	bs.get_u64();
	bs.get_u64_le();
	bs.get_s64();
	bs.get_float();
	bs.get_double();
	bs.get_4cc();
	bs.get_bits(5);
	bs.get_bits(40);
	bs.align();
	bs.get_string();
	bs.get_data(ar);

	bs.pos = 0;
	bs.peek(8);
	bs.skip(10);
	bs.truncate();
	bs.size;
	bs.epb_mode(true);

	let nbs = new BS();
	nbs.transfer(bs);
	nbs.insert_data(ar);

}


function test_file()
{

	let file = new File();
	//test BS from file
	let bs = new BS(file, true);
	bs.put_u32(0);
	bs.flush();
	bs = null;
	file.close();

	file = new File('mytest/myfile.txt', 'w');
	file.write(ar);
	file.puts("my string\n");
	file.putc("n");
	file.flush();
	file.close();

	sys.move('mytest/myfile.txt', 'mytest/myfile2.txt')
	sys.basename('mytest/myfile2.txt');
	sys.file_ext('mytest/myfile2.txt');
	sys.file_exists('mytest/myfile2.txt');
	sys.mod_time('mytest/myfile2.txt');

	file = new File('mytest/myfile2.txt', 'r');
	file.read(ar);
	file.gets();
	file.getc();

	for(let propertyName in file) {
		print("file." + propertyName + " : " + file[propertyName]);
	}
	file.pos = 0;
	file.close();

	sys.del('mytest/myfile2.txt');
    sys.rmdir('mytest');

}
