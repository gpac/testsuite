import * as evg from 'evg'

filter.pids = [];

//metadata
filter.set_name("EVGGen");
filter.set_desc("JS-based vector graphics generator");
filter.set_version("0.1beta");
filter.set_author("GPAC team");
filter.set_help("This filter provides testing of gpac's vector graphics bindings");

filter.set_arg({ name: "cov", desc: "perform coverage test for EVG bindings", type: GF_PROP_BOOL, def: "false"} );

let width = 320;
let height = 240;
let fps = {n:25, d:1};
let osize=0;
let cts=0;
let max_cts=100;
let pid;

/*create a path containing two centered ellipses*/
let path = new evg.Path();
path.ellipse(0, 0, 200, 100);
path.ellipse(0, 0, 100, 50);
/*fill the path with odd/even rule, hence creating a whole in the middle*/
path.zero_fill=false;
/*get the strike (line) outline path for this path*/
let dashes=[];
let strikepath = path.outline({width: 5.0, align: GF_PATH_LINE_OUTSIDE, join: GF_LINE_JOIN_BEVEL, dash: GF_DASH_STYLE_DASH_DASH_DOT, dashes: [0.5, 2.5, 1.0, 5.0] });

/*create a solid brush*/
let brush = new evg.SolidBrush();
brush.set_color('cyan');

/*create a text*/
let text = new evg.Text();
text.font = 'Times';
text.fontsize = 20;
text.baseline = GF_TEXT_BASELINE_HANGING;
text.align=GF_TEXT_ALIGN_CENTER;
text.lineSpacing=0;
//text.italic=true;
text.set_text(['My awsome text', 'Powered by GPAC 1.0']);
/*create a horizontal line, we will place it at the baseline of the text*/
let line = new evg.Path().move_to(-200, 0).line_to(200, 0).outline({width: 0.5} );

let centered=true;
/*matrix used to animate the ellipse*/
let mx = new evg.Matrix2D();
mx.scale(0.5, 0.5);
/*inverse matrix, used for picking*/
let mxi = new evg.Matrix2D(mx);
let mxi_invalid=true;

/*create a radial gradient*/
let rad = new evg.RadialGradient();
rad.set_points(0.0, 0.0, 10.0, 10.0, 15.0, 15.0);
rad.set_stop(0.0, 'red');
rad.set_stopf(1.0, 0.0, 0.0, 1.0, 0.5);
rad.mode = GF_GRADIENT_MODE_STREAD;
/*create a color matrix transfering blue component to green*/
let cmx = new evg.ColorMatrix();
cmx.bb = 0;
cmx.gb = 1;

/*create a texture from a local file*/
let tx = new evg.Texture("../auxiliary_files/logo.png", true);
tx.repeat_s = true;
tx.repeat_t = true;

/*get a matrix for the text*/
let mxtxt = new evg.Matrix2D();
mxtxt.translate(-50, -80);

function txp_fun(x, y)
{
	return {r:1.0, a:x/32}
}

/*create a parametric texture*/
let txp = new evg.Texture(32, 32, 'rgb', txp_fun, false);
txp.repeat_s = true;
txp.repeat_t = true;

filter.initialize = function() {

this.set_cap({id: "StreamType", value: "Video", output: true} );
this.set_cap({id: "CodecID", value: "raw", ouput: true} );

pid = this.new_pid();
pid.set_prop('StreamType', 'Visual');
pid.set_prop('CodecID', 'raw');
pid.set_prop('Width', width);
pid.set_prop('Height', height);
pid.set_prop('FPS', fps);
pid.set_prop('Timescale', fps.n);
pid.set_prop('PixelFormat', 'rgb');
//output packet size in bytes (8bpp RGB)
osize = 3 * width * height;
cts=0;
this.canvas=null;

if (filter.cov) do_coverage();
}

filter.update_arg = function(name, val)
{
}


filter.process = function()
{
	if (cts >= max_cts) {
		return GF_EOS;
	}
	let pck = pid.new_packet(osize);

	//basic red formatting of buffer
/*
	let pixbuf = new Uint8Array(pck.data);
	for (let i=0; i<osize; i+= 3) {
		pixbuf[i] = 255*cts/100;
		pixbuf[i+1] = 0;
		pixbuf[i+2] = 0;
	}
*/
	/*create a canvas for our output data if first time, otherwise reassign internal canvas data*/
	if (!this.canvas) {
		this.canvas = new evg.Canvas(width, height, 'rgb', pck.data);
	} else {		
		this.canvas.reassign(pck.data);
	}
	let canvas = this.canvas;
	canvas.centered = centered;
	//test clear
	canvas.clearf(1.0, 1.0, 0.0);
	canvas.clearf('yellow');
	//test clip clear
	let clip = {x:-200+4*cts,y:-200+4*cts,w:50,h:20};
	canvas.clearf(clip, 1.0);

/*	canvas.on_alpha = function(in_alpha, x, y) {
		//return Math.random() * 255;
		return x > y ? in_alpha : 255 - in_alpha;
		//return in_alpha;
	}
*/
	//animate ellipse matrix and keep inverse
	mx.rotate(0, 0, 0.1);
	mxi_invalid = true;

	/*some fun with color matrix*/
	brush.set_color(cmx.apply('blue'));

	//assign path, clipper and matrix
	canvas.path = path;
	canvas.clipper = {x:0,y:0,w:100,h:100};
	canvas.matrix = mx;
	//fill with solid and reset clipper 
	canvas.fill(brush);
	canvas.clipper = null;
	//fill with gradient
	canvas.fill(rad);

	//compute object matrix to scale the texture to the object bounds and translate it in the middle of the object bounds (in object local coor system)
	let mmx = new evg.Matrix2D();
	mmx.scale(200/tx.width, 100/tx.height);
	mmx.translate(100, 50);
	//and apply the same transfor as the object
	mmx.add(mx);
	tx.mx = mmx;
	//fill with texture and global alpha
	tx.set_alphaf(0.5);
	canvas.fill(tx);

	canvas.on_alpha = null;
	//solid paint of the outline 
	brush.set_color('green');
	canvas.path = strikepath;
	canvas.fill(brush);

	/*draw text baseline line*/
	brush.set_color('black');
	canvas.matrix = mxtxt;
	canvas.path = line;
	canvas.fill(txp);

	/*draw text*/
	canvas.matrix = mxtxt;
	canvas.path = text;
	canvas.fill(brush);

	/*set packet properties and send it*/
	pck.cts = cts;
	pck.sap = GF_FILTER_SAP_1;
	pck.send();
	cts ++;
	if (cts == max_cts) {
		pid.eos = true;
		return GF_EOS;
	}
	return GF_OK;
}

filter.process_event = function(pid, evt)
{
	if (evt.type != GF_FEVT_USER) {
		return;
	} 
	if (evt.ui_type == GF_EVENT_MOUSEMOVE) {
		let m = {x: evt.mouse_x, y: evt.mouse_y};
		if (centered) {
			m.x -= width/2;
			m.y = height/2 - m.y;
		}
		if (mxi_invalid) {
			mxi = mx.copy().inverse();
			mxi_invalid=false;
		}
		//print('mouse move ' + JSON.stringify(m) );
		m = mxi.apply(m);

		if (path.point_over(m))
			print('mouse over path !');

	}
}


function do_coverage()
{
	//matrix2d
	let mx = new evg.Matrix2D();
	mx = mx.skew(10, 10);
	mx = mx.skew_x(5);
	mx = mx.skew_y(-5);
	let pt = {x:20, y:20};
	let res = mx.apply(pt);
	mx = mx.inverse();
	let mx2 = mx.copy();
	let apt = mx2.get_scale();
	apt = mx2.get_translate();
	let d = mx2.get_rotate();
	d = mx.xx;
	mx.xy = 0.5;
	mx2.identity = true;

	//color matrix
	let acmx = new evg.ColorMatrix();
	acmx.bb = cmx.bb;
	let cres = acmx.applyf([1.0, 0.0, 0.0, 1.0]);
	acmx = acmx.multiply(cmx);

	//path
	let apath = path.clone();
	apath.reset();
	apath.move_to(0, 0);
	apath.cubic_to(10, 10, 20, -10, 30, 0);
	apath.close();
	apath.reset();
	apath.move_to(0, 0);
	apath.quadratic_to(10, 10, 20, 0);
	apath.reset();
	apath.rectangle(0, 0, 20, 20);
	apath.bezier({x:0, y:0}, {x:10, y:10}, {x:20, y:-10}, {x:30, y:10}, {x:40, y:-10}, {x:50, y:0} );
	apath.arc_bifs(100, 0, 50, 0, 50, 0);
	apath.arc_svg(100, 0, 50, 50);
	apath.arc(50, 10, 20);
	apath.flatten();

	apath.reset();
	apath.move_to(0, 0);
	apath.cubic_to(10, 10, 20, -10, 30, 0);
	apath.close();
	let ap2 = apath.get_flatten();
	apath.reset();
	apath.add_path(ap2);
	apath.point_over(0, 0);
	let rc = apath.bounds;

	//text
	let font = text.font;
	apath = text.get_path();
	let tsize = text.measure();

	//stencil
	let lin = new evg.LinearGradient();
	lin.set_points(0.0, 0.0, 1.0, 1.0);
	lin.set_alpha(128);
	lin.pad = GF_GRADIENT_MODE_REPEAT;

	let ab = new evg.SolidBrush();
	ab.set_colorf(1.0, 0.0, 1.0, 1.0);

	//matrix
	let mx1 = new evg.Matrix();
	mx2 = new evg.Matrix();
	mx1.scale(1.0, 2.0, 2.0);
	let eq = mx1.equal(mx2);

	let pt2 = mx1.apply({x:0, y:0, z:0});
	mx1.ortho(-100, 100, 100, -100, -100, 100);
	mx2.lookat( {x: 0, y:0, z:0}, {x: 0, y:0, z:-10}, {x: 0, y:1, z:0});

	//canvas
	let cnv = new evg.Canvas(32, 32, 'rgb');
	let c = cnv.centered;
	cnv.clear('yellow');
	let resY = cnv.toYUV(1.0, 0.0, 0.0);
	let resR = cnv.toRGB(resY);
	cnv.on_alpha = function(in_alpha, x, y) {
		return x > y ? in_alpha : 255 - in_alpha;
	}
	cnv.matrix = mx;
	cnv.path = text;
	cnv.compositeOperation = GF_EVG_SRC_OVER;
	let atxp = new evg.Texture(32, 32, 'rgb', txp_fun, true);
	cnv.fill(atxp);

	let aproj = new evg.Matrix().perspective(Math.PI/4, 1.0, 1, 100);
	let amv = new evg.Matrix().lookat({x: 0, y:0, z:0}, {x: 0, y:0, z:-10}, {x: 0, y:1, z:0});
	aproj.add(amv);
	cnv.matrix3d = aproj;
	apath.reset().rectangle(0, 0, 200, 200);
	cnv.path = apath;
	cnv.fill(brush);

	cnv = new evg.Canvas(32, 32, 'yuvl');
	cnv.matrix = mx;
	cnv.path = text;
	cnv.fill(atxp);

	let txbuf = new ArrayBuffer(200);
	atxp = new evg.Texture(2, 2, 'nv1l', txbuf, 4);
	cnv.fill(atxp);
	atxp = new evg.Texture(2, 2, 'nv2l', txbuf, 4);
	cnv.fill(atxp);
	atxp = new evg.Texture(2, 2, 'yp4l', txbuf, 4);
	cnv.fill(atxp);
	//test getPixel with bi-linear interpolation on a wide color fomat
	atxp.filtering = GF_TEXTURE_FILTER_HIGH_QUALITY;
	let ap = atxp.get_pixelf(0.001, 0.004);
	ap = atxp.get_pixel(20, 30);

	atxp = new evg.Texture(2, 2, 'yp2l', txbuf, 4);
	cnv.fill(atxp);
	atxp = new evg.Texture(2, 2, 'yuvl', txbuf, 4);
	cnv.fill(atxp);	
	atxp = new evg.Texture(2, 2, 'yuva', txbuf, 2);
	cnv.fill(atxp);
	atxp = new evg.Texture(2, 2, 'yp4a', txbuf, 2);
	let mycmx = new evg.ColorMatrix();
	mycmx.rr = 0.5;
	atxp.cmx = mycmx; 
	cnv.fill(atxp);

	cnv = new evg.Canvas(32, 32, 'argb');
	cnv.matrix = mx;
	cnv.path = text;
	let myb = new evg.SolidBrush();
	myb.set_colorf(0.0, 0.0, 0.0, 0.0);
	cnv.fill(myb);

	//texture
	let tx2 = tx.rgb2hsv();
	tx2 = tx2.hsv2rgb();
	tx2 = tx.yuv2rgb(cnv);
	tx2 = tx.split(0);
	tx2 = tx.convolution({w:3, h:1, k: [0, 1, 0]})

	//test getPixel with bi-linear interpolation on a 8-bit color fomat
	tx2.filtering = GF_TEXTURE_FILTER_HIGH_QUALITY;
	let pix = tx2.get_pixelf(0.001, 0.004);

	//canvas3d
	cnv = new evg.Canvas3D(32, 32, 'rgb');
	cnv.clear('yellow');
	resY = cnv.toYUV(1.0, 0.0, 0.0);
	resR = cnv.toRGB(resY);
    cnv.depth_buffer = new ArrayBuffer(32 * 32 * 4);
    let db = cnv.depth_buffer;
}

